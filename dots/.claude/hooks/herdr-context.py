#!/usr/bin/env python3
"""Feed herdr's agent sidebar two extra lines about this Claude pane.

  task  — what this agent is working on (from the last prompt you sent)
  why   — why it is blocked, when it is blocked

herdr collapses every "waiting on you" situation into one `blocked` state (see
~/.local/state/herdr/agent-detection/remote/claude.toml — an AskUserQuestion
prompt and a permission prompt both match it). The sidebar therefore cannot say
whether an agent wants an answer or an approval, and says nothing at all about
what it was doing. These hooks report that directly from Claude Code, so it is
ground truth rather than terminal scraping.

Deliberately NOT written into herdr's own ~/.claude/hooks/herdr-agent-state.sh:
that file is managed by `herdr integration install claude` and says so in its
header — reinstalling would overwrite anything added there.

Wire protocol: one JSON-RPC line over the pane's unix socket, method
pane.report_metadata. Contract from `herdr api schema --json`
(PaneReportMetadataParams): tokens is at most 16 keys matching
^[A-Za-z0-9_-]{1,32}$, a null value clears a key, ttl_ms <= 86400000.

Every path exits 0. A hook that fails must never disturb the session.
Set HERDR_CONTEXT_DEBUG=1 to append raw payloads to .herdr-context-debug.jsonl.
"""

import json
import os
import random
import re
import socket
import sys
import time

SOURCE = "claude-context"
# The sidebar is ~26-36 columns wide, so anything longer than this is noise.
MAX_LEN = 34


def log_debug(payload, action):
    if os.environ.get("HERDR_CONTEXT_DEBUG") != "1":
        return
    try:
        path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            ".herdr-context-debug.jsonl")
        with open(path, "a", encoding="utf-8") as fh:
            fh.write(json.dumps({"action": action, "payload": payload}) + "\n")
    except Exception:
        pass


def shorten(text, limit=MAX_LEN):
    """Collapse to one clean line and cut on a word boundary where possible."""
    if not isinstance(text, str):
        return None
    text = " ".join(text.split())
    if not text:
        return None
    if len(text) <= limit:
        return text
    cut = text[:limit - 1]
    space = cut.rfind(" ")
    if space > limit * 0.6:
        cut = cut[:space]
    return cut + "…"


def describe_question(tool_input):
    """'? Extra hues' — AskUserQuestion headers are <=12 chars by design."""
    questions = tool_input.get("questions")
    if isinstance(questions, list) and questions:
        headers = []
        for q in questions:
            if not isinstance(q, dict):
                continue
            headers.append(q.get("header") or q.get("question"))
        headers = [h for h in headers if isinstance(h, str) and h.strip()]
        if headers:
            joined = " · ".join(h.strip() for h in headers)
            return shorten("? " + joined)
    return "? question"


def describe_permission(tool_name, tool_input):
    """'! Bash: rm -rf dist' — name the tool and the thing it wants to touch."""
    detail = None
    if tool_name == "Bash":
        detail = tool_input.get("command")
    elif tool_name in ("Edit", "Write", "NotebookEdit", "Read"):
        path = tool_input.get("file_path")
        if isinstance(path, str) and path:
            detail = os.path.basename(path)
    elif tool_name in ("WebFetch", "WebSearch"):
        detail = tool_input.get("url") or tool_input.get("query")
    label = tool_name if isinstance(tool_name, str) and tool_name else "tool"
    if isinstance(detail, str) and detail.strip():
        return shorten("! {}: {}".format(label, " ".join(detail.split())))
    return shorten("! " + label)


def rpc(method, params, want_result=False):
    """One JSON-RPC line over the pane socket. Silent on every failure."""
    socket_path = os.environ.get("HERDR_SOCKET_PATH")
    if not socket_path:
        return None
    request = {
        "id": "{}:{}:{:06d}".format(SOURCE, int(time.time() * 1000),
                                    random.randrange(1_000_000)),
        "method": method,
        "params": params,
    }
    raw = b""
    try:
        client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        client.settimeout(0.5)
        client.connect(socket_path)
        client.sendall((json.dumps(request) + "\n").encode())
        try:
            while b"\n" not in raw:
                chunk = client.recv(4096)
                if not chunk:
                    break
                raw += chunk
        except Exception:
            pass
        client.close()
    except Exception:
        return None
    if not want_result:
        return None
    try:
        return json.loads(raw.split(b"\n", 1)[0].decode())
    except Exception:
        return None


def send(tokens):
    """Display-only sidebar tokens ($task / $why) for this pane."""
    pane_id = os.environ.get("HERDR_PANE_ID")
    if not pane_id:
        return
    rpc("pane.report_metadata", {
        "pane_id": pane_id,
        "source": SOURCE,
        # Nanosecond clock keeps out-of-order hook delivery from letting a
        # stale value overwrite a newer one.
        "seq": time.time_ns(),
        "tokens": tokens,
    })


# ---------------------------------------------------------------------------
# Pane labels.
#
# Claude Code already names its own session and pushes that name out as the
# terminal title -- the same thing you see as a conversation title on
# claude.ai ("Rename herdr panes automatically"). herdr sees it as
# terminal_title but never promotes it to the pane's real `label`, so
# `herdr pane list` shows label=null on every pane and the navigator falls
# back to titles that are four or five words long.
#
# This turns that title into a short sticky label. No extra model call: the
# title IS the model's own name for the session, it just needs cutting down.
#
# Cutting rules, in order:
#   1. strip Claude's leading status glyph (◑ ✳ ·) and punctuation
#   2. drop stop words and weak title-filler ("setup", "support", "behavior")
#   3. drop the cwd basename -- in a herdr workspace every title says "herdr"
#   4. keep the longest prefix of surviving words that fits MAX_LABEL,
#      3 words at most
#
#   'Herdr config plugin setup'         -> config plugin
#   'Border panes indicator color'      -> border panes
#   'Rename herdr panes automatically'  -> rename panes
#   'Herdr floating terminals support'  -> floating terminals
#
# A label you set by hand (prefix+shift+p) always wins: if the live label is
# not the one this hook last wrote, the pane is marked manual in STATE_DIR and
# the hook never touches it again for the life of that pane.
# ---------------------------------------------------------------------------
MAX_LABEL = 22
STATE_DIR = os.path.expanduser("~/.local/state/herdr/claude-pane-labels")
MANUAL = "\0manual"

# Titles that carry no information yet -- do not overwrite a good label with
# these, and do not bother labelling a pane that only shows them.
DEAD_TITLES = {"claude", "claude code", "zsh", "bash", "fish", "nvim", "vim"}

STOP_WORDS = {
    "a", "an", "the", "and", "or", "of", "for", "to", "in", "on", "at", "by",
    "with", "from", "as", "is", "are", "be", "being", "been", "it", "its",
    "this", "that", "these", "those", "not", "no", "do", "does", "did", "how",
    "why", "when", "what", "which", "into", "over", "under", "about", "via",
    "my", "our", "your", "their", "some", "any", "more", "less",
    # weak title filler: present in half the titles, distinguishes none of them
    "setup", "support", "behavior", "behaviour", "usage", "option", "options",
    "issue", "issues", "problem", "problems", "question", "questions", "help",
}


def state_path(pane_id):
    return os.path.join(STATE_DIR, pane_id.replace(":", "_").replace("/", "_"))


def read_state(pane_id):
    try:
        with open(state_path(pane_id), encoding="utf-8") as fh:
            return fh.read()
    except Exception:
        return ""


def write_state(pane_id, value):
    try:
        os.makedirs(STATE_DIR, exist_ok=True)
        with open(state_path(pane_id), "w", encoding="utf-8") as fh:
            fh.write(value)
    except Exception:
        pass


def clear_state(pane_id):
    try:
        os.remove(state_path(pane_id))
    except Exception:
        pass


def short_label(title, cwd):
    """Claude's own session title -> at most two words, at most MAX_LABEL."""
    if not isinstance(title, str):
        return None
    # Claude prefixes the title with a spinner glyph while it is working.
    cleaned = "".join(c if (c.isalnum() or c in " +-_./#") else " "
                      for c in title)
    words = [w for w in cleaned.lower().split() if w]
    if not words or " ".join(words) in DEAD_TITLES:
        return None
    # A shell prompt (aiadmin@host:~/path) is not a session name. Match the
    # shape on the raw title -- cleaning turns it into ordinary-looking words.
    if re.match(r"^\s*\S+@\S+", title):
        return None

    drop = set(STOP_WORDS)
    if isinstance(cwd, str) and cwd:
        drop.add(os.path.basename(cwd.rstrip("/")).lower())
    kept = [w for w in words if w not in drop] or words

    for count in (3, 2, 1):
        candidate = " ".join(kept[:count])
        if len(candidate) <= MAX_LABEL:
            return candidate
    return kept[0][:MAX_LABEL]


def sync_label(clear=False):
    """Keep this pane's label in step with Claude's own name for the session."""
    pane_id = os.environ.get("HERDR_PANE_ID")
    if not pane_id:
        return
    previous = read_state(pane_id)
    if previous == MANUAL:
        return

    reply = rpc("pane.get", {"pane_id": pane_id}, want_result=True)
    pane = ((reply or {}).get("result") or {}).get("pane") or {}
    live = pane.get("label")

    # Someone renamed this pane by hand -- back off permanently.
    if isinstance(live, str) and live.strip() and live != previous:
        write_state(pane_id, MANUAL)
        return

    if clear:
        if previous:
            rpc("pane.rename", {"pane_id": pane_id, "label": None})
            clear_state(pane_id)
        return

    label = short_label(pane.get("terminal_title_stripped")
                        or pane.get("terminal_title"), pane.get("cwd"))
    if not label or label == previous:
        return
    rpc("pane.rename", {"pane_id": pane_id, "label": label})
    write_state(pane_id, label)


def main():
    action = sys.argv[1] if len(sys.argv) > 1 else ""

    # Always drain stdin, even when bailing out, so Claude never blocks on a
    # hook that is not listening.
    raw = ""
    try:
        raw = sys.stdin.read()
    except Exception:
        pass

    if os.environ.get("HERDR_ENV") != "1":
        return
    if not os.environ.get("HERDR_PANE_ID") or not os.environ.get("HERDR_SOCKET_PATH"):
        return

    payload = {}
    try:
        if raw.strip():
            payload = json.loads(raw)
    except Exception:
        payload = {}
    if not isinstance(payload, dict):
        payload = {}

    log_debug(payload, action)

    # A subagent's tool calls are not what the sidebar row is about; letting
    # them write would make the parent pane describe work you cannot see.
    if payload.get("agent_id"):
        return

    tool_input = payload.get("tool_input")
    if not isinstance(tool_input, dict):
        tool_input = {}

    if action == "prompt":
        # New turn: replace the task line and drop any stale blocked reason.
        send({"task": shorten(payload.get("prompt")), "why": None})
    elif action == "question":
        send({"why": describe_question(tool_input)})
    elif action == "permission":
        send({"why": describe_permission(payload.get("tool_name"), tool_input)})
    elif action == "stop":
        # Claude answered, so nothing is waiting on you any more. `task` stays:
        # that is the whole point — it is what reminds you what this pane did.
        send({"why": None})
        # By now Claude has settled on a title for the turn, so this is the
        # cheapest moment to promote it to the pane label.
        sync_label()
    elif action == "end":
        send({"task": None, "why": None})
        # The pane outlives the session and goes back to being a plain shell,
        # so the name has to go with it.
        sync_label(clear=True)
    elif action == "label":
        # Manual/testing entry point: python3 herdr-context.py label < /dev/null
        sync_label()


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
