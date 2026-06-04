> ✅ **RESOLVED 2026-06-04 — see `LOCKSCREEN-RESOLVED.md`.** Root cause was a **deleted wallpaper file** → null image source → lock surface failed to render on nvidia. NOT the Qt/mesa/hyprland/nvidia/reload/FBO theories explored below (all refuted). This document is kept for history only; everything below is superseded.

# Quickshell Lockscreen — Debug Handoff (rev 3, 2026-06-03 evening)

**Companion:** `quickshell-lockscreen-issue.md` (original symptom report — read first).
**Status (rev 3):** Big reframe. The qs **process does NOT crash** on the real lock — it **survives**; what fails is the lock **surface presentation** (Hyprland then shows its "lockscreen crashed" overlay → user trapped). The bare `WlSessionLock` primitive works on nvidia real DRM in **both opaque AND transparent** form (tested today). So the bug is **inside what the full `ii` lock loads/does**, NOT the primitive, NOT transparency, NOT a Qt ABI issue, NOT the "nvidia GPU stack" in general. **New prime suspects (narrowed today):** (A) `LockSurface.qml:163` `layer.enabled:true` + `layer.effect: OpacityMask` (Qt5Compat FBO/ShaderEffect rendered into a session-lock surface), (B) `Lock.qml:47-59` runs `hyprctl --batch …; reload` *during* lock. **Read the "REV 3" section next — it corrects several rev-2 claims.**

> ⚠️ **rev-2 below is preserved but partly WRONG.** rev-2 repeatedly says "qs dies building the lock surface on real DRM" and treats a captured SIGSEGV as the lock crash. That SIGSEGV was an **artifact of my own verbose logging** (a use-after-free in quickshell's offthread logger, `logging.cpp:131`), not the lock bug. Where rev-2 conflicts with REV 3, **REV 3 wins.** Corrections are annotated inline as **[rev3: …]**.

---

## ⛔ HARD SAFETY RULES (unchanged — read before doing anything)

1. **NEVER lock tty1.** User works on tty1 ALWAYS. The qs lock is broken → any real qs lock on a session you can't escape = lockout. All lock testing on **tty2+** only.
2. **DO NOT run a second real-DRM compositor while tty1 is live.** One nvidia GPU; starting `Hyprland` on another tty can steal DRM master and crash tty1's GPU apps. Test only as the *sole* graphical session, or via the safe hyprlock fallback (now in place).
3. The **hyprlock fallback is currently ACTIVE** (see "Current state"), so idle/`Super+Alt+L` are safe right now. Keep it until the qs lock is verified fixed on tty2.

---

## ★ REV 3 — corrected understanding + today's evening findings (READ THIS FIRST)

### What the failure actually is (corrected)
- The **qs process SURVIVES the real lock.** Proof: `lock-crash-real.sh` dispatched `quickshell:lock` at the session's own qs; the qs **pid was unchanged** before/after, and **no quickshell crash report** was written. The bar/process lived.
- What breaks is the **lock SURFACE presentation**: qs enters lock, Hyprland can't get a valid lock surface for all outputs, so Hyprland shows its built-in **"lockscreen crashed"** overlay and keeps the session locked → **user trapped, no password field** (exactly the original symptom). The user confirmed seeing the Hyprland crash overlay, NOT a qs crash dialog, in the clean run.
- ⇒ rev-2's whole "qs dies building the surface on real DRM" framing is **wrong**. It was built on a SIGSEGV that my instrumentation caused (see below).

### The SIGSEGV I "found" was self-inflicted (important trap to avoid)
- My first instrumented run (`capture-lock-death.sh`, crash dir `~/.cache/quickshell/crashes/jrgd1r82gt`) DID segfault qs — but the stacktrace is in **quickshell's own logger**: `qs::log::LogMessage::formatMessage` → `QLatin1String::operator==` at `logging.cpp:131` (`if (msg.category == "quickshell.bare")`). The `msg.category` QLatin1String had a **dangling pointer** = a **use-after-free / race in quickshell's offthread logger** under high log volume.
- I triggered it with `QT_LOGGING_RULES="…;quickshell.*=true"` + `QSG_INFO=1`. It crashed during normal **startup** (log tail shows UPower/pipewire/background, no lock activity), ~10s in, *before the lock mattered*.
- **Lesson: never enable verbose quickshell/qt logging on this build to debug the lock — it crashes qs by itself and masks the real behavior.** (Also worth reporting upstream as a genuine logging bug, independent of the lock.)

### What is now CONFIRMED by clean tests (tty2, real nvidia DRM)
1. **Bare `WlSessionLock` with an OPAQUE surface → WORKS.** `minimal-lock.qml` (color `#1e1e2e`, centered text) rendered perfectly; user saw the text. ⇒ the WlSessionLock primitive + nvidia DRM presentation are fine.
2. **Bare `WlSessionLock` with a TRANSPARENT surface → ALSO WORKS.** `minimal-lock-transparent.qml` (color `"transparent"`, small centered content like the ii lock) rendered fine; user saw the text. ⇒ **transparency is NOT the bug** (this refutes the rev-1/rev-2 suspicion *and* the original quickshell-docs "transparent surfaces get rejected" theory for THIS compositor).
3. Both worked **dual-monitor** (tty2 had two outputs) → multi-output lock-surface creation is fine.
4. The full **ii lock wedges** (surface fails, Hyprland lock-crashed overlay) while qs survives.

⇒ **The bug lives in what the full `ii` lock adds on top of a bare surface**, not in the primitive/transparency/GPU-stack-in-general.

### New PRIME suspects (narrowed, specific, testable)
- **(A) FBO/layer effect in the lock surface.** `ii/modules/ii/lock/LockSurface.qml:163-164`: `layer.enabled: true` + `layer.effect: OpacityMask {…}` (from `Qt5Compat.GraphicalEffects`, on the password box mask). `layer.enabled` allocates an FBO/ShaderEffectSource; `OpacityMask` is a ShaderEffect. Rendering an FBO-backed effect **into an ext-session-lock surface** is the kind of thing that can fail on nvidia where the same effect in a layer-shell surface (the bar) works. The minimal tests had **no** layer effects → worked. **Top suspect.**
- **(B) `hyprctl … reload` fired during lock.** `ii/modules/ii/lock/Lock.qml:47-59`: on `screenLocked`, qs runs one big `hyprctl --batch "keyword animation …; dispatch focusmonitor …; dispatch workspace …; … reload"`. A compositor **config reload in the middle of entering session-lock** could disrupt/destroy the lock surface. The minimal tests don't touch hyprctl. **Second suspect.**
- (C) Other ii LockSurface content: `Qt5Compat.GraphicalEffects` import generally, MaterialSymbol font rendering, UPower/SystemTray bindings, PAM. Lower priority than A/B.

### Things now REFUTED today (in addition to rev-2's list)
- ❌ "qs process dies/crashes on the lock" — it **survives** (pid unchanged, no crash report).
- ❌ "transparent lock surface is rejected on nvidia" — transparent minimal lock **works**.
- ❌ "the WlSessionLock primitive / nvidia DRM presentation is broken" — opaque+transparent minimal both **work**.
- ❌ "atomic DRM commit `Permission denied` (EACCES) is the cause" — it's **normal background-VT noise** (tty1, the healthy primary session, logs it **66×**; it's just an inactive-VT compositor failing to page-flip, immediately followed by `Restoring crtc` on VT-regain). Do **not** chase it.
- ❌ "the `nvidia GPU render path` is the lead" (rev-2's primary lead) — the GPU render path works (bar renders; minimal lock renders; `qt.rhi` showed a healthy OpenGL/`NVIDIA T1000` context + swapchain). Demoted.

### Also learned
- **This box is hybrid GPU**, not pure nvidia: crash report lists `renderD129 nvidia (10de:1ff0, T1000)` **and** `renderD128 i915 Intel`. Multi-GPU/PRIME may matter for FBO/layer handling (suspect A).
- **quickshell has a built-in crash handler** → on a real *process* crash it writes `~/.cache/quickshell/crashes/<id>/report.txt` (full stacktrace + log tail) and `log.qslog.log`. The rev-1 "traceless death" was wrong — they only checked `coredumpctl`. BUT the real lock failure leaves **no** report precisely because qs does **not** crash.

### Recommended next steps (rev 3, ordered) — supersedes rev-2's list
1. **Capture the full-ii-lock behavior cleanly** (we never actually ran this): `lock-foreground.sh` on tty2 — single instance, **default** verbosity (NOT the crashing verbose rules), output tee'd to `~/locktest-out/fg-*.log`. Dispatch the lock from another pane (`hyprctl dispatch global quickshell:lock`). Read qs's stderr WARN/ERROR when the surface wedges. (Use tmux so output persists across the lock; the file persists regardless.)
2. **Test suspect (A):** copy the ii lock minimally, or edit `LockSurface.qml:163` to `layer.enabled: false` (temporarily), test the real lock on tty2. If it then works → the FBO/OpacityMask is the trigger; fix = avoid `layer.effect`/`Qt5Compat.GraphicalEffects` in the lock surface (use a different rounded-mask approach, e.g. `Rectangle` clip or `MultiEffect`).
3. **Test suspect (B):** in `Lock.qml`, drop the trailing `reload` from the lock `--batch` (or remove the keyword/animation change), test. If it works → the mid-lock `reload` is the trigger.
4. **Build-up bisection:** start from `minimal-lock.qml` (known good) and add ii LockSurface pieces until it breaks — definitive isolation.
5. **Capture Hyprland's own debug log** during a full-lock wedge (Hyprland debug logging, NOT qs logging) to see why it declares the lock crashed — it's compositor-side and risk-free.

### Current state at end of rev-3 session (2026-06-03 evening)
- **hyprlock fallback still ACTIVE & safe** on tty1 (unchanged). qs lock still effectively broken (full ii lock wedges).
- tty1 untouched/healthy (qs `526527`, hypridle vt1). All stray tty2 test sessions `loginctl terminate-session`'d — only tty1 + manager remain.
- New harness files added (see Appendix B): `lock-crash-real.sh`, `lock-foreground.sh`, `minimal-lock.qml` (opaque, **good**), `minimal-lock-transparent.qml` (**good**), `drive-capture.sh`/`capture-lock-death.sh` (⚠️ verbose-logging ones — they crash qs via the logger bug; keep only for the backend-discriminator idea, and even then drop `quickshell.*=true`).

---

## TL;DR (what changed this session)  *(rev-2 — see REV 3 above for corrections)*

- **Confirmed the Qt 6.11.0→6.11.1 ABI mismatch was real**, rebuilt qs against 6.11.1, installed, restarted qs (running clean, `--private-check-compat` exit 0). **Then tested the qs lock on tty2 → it STILL crashed, identical symptom.** ⇒ **#1 is NOT the root cause.** (Rebuild was still mandatory hygiene + a precondition for trustworthy logs.) **[rev3: the "still crashed" test here was muddied by 2nd-instance + verbose-logging artifacts; the clean conclusion is the lock SURFACE wedges while qs survives.]**
- **Found the true onset trigger:** a **200-package upgrade on 2026-05-22** (`/var/log/pacman.log`), matching the user's "~May 21" onset. The old handoff's "Qt bumped May 26" was wrong (it inferred from shader-cache dir dates; pacman.log is authoritative: Qt 6.11.1 landed **May 22**, same batch as everything else).
- **The qs binary did NOT change at onset** — `illogical-impulse-quickshell-git 0.1.0.r1-6` was installed **Apr 15** and only *reinstalled* today. So the trigger is a *system* change on May 22, not a qs/config change.
- **Cross-machine logic still isolates nvidia.** Both nvidia desktops got the May 22 batch → crash. The non-nvidia laptop got the same synced batch → fine. ⇒ culprit ∈ the **nvidia-specific** parts of the May 22 batch.
- **Corrected a stale handoff claim:** `allow_session_lock_restore` / `session_lock_xray` ARE correctly inside the `misc {}` block (general.conf line 136 opens `misc {`, options at 147–148), and `hyprctl getoption misc:*` shows `set: true`. No config fix needed there. (Old handoff said they were misplaced under `general` — false.)

---

## The May 22 upgrade batch — the real onset (evidence)

`/var/log/pacman.log` 2026-05-22 11:51 — 200 packages upgraded. The nvidia/render-relevant ones:

| Package | From → To | Why it matters |
|---|---|---|
| **mesa** | 26.0.6 → 26.1.1 | GL/Vulkan userspace — the RHI render path |
| **hyprland** | 0.55.0 → **0.55.2** | compositor: session-lock handling, explicit sync, aquamarine backend |
| **nvidia-open** | 595.71.05-5 → **-10** | kernel module rebuilt (for new kernel) |
| **linux** | 7.0.5 → **7.0.9** | new kernel → nvidia module rebuild |
| vulkan-icd-loader / vulkan-headers / glslang | 1.4.341 → **1.4.350** | Vulkan RHI path on nvidia |
| qt6-base & friends | 6.11.0 → 6.11.1 | **already refuted as the cause** (rebuilt, still crashes) |
| qt6-shadertools | 6.11.0 → 6.11.1 | shader compile for RHI |

**Suspect set (post-Qt-refutation):** `{ mesa 26.1.1, hyprland 0.55.2, nvidia-open -10 / kernel 7.0.9, vulkan stack 1.4.350 }`.

---

## Why I concluded #1 (Qt ABI mismatch) is NOT the root cause

Direct disproof, not inference:
1. `qs --private-check-compat` → **exit 1**, "built against 6.11.0, system 6.11.1". Mismatch confirmed present.
2. `makepkg -f` rebuild of the pinned PKGBUILD against current Qt → built binary `--private-check-compat` **exit 0**.
3. `sudo pacman -U` the rebuilt pkg → installed binary **exit 0** (warning gone).
4. User restarted qs → `/proc/<pid>/exe` no longer `(deleted)`, fresh pid, compat exit 0 = **definitely running the rebuilt binary**.
5. **qs lock tested on tty2 → still crashes, same symptom.**

If the ABI mismatch were the cause, step 5 would pass. It didn't. QED.

**Important nuance (don't overclaim):** the rebuild refutes "**ABI mismatch**" specifically. It does **not** by itself refute "a genuine **Qt 6.11.1 RHI code regression** on nvidia" — rebuilding only fixes ABI, the Qt *code* is identical 6.11.1 either way. That sub-hypothesis is folded into "the May 22 batch / nvidia render path" below and will be settled by capturing the death cause.

---

## Why the nvidia-GPU-render path is the right primary lead (and the counter-arguments)

**For it:**
- **Cross-machine controlled comparison.** Qt/mesa/hyprland/vulkan all upgraded on the laptop too (same synced system), yet only the **nvidia** desktops crash. nvidia is the single variable that tracks crash-vs-works. The May 22 batch's nvidia-touching pieces (mesa nvidia path, nvidia module rebuild, vulkan-on-nvidia, hyprland nvidia render) are the intersection.
- **The death location.** qs dies exactly when it **builds the `WlSessionLockSurface` on the real DRM path** — i.e. creating a *new GPU surface/swapchain per output*. That is precisely where nvidia userspace/driver/compositor bugs bite. Nested (Wayland backend, no real DRM) survived last session → the real-DRM presentation path is required to reproduce.
- **Traceless, SIGKILL-like death with no Qt-level error** is consistent with a lower-level (driver/compositor/DRM) abort rather than a QML logic error.

**Against it / steelman the alternatives (so the next session stays honest):**
- **It could be hyprland 0.55.2's session-lock protocol/explicit-sync handling**, not qs's GPU code per se. That still correlates with "nvidia" *if* hyprland's lock path differs by GPU (it does, via explicit sync). So "nvidia GPU render in qs" vs "hyprland lock handling on nvidia" both fit the data. **Only the captured death cause distinguishes them.**
- **It could be a Qt 6.11.1 RHI regression** that only manifests on nvidia (see nuance above) — not excluded by the rebuild.
- **mesa 26.1.1** alone (GL/Vulkan userspace) is a strong single-package suspect and the cheapest to bisect.

⇒ The lead is **"the WlSessionLockSurface GPU presentation fails on nvidia after May 22"**; *which component* (qs/Qt RHI vs mesa vs hyprland vs driver) is still open and is answered by step 1 below.

---

## Re-evaluated priority (next steps, ordered)

### 1. CAPTURE THE DEATH CAUSE (keystone — do this first, it's cheap & safe) ⭐
The whole investigation is blocked on the "traceless death." Turn it into a concrete error. Harness is ready in `locktest-harness/` (persistent, survives reboot — unlike old `/tmp` scripts).

On **tty2** (sole graphical session is safest; or just a second tty since the lock will be qs's own, escapable by VT-switch):
```bash
cd ~/.config/quickshell/locktest-harness
./capture-lock-death.sh            # default RHI; launches qs, logs RHI/scenegraph/qpa
# then from another shell on the SAME session:
hyprctl dispatch global quickshell:lock
```
Read the printed log. Expected discriminators in the output:
- `qt.rhi` swapchain/Vulkan/GL **create failure** → GPU render path (qs/Qt/mesa/driver).
- `wl_` / protocol error → hyprland session-lock protocol.
- a clean qFatal/assert → Qt logic.
- nothing + `SIGNAL 9/11` → driver/compositor abort (check `dmesg | grep -iE 'nvidia|Xid|drm'` right after).

### 2. BACKEND DISCRIMINATORS (cheap env toggles, same harness)
Run each, lock, observe survive/die:
```bash
./capture-lock-death.sh software   # QT_QUICK_BACKEND=software — survives ⇒ GPU render path
./capture-lock-death.sh opengl     # QSG_RHI_BACKEND=opengl
./capture-lock-death.sh vulkan     # QSG_RHI_BACKEND=vulkan
```
- software survives, GPU dies ⇒ render-path confirmed; if one of GL/Vulkan survives and the other dies ⇒ you have a **working workaround** (pin that RHI backend via env in the qs launch).

### 3. ISOLATE qs-config vs the WlSessionLock PRIMITIVE
```bash
qs -p ~/.config/quickshell/locktest-harness/minimal-lock.qml   # on tty2
```
- minimal crashes too ⇒ bug in WlSessionLock/Qt-RHI on nvidia (not the ii lock QML).
- minimal survives, full `ii` lock dies ⇒ bug in what the ii lock loads (PAM widget, per-monitor surfaces, blur) — bisect the ii LockSurface.

### 4. COMPONENT BISECT (heavier — only if 1–3 don't pinpoint)
Downgrade May 22 suspects one at a time on a test session, test lock each time (Arch cache in `/var/cache/pacman/pkg/`):
order by suspicion/cheapness: **mesa** → **hyprland** → **vulkan stack** → **nvidia-open/kernel**.
```bash
sudo pacman -U /var/cache/pacman/pkg/mesa-1:26.0.6-1-x86_64.pkg.tar.zst   # example; verify exact file
```

### 5. nvidia explicit-sync / compositor knobs (parallel cheap try)
Hyprland #7230 fix was `render { explicit_sync = false }` but that key was renamed in 0.55.2. Check current knobs:
```bash
hyprctl getoption render:explicit_sync_kms
```
Also try aquamarine env on the test session: `AQ_NO_ATOMIC=1`, `AQ_MGPU_NO_EXPLICIT=1`. nvidia env worth a shot: `__GL_VRR_ALLOWED=0`, `GBM_BACKEND=nvidia-drm`, `__GLX_VENDOR_LIBRARY_NAME=nvidia`.

### 6. Upstream check
Search end-4/dots-hyprland + quickshell issues for: `WlSessionLock nvidia crash`, `mesa 26.1 lock`, `hyprland 0.55.2 session_lock nvidia`, `Qt 6.11.1 rhi nvidia`. The pin is `7511545e`; bumping it is only useful if upstream has a post-7511545e nvidia-lock fix (re-check; last session it was identical).

### 7. Make the recurrence impossible (hygiene, independent of the fix)
`quickshell-check.hook` only **warns** on qt6 upgrades (`Exec=/usr/bin/quickshell --private-check-compat`, no abort) — that's why the mismatch slid in silently. Make it **loud/abort** or auto-rebuild. (Lower priority — it wasn't the root cause, but it's real debt.) Path: `~/dotfiles/.installation/arch-packages/illogical-impulse/ii-quickshell-git/quickshell-check.hook`.

---

## CONFIRMED this session (with evidence)
1. Qt ABI mismatch present, then removed by rebuild — **lock still crashes** (the central new fact).
2. Onset = **May 22 200-pkg batch** (`pacman.log`), not May 26; qs binary unchanged since **Apr 15**.
3. hyprlock fallback works (user saw/unlocked it: black bg + working pwd field — that's hyprlock, expected, NOT a broken qs lock).
4. `misc:allow_session_lock_restore` & `misc:session_lock_xray` both `set: true`, correctly placed.

## REFUTED
- ❌ Qt 6.11.0↔6.11.1 **ABI mismatch** as the cause (rebuilt + still crashes).
- ❌ "Qt bumped May 26" (it was May 22 — pacman.log).
- ❌ "session-lock options misplaced under `general`" (they're correctly in `misc {}`).
- ❌ (carried from rev 1) transparent-surface color as the bug; bumping the pinned commit.

---

## Environment (verified today)
| Thing | Value |
|---|---|
| qs pkg | `illogical-impulse-quickshell-git 0.1.0.r1-6` (installed Apr 15, rebuilt+reinstalled today) |
| qs binary | `Quickshell 0.2.1 (rev 7511545e, DISTRIBUTOR "AUR (package: quickshell-git)")` |
| qs built-against Qt | **6.11.1 now** (was 6.11.0; `--private-check-compat` exit 0) |
| System Qt | 6.11.1-1 |
| mesa | **26.1.1** (was 26.0.6 pre-May-22) |
| Hyprland | **0.55.2** (was 0.55.0 pre-May-22), commit 39d7e209 |
| nvidia | nvidia-open **595.71.05-10**, nvidia-utils 595.71.05-2, kernel **7.0.9** |
| Monitors | DP-6, DP-7 (dual) |
| PKGBUILD | `~/dotfiles/.installation/arch-packages/illogical-impulse/ii-quickshell-git/PKGBUILD` (pin `7511545e`, pkgrel 6) |

## Current system state at end of session (2026-06-03 ~16:33)
- **Lock = hyprlock fallback, ACTIVE & safe.** `~/.config/hypr/hypridle.conf` line 2: `$lock_cmd = pidof hyprlock || hyprlock` (qs-lock line kept commented below it). The user **accepts hyprlock for now** until the qs lock is fixed.
- **One** hypridle on tty1 (vt1), **one** Hyprland (tty1). Stray test sessions tty2/tty3 were `loginctl terminate-session`'d — clean.
- qs running = rebuilt 6.11.1 binary, fresh pid, healthy.
- Harness in `~/.config/quickshell/locktest-harness/` (persistent): `capture-lock-death.sh`, `minimal-lock.qml`.

---

## Lock architecture (file map — unchanged, still accurate)
- **Trigger:** `Super+Alt+L` → `~/.config/hypr/hyprland/keybinds.conf` line 278: `bindd = SUPER+ALT, L, Lock, exec, loginctl lock-session`.
- **logind → hypridle:** `~/.config/hypr/hypridle.conf` `general.lock_cmd = $lock_cmd`; idle listener at 300s also calls `loginctl lock-session`. hypridle catches the logind Lock signal and runs `$lock_cmd`. (Currently → hyprlock.)
- **qs side (config dir `ii`):**
  - `ii/modules/ii/lock/Lock.qml` — moves each monitor's workspace away (the "windows fly to the bottom"), registers `GlobalShortcut{name:"lock"}` + IPC `lock.activate`.
  - `ii/modules/common/panels/lock/LockScreen.qml` — core: `WlSessionLock{ locked: GlobalStates.screenLocked }` + `WlSessionLockSurface{ color:"transparent"; Loader{...lockSurface} }`. **[rev3: NOT where it dies — qs survives; a bare version of this exact surface works opaque AND transparent. The failure is in the `lockSurface` content the Loader pulls in (LockSurface.qml), prime suspect its `layer.enabled`+OpacityMask at line 163.]**
  - `ii/modules/ii/lock/LockSurface.qml` — visible UI (pwd box, toolbars).
  - `ii/modules/common/panels/lock/LockContext.qml` — PAM auth.
- The blur+clock "behind" the lock is Hyprland `session_lock_xray` + `decoration:blur{xray}` showing the desktop through the (transparent) lock surface — NOT drawn by qs.

---

## APPENDIX A — Debug commands that WORKED WELL this session (reuse these)

**Prove the qs binary in memory vs on disk (catch "I reloaded but it's still old"):**
```bash
PID=$(pidof qs quickshell | awk '{print $1}')
ls -l /proc/$PID/exe          # "...(deleted)" = process still on OLD binary; needs real restart, not config reload
ps -o pid,lstart,cmd -p $PID  # start time changed? = real restart happened
/usr/bin/quickshell --private-check-compat; echo "exit=$?"   # exit 0 = Qt ABI OK
```

**Find the true onset by mining pacman.log (this cracked the timeline):**
```bash
awk '/2026-05-2[0-4]/ && /upgraded/' /var/log/pacman.log | grep -iE "nvidia|mesa|hyprland|qt6|vulkan|linux |libdrm"
grep -iE "quickshell" /var/log/pacman.log | grep -iE "installed|upgraded"   # proved binary unchanged at onset
```

**Map every Hyprland/hypridle to its tty/VT (untangle multi-session messes safely):**
```bash
for hp in $(pgrep -x Hyprland); do echo "pid=$hp tty=$(ps -o tty= -p $hp) vt=$(tr '\0' '\n' </proc/$hp/environ 2>/dev/null|grep XDG_VTNR|cut -d= -f2)"; done
for p in $(pidof hypridle); do echo "$p vt=$(tr '\0' '\n' </proc/$p/environ 2>/dev/null|grep XDG_VTNR|cut -d= -f2)"; done
loginctl list-sessions          # session#→tty; loginctl terminate-session N to clean strays
echo "$WAYLAND_DISPLAY $XDG_VTNR $HYPRLAND_INSTANCE_SIGNATURE"   # which compositor THIS shell drives
hyprctl version | head -1       # confirm hyprctl talks to the intended (tty1) instance via its commit hash
```

**Verify which block a hypr option really sits in + whether it's applied:**
```bash
awk 'NR<=148 && /\{/{h=NR": "$0} END{print h}' ~/.config/hypr/hyprland/general.conf   # nearest enclosing block
hyprctl getoption misc:allow_session_lock_restore     # set:true = applied; "no such option" = wrong section/renamed
```

**Restart hypridle safely (reload lock_cmd WITHOUT locking):**
```bash
pkill -x hypridle; setsid hypridle >/dev/null 2>&1 </dev/null & disown   # killing/restarting hypridle does NOT lock
```
⚠️ Note: Hyprland's `--watchdog-fd` parent **respawns** its exec-once hypridle child — so a stray session's hypridle keeps coming back until you terminate the whole session.

**Rebuild + install the pinned qs (non-disruptive; does NOT kill the running qs):**
```bash
cd ~/dotfiles/.installation/arch-packages/illogical-impulse/ii-quickshell-git
rm -rf src pkg *.pkg.tar.zst; makepkg -f          # build only, no sudo, compile against current Qt
sudo pacman -U --noconfirm illogical-impulse-quickshell-git-*-x86_64.pkg.tar.zst
# new binary active only after a REAL qs restart: pkill -x qs; qs -c ii & disown  (flickers the bar; user's call)
```

## APPENDIX B — harness files (in `locktest-harness/`, persistent)
- `minimal-lock.qml` — bare `WlSessionLock` + **opaque** colored rect. **[rev3: CONFIRMED WORKS on nvidia.]** Run: `qs -p minimal-lock.qml` on tty2.
- `minimal-lock-transparent.qml` — bare `WlSessionLock` + **transparent** surface + small content. **[rev3: CONFIRMED WORKS on nvidia → transparency is not the bug.]**
- `lock-crash-real.sh` — **[rev3: the good one]** dispatches the lock at the **session's own** qs (no 2nd instance, **no** verbose logging), then reports pid-changed?/new-crash-report?/dmesg. Proved qs survives.
- `lock-foreground.sh` — runs ONE qs in the foreground (kills only this-VT's qs first; **default** verbosity), output tee'd to `~/locktest-out/fg-*.log`. For the rev-3 step-1 clean full-lock capture (use in tmux). 
- `capture-lock-death.sh` / `drive-capture.sh [default|software|opengl|vulkan]` — ⚠️ **these enable `QT_LOGGING_RULES=…quickshell.*=true` which SEGFAULTS qs in its own logger (`logging.cpp:131`) — they do NOT measure the lock bug.** Keep only for the GPU-backend-discriminator idea, and if reused, **delete `quickshell.*=true`** from the rules first.

## APPENDIX D — the isolation protocol (`qs -p <file>`) — USE THIS, it's fast & decisive

The single most productive method this session. Instead of debugging the giant `ii` config in place, write a **tiny standalone `.qml`** that contains **only** the one feature you want to test, run it directly with `qs -p <file>`, and observe. Each file is a controlled experiment: one variable changed vs the last known-good file. This is what proved (in ~3 quick runs) that the primitive works, opaque works, and transparent works — collapsing a huge suspect space fast.

### Why it works
- `qs -p /path/to/file.qml` runs that file as a complete, self-contained shell — **no `ii` config, no services, no PAM, no bar** loaded. So anything that breaks is caused by *what's in your file*, nothing else.
- You add ONE thing at a time. Known-good file + one change → if it now breaks, that one change is the cause. If it still works, that feature is exonerated. Either outcome is information.
- It's **safe**: a standalone `WlSessionLock{ locked:true }` is escapable by VT-switch (no PAM needed); if it wedges, you terminate the test session — your real config is untouched.

### The loop
1. **Start from known-good.** Here: `minimal-lock.qml` (bare opaque `WlSessionLock` + a colored `Rectangle` + `Text`). Confirm it still works.
2. **Form ONE hypothesis** ("transparency breaks it", "the OpacityMask layer breaks it", "MaterialSymbol breaks it").
3. **Copy the good file, change exactly ONE thing** to embody that hypothesis. Name it for the hypothesis (`minimal-lock-transparent.qml`, `minimal-lock-layereffect.qml`, …).
4. **Run on tty2+ (NEVER tty1):** `qs -p ~/.config/quickshell/locktest-harness/<file>.qml`
5. **Observe the screen:** the test rect/text **visible** = that feature is fine (✅, this file becomes the new baseline). Hyprland **"lockscreen crashed"** overlay / black / no text = that feature is the trigger (❌, root cause found).
6. `Ctrl+Alt+F1` back to tty1; if the session wedged, `loginctl terminate-session <tty2's #>`. Record ✅/❌. Go to 2 with the next hypothesis.

### Template (copy, change one line)
```qml
import QtQuick
import Quickshell
import Quickshell.Wayland
ShellRoot {
    WlSessionLock {
        locked: true
        WlSessionLockSurface {
            color: "#1e1e2e"            // <-- variable 1: opacity/color
            Rectangle {
                anchors.centerIn: parent; width: 760; height: 240; radius: 24
                color: "#cdd6f4"
                // <-- variable 2: drop in ONE suspect feature here and nothing else.
                //     e.g. to test suspect (A): layer.enabled: true; layer.effect: OpacityMask { ... }
                //     e.g. to test fonts:        MaterialSymbol { text: "lock" }
                Text { anchors.centerIn: parent; text: "visible => this feature is fine" }
            }
        }
    }
}
```

### Next files to write (maps to rev-3 suspects)
- `minimal-lock-layereffect.qml` — add `layer.enabled: true` + `layer.effect: OpacityMask{ maskSource: Rectangle{ radius: height/2 } }` (+ `import Qt5Compat.GraphicalEffects`). ❌ here ⇒ **suspect (A) confirmed**, the FBO/OpacityMask is the bug.
- `minimal-lock-materialsymbol.qml` — add a `MaterialSymbol`/icon-font item. Tests font/glyph rendering in the lock surface.
- `minimal-lock-shadereffect.qml` — add any `ShaderEffect`/`MultiEffect`. Tests shader pipeline in the lock surface.
- Keep going down LockSurface.qml's feature list until one flips to ❌. That file IS the minimal reproducer — attach it to an upstream quickshell/Hyprland bug report.

### Rules
- One change per file. Two changes = ambiguous result.
- Name files after the hypothesis; keep every ✅ file as a regression baseline.
- Only on tty2+; the bug wedges the session, never test on tty1.
- Default verbosity only — do **not** add `QT_LOGGING_RULES=…quickshell.*=true` (it segfaults qs in its logger and ruins the experiment).

## APPENDIX E — meta-lessons / traps for the next session (hard-won today)

- **Verify session/lock state before asserting it — never infer success from indirect signals.** Twice today I claimed "tty2 healthy / lock worked / user probably typed the password" from indirect cues (qs pid alive; `hyprctl layers` showed no lock layer). Both wrong — tty2 was stuck on Hyprland's lockscreen-crash overlay, no password entered. Confirm with a direct observation (ask what's actually on screen) before stating state as fact.
- **`hyprctl layers` does NOT list ext-session-lock surfaces.** "No lock layer" proves nothing about whether a lock is active. Absence of evidence ≠ evidence of absence — check whether the tool even covers the thing.
- **qs process alive ≠ lock succeeded.** The lock *surface* can fail while the qs *process* lives. Distinguish "process crashed" (→ `~/.cache/quickshell/crashes/<id>/report.txt`) from "surface wedged" (→ no report, Hyprland lock-crashed overlay, pid unchanged).
- **Don't debug this with verbose logging.** `QT_LOGGING_RULES=…quickshell.*=true` (and friends) segfault qs in its own logger (`logging.cpp:131`, offthread-logger UAF). It crashes qs during startup and masks the real behavior. Use default verbosity.
- **Ignore aquamarine `atomic drm request: failed to commit: Permission denied` (EACCES).** It's normal inactive-VT noise (the healthy tty1 logs it 66×), always followed by `Restoring crtc`. Not the bug.
- **Single instance only.** Running a 2nd `qs -c ii` next to the session's own qs muddies everything (IPC/singleton conflicts). Test the session's own qs, or kill this-VT's qs first (never blanket `pkill qs` — it kills tty1's).
- **The `qs -p` isolation protocol (Appendix D) is the fast path.** One standalone file, one variable, run, observe ✅/❌. It collapsed the suspect space in ~3 runs. Prefer it over in-place debugging.

## APPENDIX C — key external refs
- WlSessionLockSurface docs (transparent surfaces flaky; use a colored child): https://quickshell.org/docs/master/types/Quickshell.Wayland/WlSessionLockSurface/
- Hyprland nvidia explicit-sync black/freeze (#7230, knob renamed in 0.55.2): https://github.com/hyprwm/Hyprland/issues/7230
- Upstream pin source: https://github.com/end-4/dots-hyprland → `sdata/dist-arch/illogical-impulse-quickshell-git/PKGBUILD`
