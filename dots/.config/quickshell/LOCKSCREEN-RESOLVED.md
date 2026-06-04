# Quickshell Lockscreen — RESOLVED (2026-06-04)

**Status: FIXED.** Verified working via `Super+Alt+L` on both tty2 and tty1, repeatedly.
Supersedes `LOCKSCREEN-DEBUG-HANDOFF.md` and `quickshell-lockscreen-issue.md` (kept for history; their rev-1/2/3 theories were all wrong — see "Red herrings" below).

---

## TL;DR

The configured **wallpaper file had been deleted**, leaving `background.wallpaperPath` pointing at a non-existent file. That fed a **null/empty image source** into the background+lock render path. On nvidia, the session-lock surface then failed to paint — so the screen locked with **no password field** (intermittently blank, or a glitched layout that only repainted on mouse hover). The qs process never crashed; this was a *render/presentation* failure, not a process crash.

**Fix:** point the wallpaper at a real file **and** hardcode a guaranteed fallback image so a missing wallpaper can never again produce a null source.

**It was NOT:** the Qt 6.11.0→6.11.1 ABI mismatch, mesa 26.1.1, hyprland 0.55.2, the nvidia driver, the `hyprctl reload` fired during lock, or the `OpacityMask` FBO. All were investigated and refuted.

---

## The bug

### Symptom
- Trigger the qs lock → screen locks but shows **no password field**. Either fully blank/black, or Hyprland's "lockscreen crashed" overlay showing a **glitched layout that only repaints where you hover the mouse**. Nondeterministic — the user described it as "a gamble."
- The **qs process survives** (PID unchanged, no `~/.cache/quickshell/crashes/` report). So the failure is the lock *surface presentation*, not a crash.
- Affected the **nvidia** desktops; the non-nvidia laptop (same synced dotfiles) was fine.
- Onset ≈ 2026-05-21/22.

### Root cause
1. `~/.config/illogical-impulse/config.json` → `background.wallpaperPath` pointed at `…/Pictures/b17b27216852695.682b54889f667.webp`, **a file that no longer existed on disk**.
2. `ii/modules/ii/background/Background.qml` loads that path into an `Image`; the lock's `GaussianBlur` samples that **same** `Image`. Missing file → `Image.status === Error` → effectively a **null texture source**.
3. On nvidia, that null source in the render path stalled/failed the scene-graph render of the `WlSessionLockSurface`. The surface never committed a valid frame → blank/glitched lock while qs kept running. The Intel laptop tolerated the null source (no symptom) — **nvidia was the amplifier, not the cause.**

The "render glitch only revealed on mouse hover" is the tell-tale signature of *frames not being committed* (hover forces a localized repaint), which is what pointed away from a logic/colour bug and toward a render-thread stall.

### Why the "May 22 system upgrade" was a red herring
Three prior debug sessions pinned onset on a 200-package upgrade on 2026-05-22 (mesa/hyprland/nvidia/Qt) and chased GPU/Qt/mesa theories. In reality the **wallpaper went missing around the same date** (the replacement image in `~/Pictures` is dated 2026-05-22 14:04). Same date, unrelated cause. **Correlation is not causation.**

---

## The fix (changes made 2026-06-04)

| # | File | Change |
|---|------|--------|
| 1 | `~/.config/illogical-impulse/config.json` (line 83) | `wallpaperPath` → an image that exists (`…/Pictures/cXtsob…jpg`). |
| 2 | `ii/modules/ii/background/Background.qml` | Added a hardcoded fallback: `fallbackWallpaper` (bundled asset), a `wallpaperLoadFailed` flag set on `Image.Error`, and `effectiveWallpaperPath` that swaps to the fallback. The wallpaper `Image` and the `magick identify` size probe now use `effectiveWallpaperPath`. **Covers both the desktop wallpaper and the lock blur** (they share the same `Image`), so a missing/failed wallpaper can never again produce a null source. |
| 3 | `ii/assets/images/fallback_wallpaper.jpg` | Bundled dark-gradient fallback image (generated with `magick`, committed to the repo, always present). |
| 4 | `~/.config/hypr/hyprland/keybinds.conf` (line 278) | `Super+Alt+L` → `exec, hyprctl dispatch global quickshell:lock` (fire the qs lock directly). |

### Remaining optional cleanup (not yet done)
- `~/.config/hypr/hypridle.conf` still uses the **hyprlock fallback** for idle-timeout and `loginctl lock-session`. To fully retire hyprlock, flip `$lock_cmd` back to the qs-lock trigger.
- Commit all of the above (config.json, Background.qml, the fallback asset, keybinds.conf).

### Verification
`Super+Alt+L` → qs lock appears with the password field over a blurred wallpaper, accepts the password, unlocks cleanly. Repeated several times on tty2 **and** tty1 — consistent, no longer "a gamble."

---

## Methodology — reusable debugging pattern

This saga took multiple sessions because early work latched onto a plausible-but-wrong lead (nvidia GPU stack / Qt regression) and never validated it. The pattern below is what finally cracked it, and generalises to any hard, environment-specific, intermittent bug.

### 1. Establish ground truth before theorising
Don't reason from indirect signals. "qs process is alive" ≠ "the lock worked." "`hyprctl layers` shows no lock layer" proves nothing if that tool doesn't even enumerate the surface type. Pin down *what is actually on screen* and *what the process actually did* first.

### 2. Confirm state by direct observation — never infer it
The single highest-leverage move here was asking the user three precise "what do you actually see?" questions (is the wallpaper showing? blank or glitched? do colours look right?). Their answers (black desktop everywhere, theme colours intact, glitch-revealed-on-hover) eliminated whole branches in one round. When you catch yourself *assuming* a state, stop and verify it instead.

### 3. Isolation protocol — one variable per experiment
Instead of debugging the giant real config in place, write a **tiny standalone reproducer** containing exactly one suspect feature, run it, observe ✅/✅. Start from a known-good baseline, change exactly **one** thing, and rerun. Each result is information either way: a pass *exonerates* that feature, a fail *names* it. Here: bare lock primitive ✅, opaque surface ✅, transparent surface ✅, OpacityMask FBO ✅, `hyprctl reload` mid-lock ✅, full faithful combo ✅ — every isolated suspect passed, which is precisely what forced attention onto "what does the full shell have that none of these do."

### 4. Each passing test is a deleted hypothesis
Treat the suspect list as a set to shrink. The value of a test that *passes* is that it permanently removes a theory. Six green isolation tests collapsed a huge suspect space down to "something only the full shell loads" → the background blur → the logs → the missing wallpaper.

### 5. Read the actual logs, at the right verbosity
The fix came from one line in a plain-verbosity foreground capture: `Background.qml: Cannot open file://…wallpaper.webp`. Note also the trap recorded here: **verbose logging can introduce its own bug** (`quickshell.*=true` segfaulted qs's own log formatter and masked the real behaviour). Capture at default verbosity first; only escalate deliberately.

### 6. Distrust correlation, especially dates
A dramatic, well-documented event (the 200-package upgrade) sitting on the onset date is seductive and was wrong. Always look for an *independent* change that coincides (here: a deleted file with the same timestamp). Ask "what else changed then?" before committing to the obvious correlate.

### 7. Separate proven facts from inferred mechanisms — and fix the proven thing
Proven: wallpaper missing → lock broken; wallpaper present → lock works. *Inferred:* the exact GPU mechanism (the blur shader stalling). The user rightly pushed back on overclaiming the mechanism. The fix targets the **proven** failure mode (a null image source) with a fallback, which is correct regardless of which downstream code chokes on the null — so the fix is robust even though the precise GPU stall path was never instrumented to proof.

### 8. Make test harnesses self-clearing and safe
Lock testing is lockout-prone. Rules that mattered: never test on the primary session (tty1) until verified; build reproducers that **auto-unlock after a timeout** so a misfire can't trap the session; know the real recovery (kill the lock *client* leaves the compositor locked → `loginctl terminate-session`, not `pkill`); put a big on-screen label on each test so you always know which variant is running.

### 9. Build-up bisection when single variables all pass
When every isolated feature is individually fine but the real thing breaks, the cause is a *combination* or a piece you haven't isolated. Build up from the known-good baseline toward the real artefact, adding pieces until it breaks (or strip down from the broken real artefact until it works). That transition is the culprit boundary.

### 10. Fix forward with a guard, not just a patch
The minimal fix was "set a valid wallpaper." The durable fix adds a **fallback** so the failure class (null source) is structurally impossible going forward. Prefer the guard that makes the whole category of bug non-recurring over the one-off correction.
