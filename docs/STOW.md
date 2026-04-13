# Dotfiles Setup with Stow

## Golden Rule

**Always run `stow` from inside the `dots/` directory.**

Running stow from the root creates symlinks in wrong locations (e.g., `.zprofile` in root instead of only in `dots/`).

## Installation

```bash
cd ~/dotfiles/dots
stow -vS . -d .. -t ~
```

Flags:
- `-v` = verbose (shows what's being linked)
- `-S` = stow (create symlinks)
- `.` = stow everything in current dir
- `-d ..` = target parent dir (dotfiles root)
- `-t ~` = target home directory

## Cleanup (Unstow)

```bash
cd ~/dotfiles/dots
stow -D .
```

Removes all symlinks without touching source files.

## Verify Setup

Check symlinks point to `dots/`:

```bash
ls -la ~/ | grep "^l"
```

All should point to `../dotfiles/dots/...`

## Common Issues

**Multiple .zprofile files** — Stow created one in root. Fix:
1. Delete `/root/.zprofile` (or `~/.zprofile` if it's a regular file not a symlink)
2. Ensure only `/home/user/dotfiles/dots/.zprofile` exists
3. Verify symlink created: `ls -la ~/.zprofile` → should point to `dotfiles/dots/.zprofile`
4. Re-run stow if needed

## Future Stow Commands

All stow operations must run from `dots/` to maintain correct symlink structure.
