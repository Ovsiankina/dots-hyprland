# QS lockscreen issue

## When it started

Since I synced this current desktop (my work desktop) to my personal laptop
and desktop (3 pcs in total).

commit of may 21 (since approx. git commit a32155fe).

## Where ?

Laptop is unimpacted yet in sync. only difference is hardware and single screen.

both work and personal desktops have dual screens. I was able to verify that the
dual screens setup is NOT the issue. deactivating the second screen doesnt fix
the issue. Other point in common: nvidia gpu. latpop doesnt have nvidia.

But nvidia is half the picture because before 21 of may, this exact desktop (work)
had the lock working.

## Symptoms

SUPER+ALT+L: triggers the lockscreen.

### normal behavior

Uses quickshell's lock system. 
- The screen is blured with a transparency layer.
- All windows and apps are thrown towards the bottom until hidden
- keyboard/user, pwd input field and power buttons shows up at the bottom of the screen
- The clock visible at all time on the desktop (unlocked) get centered and reused in the lock screen.
- Normal lock behavior.

### The actual problematic behavior

- All windows and apps are thrown towards the bottom until hidden (like normal)
- No transparency/blur layer.
- no bottom buttons.
- no pwd input field
- can't input password.. can't log back in.. forced to go to a new tty or reboot.
- other ttys have the same issue.

## What not to do while debugging

### EXTREMELY IMPORTANT. ALWAYS REMEMBER THIS.

**DO NOT CALL THE LOCK ON TTY1. NEVER**

Im working !! Im at work !! on tty1 !! never lock me out. EVER

Do all tests on tty2 and more. NEVER NEVER EVER TTY1.

## Possible ressources

upstream most likely already have a fix for this: https://github.com/end-4/dots-hyprland

The issue is that i have a slightly modified quickshell.
