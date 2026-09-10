# Dotfiles Setup with Stow

## Golden Rule

**Always run `stow` from `~/dotfiles` and name `dots` as the package.**

```bash
cd ~/dotfiles
stow --adopt dots
```

This is what `main.sh:133` (`symlink_with_stow`) actually runs, and it is what
produced every working symlink on this machine — check any of them and you'll
see `~/.config/fuzzel -> ../dotfiles/dots/.config/fuzzel`.

How stow reads that command:
- package = `dots` — the directory whose *contents* get linked
- stow dir = `~/dotfiles` — the current directory, where stow looks for the package
- target = `~` — defaults to the **parent of the stow dir**, so no `-t` is needed

## Do NOT run it from inside `dots/`

```bash
# WRONG — do not use
cd ~/dotfiles/dots
stow -vS . -d .. -t ~
```

With stow dir `..` (= `~/dotfiles`), the package `.` resolves to the **repo root**,
not to `dots/`. Stow then tries to link the repo's own top-level entries into `~`:

```
LINK: docs => dotfiles/docs
LINK: main.sh => dotfiles/main.sh
LINK: .github => dotfiles/.github
LINK: sdata => dotfiles/sdata
...
```

That litters `$HOME` with links to repo internals and links nothing from `dots/`.

## The `--adopt` hazard

`--adopt` changes what happens when a **real file** already sits where a symlink
belongs. Without it, stow refuses and reports a conflict. With it, stow **moves
that live file into the repo**, overwriting the committed version, and then
creates the symlink pointing at the now-overwritten file.

The direction is the dangerous part: **the machine wins, the repo loses.**

This is correct and necessary on a **fresh install**, where end4's installer has
already copied real files into `~/.config` that need absorbing.

It is a footgun on a **re-run** against an already-configured machine. Real
example: herdr wrote a 19-byte `~/.config/herdr/config.toml` stub during its
onboarding. A `stow --adopt dots` at that moment would have pulled the stub into
the repo and destroyed the 130-line keybinding config it replaced.

Worse, git would not flag it as a conflict — just a plain `modified` file,
indistinguishable from intentional work and easy to bury with `git add -A`.

`symlink_with_stow` in `main.sh` now diffs `git status` before and after the
stow run and warns loudly if anything was adopted. Heed that warning.

### Re-stowing safely by hand

On a machine that is already set up, drop `--adopt` so conflicts surface instead
of being silently swallowed:

```bash
cd ~/dotfiles
stow -vS dots          # refuses on conflict instead of overwriting the repo
```

Then resolve each reported conflict deliberately — usually by deleting the stray
real file, once you've confirmed the repo's version is the one you want:

```bash
rm ~/.config/<thing>   # only after checking the repo copy is correct
stow -vS dots
```

## Cleanup (Unstow)

```bash
cd ~/dotfiles
stow -D dots
```

Removes the symlinks without touching the files in `dots/`.

## Verify Setup

```bash
ls -la ~/.config/ | grep "^l"
```

All should point to `../dotfiles/dots/.config/...`.

To confirm a specific file is actually live rather than a stray real file:

```bash
ls -la ~/.config/herdr/config.toml
# -> ../../dotfiles/dots/.config/herdr/config.toml
```

## Common Issues

**A config's settings are being ignored entirely.** Usually means a real file is
shadowing the symlink, so the repo version was never read. Check with `ls -la`;
if it's a regular file, compare it against the repo copy, delete it, and re-stow.

**Stow reports a conflict.** Expected behaviour without `--adopt`. It means a real
file occupies the target. Inspect both versions before deleting either one.

**Repo files show as `modified` right after running `main.sh`.** `--adopt` absorbed
live files into the repo. Inspect and restore:

```bash
git -C ~/dotfiles diff -- dots/
git -C ~/dotfiles checkout -- dots/    # discards the adopted content
```

**Directories that are copies, not links.** Some are deleted deliberately in
`main.sh` (`~/.config/quickshell`, `~/.config/hypr`) so stow can link the repo
versions, which have their submodules properly checked out.

## Note on runtime state

Some apps write runtime files next to their config (herdr keeps sockets, logs and
`plugins.json` in `~/.config/herdr/`). Those directories stay real directories;
stow folds into them and links the individual config files. That is expected —
don't try to convert them into whole-directory symlinks.
