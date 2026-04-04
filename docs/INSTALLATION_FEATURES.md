# Illogical Impulse - Complete Feature List

This document lists all packages, applications, and configurations that will be installed by the setup script.

---

## Core System Packages

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **hyprland** | ✓ | Window Manager | Wayland compositor and window manager (core) |
| [ ] | **wl-clipboard** | ✓ | System | Wayland clipboard manager |
| [ ] | **hyprsunset** | ✗ | System | Screen temperature adjustment |
| [ ] | **hypridle** | ✓ | System | Idle management and session locking |
| [ ] | **hyprlock** | ✓ | Security | Screen locker application |
| [ ] | **wlogout** | ✓ | System | Power menu widget |
| [ ] | **networkmanager** | ✓ | Network | Network connection management |
| [ ] | **plasma-nm** | ✓ | Network | KDE Network Manager integration |
| [ ] | **bluedevil** | ✓ | Bluetooth | KDE Bluetooth integration |
| [ ] | **polkit-kde-agent** | ✓ | Security | KDE authentication agent |
| [ ] | **gnome-keyring** | ✓ | Security | Password and key storage daemon |
| [ ] | **xdg-desktop-portal** | ✓ | System | XDG desktop portal (core) |
| [ ] | **xdg-desktop-portal-kde** | ✓ | System | KDE portal implementation |
| [ ] | **xdg-desktop-portal-gtk** | ✓ | System | GTK portal implementation |
| [ ] | **xdg-desktop-portal-hyprland** | ✓ | System | Hyprland portal implementation |
| [ ] | **upower** | ✓ | System | Power management daemon |
| [ ] | **fontconfig** | ✓ | System | Font configuration system |
| [ ] | **glib2** | ✓ | System | GLib library (provides gsettings) |
| [ ] | **xdg-user-dirs** | ✓ | System | XDG user directory manager |
| [ ] | **hyprcursor** | ✗ | System | Cursor theme manager |
| [ ] | **hyprutils** | ✗ | System | Hyprland utilities |
| [ ] | **hyprlang** | ✗ | System | Hyprland language library |
| [ ] | **hyprland-qtutils** | ✗ | System | Qt utilities for Hyprland |
| [ ] | **hyprland-qt-support** | ✗ | System | Qt support for Hyprland |
| [ ] | **hyprwayland-scanner** | ✗ | System | Wayland protocol scanner |
| [ ] | **xdg-desktop-portal-hyprland** | ✓ | System | Hyprland portal implementation |

---

## Shell & Terminal

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **fish** | ✗ | Shell | Fish shell (interactive shell) |
| [ ] | **starship** | ✓ | Shell | Modular shell prompt |
| [ ] | **foot** | ✗ | Terminal | Wayland terminal emulator (optional, no config) |
| [ ] | **kitty** | ✓ | Terminal | GPU-based terminal emulator |

---

## Launcher & UI

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **fuzzel** | ✓ | Launcher | Application launcher/menu |
| [ ] | **hyprpicker** | ✗ | UI Tools | Color picker utility |
| [ ] | **kdialog** | ✓ | UI Tools | KDE dialog utility |
| [ ] | **nm-connection-editor** | ✗ | UI Tools | Network connection editor |

---

## File Manager & Utilities

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **dolphin** | ✓ | File Manager | KDE file manager |
| [ ] | **eza** | ✓ | CLI Tools | `ls` replacement with icons |
| [ ] | **systemsettings** | ✓ | System Settings | KDE system settings |

---

## Audio & Media

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **wireplumber** | ✓ | Audio | PipeWire session manager |
| [ ] | **pipewire-pulse** | ✗ | Audio | PulseAudio compatibility layer |
| [ ] | **cava** | ✗ | Audio | Audio visualizer (Quickshell widget) |
| [ ] | **pavucontrol-qt** | ✗ | Audio | PulseAudio volume control (Qt) - incompatible with pipewire-pulse |
| [ ] | **playerctl** | ✓ | Audio | Media player control |
| [ ] | **libdbusmenu-gtk3** | ✓ | Audio | DBus menu support |

---

## Hardware Control

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **brightnessctl** | ✓ | Hardware | Backlight brightness control |
| [ ] | **ddcutil** | ✓ | Hardware | Monitor brightness control via DDC-CI |
| [ ] | **geoclue** | ✓ | Hardware | Geolocation service |

---

## Screenshot & Recording

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **hyprshot** | ✓ | Utilities | Screenshot tool |
| [ ] | **slurp** | ✓ | Utilities | Region/window selection tool |
| [ ] | **swappy** | ✓ | Utilities | Screenshot annotation tool |
| [ ] | **wf-recorder** | ✓ | Utilities | Screen recording tool |
| [ ] | **tesseract** | ✓ | Utilities | OCR (Optical Character Recognition) |
| [ ] | **tesseract-data-eng** | ✓ | Utilities | English language data for tesseract |

---

## Utilities & Tools

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **cliphist** | ✓ | Utilities | Clipboard history manager |
| [ ] | **wtype** | ✓ | Utilities | Type text to active window |
| [ ] | **ydotool** | ✓ | Utilities | Keyboard/mouse automation tool |
| [ ] | **libqalculate** | ✗ | Utilities | Calculator (math in searchbar) |
| [ ] | **songrec** | ✗ | Utilities | Music recognition tool (Shazam-like) |
| [ ] | **translate-shell** | ✓ | Utilities | Text translation tool |
| [ ] | **imagemagick** | ✗ | Utilities | Image manipulation (provides `magick`) |
| [ ] | **hyprpicker** | ✗ | Utilities | Color picker utility |

---

## CLI & Development Tools

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **curl** | ✓ | CLI Tools | HTTP/HTTPS client |
| [ ] | **wget** | ✓ | CLI Tools | HTTP/FTP file downloader |
| [ ] | **ripgrep** | ✓ | CLI Tools | Fast recursive file search |
| [ ] | **jq** | ✓ | CLI Tools | JSON processor and manipulator |
| [ ] | **go-yq** | ✗ | CLI Tools | YAML processor |
| [ ] | **bc** | ✓ | CLI Tools | Command-line calculator |
| [ ] | **rsync** | ✓ | CLI Tools | File synchronization utility |
| [ ] | **coreutils** | ✓ | System | Core UNIX utilities |
| [ ] | **cmake** | ✓ | Build Tools | Build system generator |
| [ ] | **clang** | ✓ | Build Tools | C/C++ compiler (Python support) |
| [ ] | **axel** | ✗ | CLI Tools | Multi-threaded downloader |
| [ ] | **meson** | ✗ | Build Tools | Build system generator |

---

## Fonts & Icons

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **ttf-jetbrains-mono-nerd** | ✓ | Fonts | JetBrains Mono Nerd font (terminals/UI) |
| [ ] | **ttf-material-symbols-variable-git** | ✓ | Fonts | Material Symbols icon font |
| [ ] | **ttf-readex-pro** | ✓ | Fonts | Readex Pro font |
| [ ] | **ttf-rubik-vf** | ✓ | Fonts | Rubik variable weight font |
| [ ] | **ttf-twemoji** | ✓ | Fonts | Emoji font fallback |
| [ ] | **otf-space-grotesk** | ✓ | Fonts | Space Grotesk font |
| [ ] | **ttf-gabarito-git** | ✗ | Fonts | Gabarito font |
| [ ] | **illogical-impulse-bibata-modern-classic-bin** | ✗ | Cursor Theme | Bibata Modern Classic cursor theme |

---

## Themes & Color Management

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **adw-gtk-theme-git** | ✓ | Themes | Adwaita GTK theme |
| [ ] | **breeze** | ✓ | Themes | Breeze KDE theme |
| [ ] | **breeze-plus** | ✓ | Themes | Breeze Plus variant |
| [ ] | **darkly-bin** | ✓ | Themes | Darkly Qt theme |
| [ ] | **matugen** | ✗ | Utilities | Material color palette generator |
| [ ] | **matugen-bin** | ✗ | Utilities | Material color palette generator (binary) |
| [ ] | **kde-material-you-colors** | ✗ | Themes | KDE Material You color scheme |

---

## Python & Build Dependencies

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **uv** | ✓ | Python | Python package and venv manager |
| [ ] | **gtk4** | ✓ | Libraries | GTK4 library (Python support) |
| [ ] | **libadwaita** | ✓ | Libraries | Adwaita library (Python support) |
| [ ] | **libsoup3** | ✓ | Libraries | HTTP library (Python support) |
| [ ] | **libportal-gtk4** | ✓ | Libraries | Portal library (Python support) |
| [ ] | **gobject-introspection** | ✓ | Libraries | GObject introspection (Python support) |
| [ ] | **sassc** | ✗ | Build Tools | SASS compiler |
| [ ] | **python-opencv** | ✗ | Libraries | OpenCV Python bindings |

---

## Qt6 & Graphics Libraries

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **qt6-base** | ✓ | Libraries | Qt6 core libraries (Quickshell) |
| [ ] | **qt6-declarative** | ✓ | Libraries | Qt6 QML support (Quickshell) |
| [ ] | **qt6-5compat** | ✓ | Libraries | Qt6 backwards compatibility |
| [ ] | **qt6-svg** | ✓ | Libraries | SVG support |
| [ ] | **qt6-wayland** | ✓ | Libraries | Wayland support for Qt6 |
| [ ] | **qt6-imageformats** | ✓ | Libraries | Additional image format support |
| [ ] | **qt6-avif-image-plugin** | ✓ | Libraries | AVIF image format support |
| [ ] | **qt6-multimedia** | ✓ | Libraries | Multimedia support |
| [ ] | **qt6-positioning** | ✓ | Libraries | Location/positioning API |
| [ ] | **qt6-quicktimeline** | ✓ | Libraries | Qt Quick Timeline support |
| [ ] | **qt6-sensors** | ✓ | Libraries | Sensor API |
| [ ] | **qt6-tools** | ✓ | Build Tools | Qt6 build tools |
| [ ] | **qt6-translations** | ✓ | Localization | Qt6 translations |
| [ ] | **qt6-virtualkeyboard** | ✓ | Libraries | Virtual keyboard support |
| [ ] | **kirigami** | ✗ | Libraries | Kirigami UI framework |
| [ ] | **syntax-highlighting** | ✓ | Libraries | Syntax highlighting library |
| [ ] | **mesa** | ✗ | Libraries | OpenGL/Vulkan drivers |
| [ ] | **libdrm** | ✗ | Libraries | DRM library (GPU support) |
| [ ] | **libpipewire** | ✗ | Libraries | PipeWire library |
| [ ] | **libxcb** | ✗ | Libraries | X11 protocol library |
| [ ] | **wayland** | ✗ | Libraries | Wayland libraries |
| [ ] | **cpptrace** | ✗ | Libraries | C++ stack trace library |
| [ ] | **jemalloc** | ✗ | Libraries | Memory allocator (performance) |

---

## Special Builds

| Want? | Package | Also in my-scripts? | Category | Purpose |
|-------|---------|:---:|----------|---------|
| [ ] | **illogical-impulse-quickshell-git** | ✗ | Main UI | Custom Quickshell build (pinned commit) with II configs |
| [ ] | **quickshell-git** | ✗ | Main UI | Quickshell from AUR (used in my-scripts) |
| [ ] | **illogical-impulse-microtex-git** | ✓ | Utilities | LaTeX renderer (installed to /opt/MicroTeX) |
| [ ] | **illogical-impulse-oneui4-icons-git** | ✗ | Icons | OneUI4 icon theme (deprecated in end4, present in my-scripts) |

---

## Optional Packages

| Want? | Package | Category | Notes |
|-------|---------|----------|-------|
| [ ] | **plasma-browser-integration** | Optional | ~600MiB extra if KDE not installed. Shows Firefox media playback in music widget. |

---

## Dotfiles & Configuration

These configuration files will be copied to your system:

| Want? | File/Directory | Location | Purpose |
|-------|----------------|----------|---------|
| [ ] | **Quickshell** | `~/.config/quickshell/` | Custom panel/shell configuration |
| [ ] | **Hyprland** | `~/.config/hypr/` | Window manager and keybinds config |
| [ ] | **Fish** | `~/.config/fish/` | Shell configuration and aliases |
| [ ] | **Kitty** | `~/.config/kitty/` | Terminal emulator config |
| [ ] | **Fontconfig** | `~/.config/fontconfig/` | Font configuration |
| [ ] | **Fuzzel** | `~/.config/fuzzel/` | Application launcher config |
| [ ] | **Foot** | `~/.config/foot/` | Terminal emulator config (optional) |
| [ ] | **MPV** | `~/.config/mpv/` | Video player config |
| [ ] | **Konsole** | `~/.local/share/konsole/` | KDE terminal profiles |
| [ ] | **Dolphin** | `~/.config/dolphinrc` | File manager config |
| [ ] | **KDE Globals** | `~/.config/kdeglobals` | KDE theme and appearance settings |
| [ ] | **Material You Colors** | `~/.config/kde-material-you-colors/` | Dynamic color generation |
| [ ] | **Hyprlock** | `~/.config/hypr/hyprlock.conf` | Screen locker appearance |
| [ ] | **Hypridle** | `~/.config/hypr/hypridle.conf` | Idle timeout and actions |
| [ ] | **Starship** | `~/.config/starship.toml` | Prompt configuration |
| [ ] | **Kvantum** | `~/.config/Kvantum/` | Qt theme configuration |
| [ ] | **XDG Desktop Portal** | `~/.config/xdg-desktop-portal/` | Portal configuration |
| [ ] | **Wlogout** | `~/.config/wlogout/` | Power menu styling |
| [ ] | **ZSH** | `~/.config/zshrc.d/` | ZSH shell config snippets |
| [ ] | **Google Sans Flex Font** | `~/.local/share/fonts/` | Custom font (downloaded, not on Fedora) |
| [ ] | **Icon Theme** | `~/.local/share/icons/` | Icon assets |

---

## Services & Daemon Setup

These services will be enabled and started:

| Service | Purpose | Notes |
|---------|---------|-------|
| `ydotool.service` | Keyboard/mouse automation daemon | User service |
| `bluetooth` | Bluetooth connectivity | System service |

---

## Setup Steps

The installation runs 3 main phases:

1. **Install Dependencies** - All packages listed above
2. **Setup Permissions/Services** - User groups, systemd services, udev rules
3. **Copy Configuration Files** - Dotfiles and configs

You can skip individual configurations with flags like:
- `--skip-fish` - Skip Fish shell config
- `--skip-hyprland` - Skip Hyprland config
- `--skip-quickshell` - Skip Quickshell config
- `--skip-fontconfig` - Skip fontconfig
- `--skip-miscconf` - Skip all other configs
- `--core` - Alias for skipping most optional configs
- `--skip-plasmaintg` - Skip plasma-browser-integration

---

## Summary Statistics

- **Total Package Groups**: 11 meta packages
- **Total Individual Packages**: 100+ packages
- **Total Configuration Modules**: 15+ config directories
- **Special Builds**: 2 (Quickshell, MicroTeX)
- **Optional Components**: Multiple (can be skipped via flags)

---

## Key Customization Points

### For Minimal Installation
Use `--core` flag to skip:
- plasma-browser-integration
- Fish shell config
- Most miscellaneous configs
- Fontconfig

### For Terminal-Only
Skip:
- `--skip-quickshell` (the main UI)
- `--skip-hyprland` (if not using Wayland)

### For Alternative Shell
Skip:
- `--skip-fish` (keeps the environment, just different shell)

---

## Notes

- **Fish Shell**: Configured by default but can be skipped
- **Foot Terminal**: No dedicated config, kitty is the primary terminal
- **Quickshell**: Custom UI framework for the panel/widgets (requires Qt6)
- **MicroTeX**: Optional LaTeX renderer, installed to `/opt/MicroTeX`
- **Google Sans Flex Font**: Downloaded during installation (not available on Fedora)
- **Plasma Browser Integration**: Optional, adds ~600MB if KDE not installed
- **Python Virtual Environment**: Python packages installed to `~/.local/state/quickshell/.venv`

---

## Key Differences: end4 vs my-installation-scripts

### Packages ONLY in end4 (not in my-scripts)
- `hyprsunset` - Screen temperature adjustment
- `pavucontrol-qt` - PulseAudio volume control (marked incompatible with pipewire-pulse in my-scripts)
- `cava` - Audio visualizer
- `fish` - Fish shell configuration
- `foot` - Foot terminal emulator
- `hyprpicker` - Color picker (exists in both but grouped differently)
- `libqalculate` - Calculator for searchbar math
- `songrec` - Music recognition
- `imagemagick` - Image manipulation
- `go-yq` - YAML processor
- `kirigami` - Kirigami UI framework
- `mesa`, `libdrm`, `libpipewire`, `libxcb`, `wayland`, `cpptrace`, `jemalloc` - Graphics/system libraries
- `illogical-impulse-quickshell-git` - Custom Quickshell build
- `illogical-impulse-bibata-modern-classic-bin` - Bibata cursor theme
- `matugen` - Material color generator (end4 uses this, my-scripts uses `matugen-bin`)

### Packages ONLY in my-scripts (not in end4)
- `hyprcursor` - Cursor theme manager
- `hyprutils` - Hyprland utilities
- `hyprlang` - Hyprland language library
- `hyprland-qtutils` - Qt utilities for Hyprland
- `hyprland-qt-support` - Qt support for Hyprland
- `hyprwayland-scanner` - Wayland protocol scanner
- `nm-connection-editor` - Network connection editor
- `axel` - Multi-threaded downloader
- `meson` - Build system generator
- `ttf-gabarito-git` - Gabarito font
- `kde-material-you-colors` - Material You color scheme
- `matugen-bin` - Binary version of Material color generator
- `sassc` - SASS compiler
- `python-opencv` - OpenCV Python bindings
- `quickshell-git` - Quickshell from AUR (instead of custom build)
- `illogical-impulse-oneui4-icons-git` - OneUI4 icons (deprecated in end4)

### Architecture Differences
- **end4**: Uses custom `illogical-impulse-quickshell-git` with pinned commit
- **my-scripts**: Uses `quickshell-git` from AUR directly
- **my-scripts**: Moves Qt6 packages to `ii-toolkit` instead of `ii-quickshell-git`
- **my-scripts**: Directly includes Hyprland-related packages (`hyprcursor`, `hyprutils`, etc.) instead of relying on system packages
- **my-scripts**: Removed `pavucontrol-qt` (incompatible with pipewire-pulse)
- **my-scripts**: More Python-focused (adds OpenCV, SASS)

### Configuration Strategy
- **end4**: More modular with separate meta-packages per feature
- **my-scripts**: Reorganized meta-packages with some consolidation (e.g., moving Qt6 to toolkit)
