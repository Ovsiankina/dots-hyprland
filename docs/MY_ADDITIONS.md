# My Personal Additions over end4

Everything listed here is installed by `my-installation-scripts` but is **NOT** present in the end4 repo.
This is what needs to be re-implemented / ported when switching to a fork of end4.

---

## Infrastructure & Setup Strategy

| Item | Type | Notes |
|------|------|-------|
| **GNU Stow** | Dotfile manager | Uses `stow --adopt .` from `~/dotfiles` — replaces end4's rsync-based file copy |
| **qwerty-fr layout** | Keyboard layout | Downloaded from GitHub releases, installed system-wide |
| **tmux plugin manager (tpm)** | Shell tool | Cloned into `~/.tmux/plugins/tpm` |
| **ZSH as default shell** | Shell | `chsh -s $(which zsh)` + sources `~/.zshrc` |
| **end4-sync.sh** | Script | Custom sync script that pulls specific dirs from the end4 fork into `~/dotfiles` |

---

## System Base

| Package | Purpose |
|---------|---------|
| `base` | Minimal Arch base package set |
| `base-devel` | Build tools |
| `efibootmgr` | EFI Boot Manager |
| `grub` | Bootloader |
| `linux` | Linux kernel |
| `linux-firmware` | Firmware files |
| `man-db` | Man page reader |
| `xfsprogs` | XFS filesystem utilities |

---

## Shell & Terminal

| Package | Source | Purpose |
|---------|--------|---------|
| `zsh` | pacman | Primary shell (replaces fish) |
| `tmux` | pacman | Terminal multiplexer |
| `zoxide` | pacman | Smarter `cd` command |
| `bat` | pacman | `cat` with syntax highlighting |
| `fzf` | pacman | Command-line fuzzy finder |
| `fastfetch` | pacman | System info tool (neofetch replacement) |
| `fd` | pacman | Fast `find` alternative |
| `thefuck` | pacman | Corrects previous console command |
| `zsh-fast-syntax-highlighting-git` | AUR | Fast ZSH syntax highlighting |
| `htop-vim` | AUR | htop with Vim keybindings |
| `sc-im` | AUR | Vim-like terminal spreadsheet |
| `cbonsai` | AUR | Bonsai tree generator |
| `pacnews` | AUR | Read Arch Linux news from CLI |
| `tldr++` | AUR | Community-driven man page summaries |
| `asp` | AUR | Arch build source file management |
| `cheat` | AUR | Interactive CLI cheatsheets |

---

## Networking

| Package | Purpose |
|---------|---------|
| `dhcpcd` | DHCP client daemon |
| `iwd` | Internet Wireless Daemon |
| `openssh` | SSH connectivity tools |
| `speedtest-cli` | Internet bandwidth testing |
| `ufw` | Uncomplicated firewall |
| `wpa_supplicant` | Wireless LAN daemon |

---

## Audio

| Package | Purpose |
|---------|---------|
| `rtkit` | Realtime Policy and Watchdog Daemon |
| `sof-firmware` | Sound Open Firmware |
| `alsa-ucm-conf` | ALSA Use Case Manager configuration |
| `pavucontrol` | PulseAudio volume control GUI (GTK, vs end4's Qt version) |

---

## Bluetooth

| Package | Purpose |
|---------|---------|
| `bluez` | Bluetooth protocol stack |
| `bluez-utils` | Bluetooth utilities |

---

## NVIDIA

| Package | Purpose |
|---------|---------|
| `nvidia-open` | NVIDIA open kernel modules |
| `nvidia-utils` | NVIDIA driver utilities |

---

## Hyprland / Wayland Extras

| Package | Source | Purpose |
|---------|--------|---------|
| `grim` | pacman | Screenshot utility for Wayland |
| `hyprpaper` | pacman | Wallpaper utility with IPC |
| `qt5-wayland` | pacman | Qt5 Wayland support |
| `aylurs-gtk-shell-git` | AUR | AGS (shell toolkit, not used actively) |
| `xwayland-run` | AUR | Utilities for running Xwayland |

---

## Fonts

| Package | Purpose |
|---------|---------|
| `noto-fonts-cjk` | Google Noto CJK fonts (Chinese/Japanese/Korean) |
| `otf-libertinus` | Libertinus fonts with math support |
| `ttf-fira-code` | Monospaced font with ligatures |

---

## Dev Tools & Editors

| Package | Source | Purpose |
|---------|--------|---------|
| `git` | pacman | Version control |
| `docker` | pacman | Container platform |
| `docker-buildx` | pacman | Docker extended build |
| `lazydocker` | pacman | TUI for Docker |
| `lazygit` | pacman | TUI for git |
| `yazi` | pacman | Blazing fast terminal file manager (Rust) |
| `plocate` | pacman | Fast `locate` replacement |
| `qemu-base` | pacman | Basic QEMU for virtualization |
| `strace` | pacman | Trace system calls |
| `unzip` / `zip` | pacman | Archive tools |
| `usbutils` | pacman | USB device querying tools |
| `glfw` | pacman | OpenGL/graphics multi-platform library |
| `devtools` | pacman | Arch package maintainer tools |
| `stow` | pacman | Symlink farm manager (used for dotfiles) |
| `ollama` | pacman | Run LLMs locally |
| `checkupdates-with-aur` | AUR | Check pacman + AUR updates |
| `docker-scout` | AUR | Docker supply chain security CLI |

---

## Neovim & Editor Ecosystem

| Package/Tool | Source | Purpose |
|---------|--------|---------|
| `neovim` | pacman | Primary text editor |
| `go` | pacman | Go compiler (for Mason LSPs: hyprls, gols) |
| `tree-sitter-cli` | npm | Treesitter CLI for Neovim |
| `pyright` | npm | Python LSP |

---

## Python Ecosystem

| Package | Source | Purpose |
|---------|--------|---------|
| `python` | pacman | Python interpreter |
| `python-mutagen` | pacman | Audio metadata tag reader/writer |
| `python-pynvim` | pacman | Python client for Neovim |
| `pyenv` | pacman | Switch between Python versions |
| `python-gpustat` | AUR | GPU load monitor |
| `python-pywal16` | AUR | Generate colorschemes from images |

#### Python venv packages (installed via uv into `~/.local/state/quickshell/.venv`)

| Package | Purpose |
|---------|---------|
| `pillow` | Image processing |
| `pywayland` | Wayland protocol bindings |
| `psutil` | Process and system utilities |
| `materialyoucolor` | Material You color extraction |
| `libsass` | SASS compiler |
| `material-color-utilities` | Google Material color utilities |
| `setproctitle` | Set process title |
| `build`, `setuptools-scm`, `wheel` | Build tools |

---

## Rust Ecosystem

| Package | Source | Purpose |
|---------|--------|---------|
| `rustup` | pacman | Rust toolchain installer |
| `rust-src` | pacman | Rust compiler source (for IDEs) |
| `rustowl-bin` | AUR | Visualize ownership and lifetimes |

---

## JavaScript / Node Ecosystem

| Package | Source | Purpose |
|---------|--------|---------|
| `nodejs-lts-iron` | pacman | Node.js LTS runtime |
| `npm` | pacman | Node package manager |
| `yarn` | pacman | Alternative Node package manager |

---

## C/C++ Ecosystem

| Package | Source | Purpose |
|---------|--------|---------|
| `doxygen` | pacman | Documentation generator |
| `eigen` | pacman | C++ linear algebra library |
| `fmt` | pacman | Modern C++ formatting library |
| `poco` | pacman | C++ network/internet libraries |
| `valgrind` | pacman | Memory debugger |
| `codelldb-bin` | AUR | LLDB extension for VSCode |

---

## Desktop Applications

| Package | Source | Purpose |
|---------|--------|---------|
| `obsidian` | pacman | Knowledge base / Markdown notes |
| `mathjax` | pacman | JavaScript math display engine |
| `zen-browser-bin` | AUR | Firefox-based performance browser |
| `drawio-desktop` | AUR | Diagram and flowchart tool |
| `onlyoffice-bin` | AUR | Office suite (Writer, Calc, Impress) |
| `anki` | AUR | Spaced repetition flashcard app |
| `pinta` | AUR | Simple paint/drawing app |
| `dibuja` | AUR | Simple GTK paint program |
| `ida-free` | AUR | IDA freeware disassembler |
| `jetbrains-toolbox` | AUR | JetBrains IDE manager |
| `rpiusbboot` | AUR | Raspberry Pi USB boot utility |
| `zsa-keymapp-bin` | AUR | Visual reference for ZSA keyboards |

---

## AI Tools

| Package | Source | Purpose |
|---------|--------|---------|
| `openai-codex-bin` | AUR | OpenAI Codex terminal coding agent |

---

## Summary: What to Port to end4 Fork

When switching to a fork of end4, the following areas need to be handled:

1. **Shell**: Add ZSH config (`.zshrc`, plugins) — end4 uses Fish by default
2. **Dotfile management**: Decide whether to keep Stow or adapt to end4's rsync approach
3. **System/boot packages**: grub, linux, base packages (likely already installed)
4. **NVIDIA**: Add nvidia-open + nvidia-utils to your setup
5. **Keyboard layout**: Re-run the qwerty-fr install script
6. **Tmux**: Install tpm and your tmux config
7. **Dev environments**: All the language ecosystems (Rust, Python, JS, C/C++, Go)
8. **Neovim**: Install neovim + LSPs via Mason, npm globals
9. **Desktop apps**: Obsidian, Zen Browser, OnlyOffice, Anki, etc.
10. **AI**: Ollama (local LLMs), Codex
11. **Networking extras**: ufw, iwd/wpa_supplicant (if not already present)
