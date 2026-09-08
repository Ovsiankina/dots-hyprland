#!/usr/bin/env python3
"""Paint a full-width state bar across the bottom of this Claude pane.

herdr's sidebar already colours every agent by state, but it says nothing about
*where* that agent's pane is on screen. This puts the same colour inside the
pane itself, so a glance at the grid locates the agent that wants you without
reading the sidebar and mapping names back to positions.

Both facts come straight from herdr over the pane socket, so the bar cannot
drift from what the sidebar shows:
    pane.get     -> agent_status (working | blocked | idle | unknown)
    pane.layout  -> this pane's width in cells
Colours are read from herdr's own config.toml, so retheming herdr retints the
bar with no change here.

Focus is deliberately NOT encoded. A focus change happens entirely inside herdr
and produces no Claude render, so this script never re-runs to notice it and the
bar would sit on a stale value indefinitely.

Known limit, measured: Claude re-runs the statusline only when it renders, and a
blocked pane renders nothing. `blocked` therefore lands late -- on the next
render, not when the question appears. `working` and `idle` are live.

Wire protocol matches ~/.claude/hooks/herdr-context.py: one JSON-RPC line over
$HERDR_SOCKET_PATH. Every path exits 0; a statusline that fails must never
disturb the session. Set HERDR_BAR_LOG=<path> to trace invocations.
"""

import json
import os
import socket
import sys
import time
import tomllib

CONF = os.path.expanduser("~/.config/herdr/config.toml")
LOG = os.environ.get("HERDR_BAR_LOG")

# herdr's goat — marks the bar as herdr state, not Claude's own output.
MARK = "\U0001f410"
MARK_CELLS = 2          # emoji renders two cells wide but len() counts one

# Used only if config.toml cannot be read; mirrors the committed venommono values.
FALLBACK = {"accent": "#fc302e", "red": "#a855f7", "yellow": "#facc15",
            "green": "#4ade80", "grey": "#5e5e5e"}


def call(method, params):
    """One JSON-RPC line over the pane socket. Raises; caller swallows."""
    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    client.settimeout(1.0)
    client.connect(os.environ["HERDR_SOCKET_PATH"])
    client.sendall((json.dumps({"id": "statusbar", "method": method,
                                "params": params}) + "\n").encode())
    buf = b""
    while b"\n" not in buf:
        chunk = client.recv(65536)
        if not chunk:
            break
        buf += chunk
    client.close()
    return json.loads(buf.split(b"\n")[0]).get("result", {})


def colours():
    """theme.custom is the source of truth; anything unreadable falls back."""
    resolved = dict(FALLBACK)
    try:
        with open(CONF, "rb") as fh:
            custom = tomllib.load(fh).get("theme", {}).get("custom", {})
        for key, token in (("red", "red"), ("yellow", "yellow"),
                           ("green", "green"), ("accent", "accent"),
                           ("grey", "surface_dim")):
            value = custom.get(token)
            if isinstance(value, str):
                resolved[key] = value
    except Exception:
        pass
    return resolved


def sgr(hexcolour):
    h = hexcolour.lstrip("#")
    return "\033[38;2;{};{};{}m".format(
        int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))


def pane_width(pane_id, default=60):
    try:
        for pane in call("pane.layout", {"pane_id": pane_id}) \
                .get("layout", {}).get("panes", []):
            if pane.get("pane_id") == pane_id:
                # rect includes the pane's own border column on each side.
                return max(12, int(pane["rect"]["width"]) - 2)
    except Exception:
        pass
    return default


def main():
    if not os.environ.get("HERDR_PANE_ID") or not os.environ.get("HERDR_SOCKET_PATH"):
        return
    pane_id = os.environ["HERDR_PANE_ID"]

    try:
        status = call("pane.get", {"pane_id": pane_id}) \
            .get("pane", {}).get("agent_status") or "unknown"
    except Exception:
        return

    palette = colours()
    colour, name = {
        "blocked": (palette["red"], "BLOCKED"),
        "working": (palette["yellow"], "WORKING"),
        "idle": (palette["green"], "IDLE"),
    }.get(status, (palette["grey"], status.upper()))

    width = pane_width(pane_id)
    label = " {} {} ".format(MARK, name)
    rule = "─" * max(0, width - (len(label) + MARK_CELLS - 1))

    if LOG:
        try:
            with open(LOG, "a") as fh:
                fh.write("{}  status={:<8} w={}\n".format(
                    time.strftime("%H:%M:%S"), status, width))
        except Exception:
            pass

    sys.stdout.write(sgr(colour) + label + rule + "\033[0m")


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
