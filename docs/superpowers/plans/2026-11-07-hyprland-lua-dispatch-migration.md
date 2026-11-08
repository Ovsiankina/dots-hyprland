# Hyprland 0.57 Lua-dispatch Migration (callers outside hypr/) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every caller that still speaks the pre-0.57 hyprctl/IPC language (hypridle, quickshell `ii`) works again under the Lua-only Hyprland 0.57.1.

**Architecture:** Pure call-site translation, no new modules. Socket `dispatch <X>` is now evaluated as `return hl.dispatch(<X>)`, so `Hyprland.dispatch()` / `hyprctl dispatch` take a Lua dispatcher expression. Option changes (`keyword`, gone: "unknown request") become `hyprctl eval 'hl.config({...})'`. Multi-step batches become one `hyprctl eval` chunk of `hl.dispatch(...)` calls, passed as a positional arg to `sh -c` to avoid quoting.

**Tech Stack:** Hyprland 0.57.1 Lua API, hypridle (hyprlang .conf), Quickshell QML.

**Spec:** Investigation findings in this session (no separate spec doc).

## Global Constraints

- Translation table (each verified live against 0.57.1 on 2026-11-07):
  - `workspace N` → `hl.dsp.focus({ workspace = N })` (relative: `workspace = "r+1"`)
  - `focusmonitor M` → `hl.dsp.focus({ monitor = "M" })`
  - `togglespecialworkspace` → `hl.dsp.workspace.toggle_special()`
  - `focuswindow address:A` → `hl.dsp.focus({ window = "address:A" })`
  - `closewindow address:A` → `hl.dsp.window.close({ window = "address:A" })`
  - `pin address:A` → `hl.dsp.window.pin({ window = "address:A" })`
  - `movetoworkspacesilent N, address:A` → `hl.dsp.window.move({ workspace = N, follow = false, window = "address:A" })`
  - `movewindowpixel exact X% Y%` → `hl.dsp.window.move({ x = PX, y = PY, window = ... })` — **absolute global pixels, no % form**
  - `movecursor X Y` → `hl.dsp.cursor.move({ x = X, y = Y })`
  - `exec CMD` → `hl.dsp.exec_cmd("CMD")`
  - `global NAME` → `hl.dsp.global("NAME")`
  - `dpms on|off` → `hl.dsp.dpms({ action = "on"|"off" })`
  - `keyword a:b v` → `hyprctl eval 'hl.config({ a = { b = v } })'`
  - `keyword animation leaf,1,speed,bezier,style` → `hl.animation({ leaf=, enabled=true, speed=, bezier=, style= })` inside eval
  - `reload` (dispatcher) → `hyprctl reload` (process)
- `hyprctl getoption <bool opt> -j` now returns `{"bool": true}`, not `.int`.
- **Never trigger the lock** while testing (it drops the user to a TTY). Lock paths are verified by syntax/grep only.
- Unknown dispatcher table keys are silently ignored, so "ok" from hyprctl proves nothing; verify by observed state.

## Review Focus

- Window address/monitor names interpolated into Lua strings: use double quotes in Lua; addresses are hex and monitor names `[A-Z0-9-]`, so no escaping needed.
- Overview drag on a floating window: pixel position must be the inverse of `OverviewWidget.qml:206-207` (`at = local/scale + monitor.x + reserved[0]`), else windows jump.
- Lock batch ordering: animation set → focus/workspace per monitor → reload, all sequential (single eval then reload), as before.
- Game mode toggle state on startup must reflect `animations:enabled` correctly after the `.int` → `.bool` change.
- hypridle only re-reads its config on restart.

---

### Task 1: hypridle (idle lock, before/after sleep, DPMS) — security

**Files:** Modify `dots/.config/hypr/hypridle.conf:2,9,20,21`

- [ ] Line 2: `$lock_cmd = hyprctl dispatch 'hl.dsp.global("quickshell:lock")'`
- [ ] Line 9: `after_sleep_cmd = hyprctl dispatch 'hl.dsp.global("quickshell:lockFocus")'`
- [ ] Lines 20/21: `hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'` / `... "on" ...`
- [ ] Verify: `grep -nE "hyprctl dispatch [a-z]" hypridle.conf` → no output; `hyprctl dispatch 'hl.dsp.dpms({ action = "on" })'` → `ok`; restart hypridle under Hyprland (`pkill hypridle; hyprctl dispatch 'hl.dsp.exec_cmd("hypridle")'`), `pgrep hypridle` → a pid. Do NOT run lock_cmd.

### Task 2: Quickshell lock/unlock batches

**Files:** Modify `quickshell/ii/modules/ii/lock/Lock.qml:22-31,46-59`, `quickshell/ii/modules/common/panels/lock/LockScreen.qml:79`

- [ ] Lock.qml: build a Lua chunk string `lua` instead of `batch`. Lock: start with `hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "menu_decel", style = "slidevert" }); `, append per monitor `hl.dispatch(hl.dsp.focus({ monitor = "<mon>" })); hl.dispatch(hl.dsp.focus({ workspace = <2147483647 - ws> })); `. Restore: same per-monitor pair with saved `wsId`, no animation line.
- [ ] Both: `Quickshell.execDetached(["sh", "-c", 'hyprctl eval "$1" && hyprctl reload', "sh", lua])`. Keep the early `return` logic untouched (owned by the lockscreen branch).
- [ ] LockScreen.qml:79: `["bash", "-c", "sleep 0.2; hyprctl eval 'hl.dispatch(hl.dsp.workspace.toggle_special()); hl.dispatch(hl.dsp.workspace.toggle_special())'"]`
- [ ] Verify (no lock): run a lock-shaped chunk for the *current* workspaces through the same `sh -c` form and observe `ok` and unchanged workspaces.

### Task 3: Quickshell `Hyprland.dispatch()` call sites

**Files:** `ii/modules/ii/bar/Workspaces.qml:91,93,103,202`, `ii/modules/ii/overview/Overview.qml:85,88`, `ii/modules/ii/overview/OverviewWidget.qml:145,269,279,287,290`, `ii/modules/waffle/taskView/TaskViewContent.qml:189,295`, `ii/modules/waffle/taskView/TaskViewWindow.qml:65,72,146`, `ii/modules/ii/bar/UtilButtons.qml:110,112`, `ii/modules/ii/sidebarRight/SidebarRightContent.qml:271`, `ii/modules/ii/sidebarLeft/anime/BooruImage.qml:152,154,165,167`, `ii/services/Hyprsunset.qml:168`

- [ ] Translate each per the table. OverviewWidget:279 replaces the % math with
  `x = Math.round((window.x - xOffset) / root.scale + (window.monitor?.x ?? 0) + (window.monitor?.reserved[0] ?? 0))` (y analogous with `[1]`), dispatched as `hl.dsp.window.move({ x, y, window = "address:..." })`.
- [ ] SidebarRightContent:271 → `Quickshell.execDetached(["hyprctl", "reload"])`.
- [ ] BooruImage → `Quickshell.execDetached(["hyprctl", "eval", "hl.config({ cursor = { no_warps = true } })"])` (and `false`).
- [ ] Hyprsunset:168 → delete the bogus dispatch line; the `execDetached` on :169 already does the job.
- [ ] Verify: `grep -rnE 'Hyprland\.dispatch\(["\x60](?!hl\.)' ` (PCRE) → none; each distinct Lua form was already live-tested (see Global Constraints).

### Task 4: Game mode + left-sidebar pin cursor dance

**Files:** `ii/modules/ii/sidebarRight/quickToggles/classicStyle/GameMode.qml:15,24`, `ii/modules/ii/sidebarLeft/SidebarLeft.qml:37,45`

- [ ] GameMode on: `["hyprctl", "eval", "hl.config({ animations = { enabled = false }, decoration = { shadow = { enabled = false }, blur = { enabled = false }, rounding = 0 }, general = { gaps_in = 0, gaps_out = 0, border_size = 1, allow_tearing = true } })"]`; off stays `hyprctl reload`.
- [ ] GameMode state probe: `hyprctl getoption animations:enabled -j | jq -e .bool >/dev/null` (exit 0 = animations on = game mode off; keep `toggled = exitCode !== 0`).
- [ ] SidebarLeft: `hyprctl dispatch 'hl.dsp.cursor.move({ x = 9999, y = 9999 })'` and `... x = ${cursorX}, y = ${cursorY} ...`.
- [ ] Verify: the eval string with current values (no-op) returns `ok`; probe command exits 0 now (animations on).

### Task 5: Sweep + commit

- [ ] `grep -rnE 'hyprctl[^|;&]*\b(dispatch [a-z]|keyword|--batch)'` across `dots/` (excluding comments and `.conf` copies kept for the cheatsheet) → nothing live.
- [ ] `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua` → `config ok`.
- [ ] User restarts quickshell (Ctrl+Super+R or relogin) to load QML changes.
- [ ] Leave uncommitted for user review (commit only on request).
