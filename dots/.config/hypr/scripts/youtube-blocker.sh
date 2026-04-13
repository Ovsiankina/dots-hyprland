#!/usr/bin/env bash
# ============================================================================
# youtube-blocker.sh — Multi-layer YouTube blocking for Linux
# ============================================================================
# Layers:
#   1. nftables firewall rules (blocks YouTube/Google-Video IP ranges)
#   2. /etc/hosts poisoning (backup layer)
#   3. DNS-over-HTTPS disabling in browsers (prevents bypassing /etc/hosts)
#   4. Password-protected unblock (random token you must supply)
#
# Install:  sudo bash youtube-blocker.sh install
# Status:   sudo bash youtube-blocker.sh status
# Unblock:  sudo bash youtube-blocker.sh unblock  (needs password file)
# Reblock:  sudo bash youtube-blocker.sh reblock
# ============================================================================

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────
BLOCK_MARKER="## YOUTUBE-BLOCKER — DO NOT EDIT MANUALLY ##"
HOSTS_FILE="/etc/hosts"
NFT_TABLE="youtube_block"
PASSWORD_FILE="/etc/youtube-blocker/.unlock-token"
SYSTEMD_SERVICE="youtube-reblock.service"
SYSTEMD_TIMER="youtube-reblock.timer"
SYSTEMD_ALLOWANCE_SERVICE="youtube-allowance.service"
SYSTEMD_ALLOWANCE_TIMER="youtube-allowance.timer"
UNBLOCK_DURATION_MIN=30

# YouTube / Google Video domains to block in /etc/hosts
YOUTUBE_DOMAINS=(
    "youtube.com"
    "www.youtube.com"
    "m.youtube.com"
    "music.youtube.com"
    "gaming.youtube.com"
    "kids.youtube.com"
    "youtu.be"
    "youtube-nocookie.com"
    "www.youtube-nocookie.com"
    "youtubei.googleapis.com"
    "yt3.ggpht.com"
    "yt3.googleusercontent.com"
    "i.ytimg.com"
    "s.ytimg.com"
    "i9.ytimg.com"
    "img.youtube.com"
    "accounts.youtube.com"
    "consent.youtube.com"
    "studio.youtube.com"
    "tv.youtube.com"
    "redirect.googlevideo.com"
    "rr1---sn-*.googlevideo.com"
    "manifest.googlevideo.com"
    "video-stats.l.google.com"
    "suggestqueries-clients6.youtube.com"
)

# Google/YouTube ASNs and known IP ranges
# These cover the main ranges serving YouTube video content
YOUTUBE_IP_RANGES=(
    "208.65.152.0/22"
    "208.117.224.0/19"
    "209.85.128.0/17"
    "216.58.192.0/19"
    "216.239.32.0/19"
    "172.217.0.0/16"
    "142.250.0.0/15"
    "74.125.0.0/16"
    "64.233.160.0/19"
    "108.177.0.0/17"
    "173.194.0.0/16"
    "207.223.160.0/20"
    "72.14.192.0/18"
    "35.190.0.0/17"
    "35.191.0.0/16"
)

# ── Color helpers ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERR]${NC}   $*" >&2; }
die()   { err "$@"; exit 1; }

require_root() {
    [[ $EUID -eq 0 ]] || die "This script must be run as root (sudo)."
}

# ── Layer 1: nftables ──────────────────────────────────────────────────────
nft_block() {
    info "Setting up nftables firewall rules..."

    # Flush old table if exists
    nft list table inet "$NFT_TABLE" &>/dev/null && nft delete table inet "$NFT_TABLE"

    nft add table inet "$NFT_TABLE"
    nft add chain inet "$NFT_TABLE" output '{ type filter hook output priority 0; policy accept; }'

    for cidr in "${YOUTUBE_IP_RANGES[@]}"; do
        nft add rule inet "$NFT_TABLE" output ip daddr "$cidr" counter drop
        nft add rule inet "$NFT_TABLE" output ip6 daddr "$cidr" counter drop 2>/dev/null || true
    done

    ok "nftables: ${#YOUTUBE_IP_RANGES[@]} IP ranges blocked."
}

nft_unblock() {
    if nft list table inet "$NFT_TABLE" &>/dev/null; then
        nft delete table inet "$NFT_TABLE"
        ok "nftables: firewall rules removed."
    else
        info "nftables: no rules to remove."
    fi
}

nft_status() {
    if nft list table inet "$NFT_TABLE" &>/dev/null; then
        local rule_count
        rule_count=$(nft list table inet "$NFT_TABLE" | grep -c "drop" || true)
        echo -e "  Firewall:  ${RED}BLOCKED${NC} ($rule_count drop rules)"
    else
        echo -e "  Firewall:  ${GREEN}OPEN${NC}"
    fi
}

# ── Layer 2: /etc/hosts ───────────────────────────────────────────────────
hosts_block() {
    info "Adding YouTube domains to /etc/hosts..."

    # Remove old entries first
    hosts_unblock_silent

    {
        echo ""
        echo "$BLOCK_MARKER"
        for domain in "${YOUTUBE_DOMAINS[@]}"; do
            # Skip wildcard entries (hosts doesn't support them, they're for reference)
            [[ "$domain" == *'*'* ]] && continue
            echo "0.0.0.0 $domain"
            echo "::0     $domain"
        done
        echo "$BLOCK_MARKER"
    } >> "$HOSTS_FILE"

    ok "/etc/hosts: ${#YOUTUBE_DOMAINS[@]} domains redirected to 0.0.0.0."
}

hosts_unblock_silent() {
    if grep -q "$BLOCK_MARKER" "$HOSTS_FILE" 2>/dev/null; then
        sed -i "/$BLOCK_MARKER/,/$BLOCK_MARKER/d" "$HOSTS_FILE"
    fi
}

hosts_unblock() {
    hosts_unblock_silent
    ok "/etc/hosts: YouTube entries removed."
}

hosts_status() {
    if grep -q "$BLOCK_MARKER" "$HOSTS_FILE" 2>/dev/null; then
        local count
        count=$(sed -n "/$BLOCK_MARKER/,/$BLOCK_MARKER/p" "$HOSTS_FILE" | grep -c "0.0.0.0" || true)
        echo -e "  /etc/hosts: ${RED}BLOCKED${NC} ($count domain entries)"
    else
        echo -e "  /etc/hosts: ${GREEN}OPEN${NC}"
    fi
}

# ── Layer 3: Disable DNS-over-HTTPS in browsers ──────────────────────────
# (Prevents browsers from bypassing /etc/hosts via DoH)
disable_browser_doh() {
    info "Blocking known DNS-over-HTTPS endpoints..."

    local doh_domains=(
        "dns.google"
        "dns.google.com"
        "chrome.cloudflare-dns.com"
        "cloudflare-dns.com"
        "mozilla.cloudflare-dns.com"
        "doh.cleanbrowsing.org"
        "dns.nextdns.io"
        "doh.opendns.com"
    )

    # Add DoH endpoints to nftables block (port 443 to these IPs)
    # Simpler: just add them to /etc/hosts
    for domain in "${doh_domains[@]}"; do
        if ! grep -q "$domain" "$HOSTS_FILE" 2>/dev/null; then
            echo "0.0.0.0 $domain   # youtube-blocker-doh" >> "$HOSTS_FILE"
        fi
    done

    ok "DoH endpoints blocked in /etc/hosts."
}

remove_browser_doh() {
    sed -i '/# youtube-blocker-doh/d' "$HOSTS_FILE"
    ok "DoH endpoint blocks removed."
}

# ── Layer 4: Password-protected unlock ────────────────────────────────────
generate_password() {
    local dir
    dir=$(dirname "$PASSWORD_FILE")
    mkdir -p "$dir"
    chmod 700 "$dir"

    # Generate a 64-char random token
    local token
    token=$(head -c 48 /dev/urandom | base64 | tr -d '/+=' | head -c 64)

    # Store the hash, not the plaintext
    local hash
    hash=$(echo -n "$token" | sha256sum | awk '{print $1}')
    echo "$hash" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"

    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  YOUR UNLOCK TOKEN (save this somewhere INCONVENIENT):          ║${NC}"
    echo -e "${BOLD}╠══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}║${NC}                                                                  ${BOLD}║${NC}"
    echo -e "${BOLD}║${NC}  ${YELLOW}${token}${NC}  ${BOLD}║${NC}"
    echo -e "${BOLD}║${NC}                                                                  ${BOLD}║${NC}"
    echo -e "${BOLD}╠══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}║${NC}  ${RED}Print this. Give it to someone. Put it in a locked drawer.${NC}     ${BOLD}║${NC}"
    echo -e "${BOLD}║${NC}  ${RED}Do NOT save it on this laptop.${NC}                                 ${BOLD}║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

verify_password() {
    if [[ ! -f "$PASSWORD_FILE" ]]; then
        die "No password file found. Run 'install' first."
    fi

    local stored_hash
    stored_hash=$(cat "$PASSWORD_FILE")

    echo ""
    echo -e "${YELLOW}Enter your unlock token to proceed:${NC}"
    read -r -s user_token

    local user_hash
    user_hash=$(echo -n "$user_token" | sha256sum | awk '{print $1}')

    if [[ "$user_hash" != "$stored_hash" ]]; then
        die "Wrong token. Access denied."
    fi

    ok "Token verified."
}

# ── Layer 5: Protect the script and config ────────────────────────────────
harden() {
    info "Hardening file permissions..."

    # Make this script immutable (requires root to undo with chattr -i)
    local script_path
    script_path=$(realpath "$0")

    # Copy to a system location
    cp "$script_path" /usr/local/sbin/youtube-blocker
    chmod 700 /usr/local/sbin/youtube-blocker
    chown root:root /usr/local/sbin/youtube-blocker

    # Make critical files immutable
    chattr +i /usr/local/sbin/youtube-blocker 2>/dev/null || warn "chattr not available — skip immutable flag"
    chattr +i "$PASSWORD_FILE" 2>/dev/null || true

    ok "Script installed to /usr/local/sbin/youtube-blocker (immutable)."
}

# ── Systemd: auto-reblock on boot & periodic enforcement ─────────────────
install_systemd() {
    info "Installing systemd services..."

    # Service that re-applies blocks
    cat > "/etc/systemd/system/$SYSTEMD_SERVICE" <<'EOF'
[Unit]
Description=Re-apply YouTube blocks
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/youtube-blocker reblock

[Install]
WantedBy=multi-user.target
EOF

    # Timer that re-applies every 5 minutes (catches manual reverts)
    cat > "/etc/systemd/system/$SYSTEMD_TIMER" <<EOF
[Unit]
Description=Periodically re-enforce YouTube block

[Timer]
OnBootSec=30
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now "$SYSTEMD_TIMER"
    systemctl enable "$SYSTEMD_SERVICE"

    ok "Systemd: blocks re-applied on boot + every 5 minutes."
}

# ── Systemd: daily 30-min allowance window ────────────────────────────────
install_allowance_timer() {
    local allow_time="${1:-20:00}"  # default 8pm

    info "Installing 30-minute daily allowance at $allow_time..."

    cat > "/etc/systemd/system/$SYSTEMD_ALLOWANCE_SERVICE" <<EOF
[Unit]
Description=YouTube 30-min allowance window

[Service]
Type=oneshot
ExecStart=/bin/bash -c '/usr/local/sbin/youtube-blocker force-unblock && sleep ${UNBLOCK_DURATION_MIN}m && /usr/local/sbin/youtube-blocker reblock'
EOF

    cat > "/etc/systemd/system/$SYSTEMD_ALLOWANCE_TIMER" <<EOF
[Unit]
Description=Daily YouTube allowance at $allow_time

[Timer]
OnCalendar=*-*-* ${allow_time}:00
Persistent=false

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now "$SYSTEMD_ALLOWANCE_TIMER"

    ok "Allowance: YouTube unblocks daily at $allow_time for $UNBLOCK_DURATION_MIN minutes."
}

# ── Sudoers hardening ─────────────────────────────────────────────────────
harden_sudoers() {
    info "Adding sudoers restrictions..."

    local sudoers_file="/etc/sudoers.d/youtube-blocker"
    cat > "$sudoers_file" <<'EOF'
# Prevent easy editing of hosts and nftables without re-auth
# Forces password every time for these commands (no caching)
Defaults!/usr/bin/nft timestamp_timeout=0
Defaults!/usr/bin/vim timestamp_timeout=0
Defaults!/usr/bin/nvim timestamp_timeout=0
Defaults!/usr/bin/nano timestamp_timeout=0
Defaults!/usr/sbin/chattr timestamp_timeout=0
EOF

    chmod 440 "$sudoers_file"
    visudo -cf "$sudoers_file" || { rm "$sudoers_file"; die "Invalid sudoers syntax."; }

    ok "Sudoers: password required every time for nft/editors/chattr."
}

# ── Shell history trap ────────────────────────────────────────────────────
install_shell_trap() {
    info "Installing shell friction hooks..."

    local trap_script="/etc/profile.d/youtube-blocker-friction.sh"
    cat > "$trap_script" <<'SHELL'
# YouTube Blocker — friction for common revert commands
youtube_blocker_preexec() {
    local cmd="$1"
    # Catch attempts to edit /etc/hosts or mess with nft/iptables
    if echo "$cmd" | grep -qiE '(vim|nvim|nano|vi|emacs).*/etc/hosts|nft.*(delete|flush|destroy)|chattr.*-i|systemctl.*(stop|disable).*youtube'; then
        echo ""
        echo -e "\033[1;31m╔═══════════════════════════════════════════════════════════╗\033[0m"
        echo -e "\033[1;31m║  🛑  YOUTUBE BLOCKER: You're trying to revert the block  ║\033[0m"
        echo -e "\033[1;31m║                                                           ║\033[0m"
        echo -e "\033[1;31m║  Is this really what you want to spend your time on?      ║\033[0m"
        echo -e "\033[1;31m║  The block exists because you asked for it.               ║\033[0m"
        echo -e "\033[1;31m║                                                           ║\033[0m"
        echo -e "\033[1;31m║  If you TRULY need to unblock:                            ║\033[0m"
        echo -e "\033[1;31m║  sudo youtube-blocker unblock                             ║\033[0m"
        echo -e "\033[1;31m║  (requires your unlock token)                             ║\033[0m"
        echo -e "\033[1;31m╚═══════════════════════════════════════════════════════════╝\033[0m"
        echo ""
        echo -n "Type 'I WANT TO WASTE MY TIME' to continue anyway: "
        read -r confirmation
        if [[ "$confirmation" != "I WANT TO WASTE MY TIME" ]]; then
            echo "Good choice. Command cancelled."
            return 1
        fi
    fi
}

# Hook into bash preexec if available
if [[ -n "$BASH_VERSION" ]]; then
    trap 'youtube_blocker_preexec "$BASH_COMMAND"' DEBUG
fi
SHELL

    chmod 644 "$trap_script"
    ok "Shell friction: revert attempts trigger a guilt prompt."
}

# ── Commands ──────────────────────────────────────────────────────────────
cmd_install() {
    require_root

    echo ""
    echo -e "${BOLD}${CYAN}YouTube Blocker — Full Installation${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""

    # Check for nftables
    if ! command -v nft &>/dev/null; then
        warn "nftables not found. Installing..."
        if command -v pacman &>/dev/null; then
            pacman -S --noconfirm nftables
        elif command -v dnf &>/dev/null; then
            dnf install -y nftables
        fi
    fi

    # Apply all layers
    nft_block
    hosts_block
    disable_browser_doh
    generate_password
    harden
    install_systemd

    echo ""
    echo -e "${YELLOW}Would you like a daily 30-minute YouTube allowance? [y/N]${NC}"
    read -r want_allowance
    if [[ "$want_allowance" =~ ^[Yy] ]]; then
        echo -e "${YELLOW}What time? (24h format, e.g., 20:00):${NC}"
        read -r allow_time
        install_allowance_timer "${allow_time:-20:00}"
    fi

    harden_sudoers
    install_shell_trap

    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║  ✅  INSTALLATION COMPLETE                                  ║${NC}"
    echo -e "${GREEN}${BOLD}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}${BOLD}║${NC}                                                              ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}  Layers active:                                              ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    1. nftables firewall   — IP-level packet drops            ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    2. /etc/hosts           — domain-level redirect            ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    3. DoH blocking        — prevents browser DNS bypass      ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    4. Systemd timer       — re-blocks every 5 minutes        ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    5. Shell friction      — intercepts revert commands       ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    6. Password-locked     — 64-char token required           ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    7. Immutable files     — chattr +i on critical files      ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}                                                              ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}  ${RED}Now hide that unlock token somewhere inconvenient.${NC}          ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}                                                              ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

cmd_status() {
    require_root
    echo ""
    echo -e "${BOLD}YouTube Blocker Status${NC}"
    echo "─────────────────────"
    nft_status
    hosts_status

    if systemctl is-active --quiet "$SYSTEMD_TIMER" 2>/dev/null; then
        echo -e "  Reblock timer: ${RED}ACTIVE${NC} (every 5 min)"
    else
        echo -e "  Reblock timer: ${GREEN}INACTIVE${NC}"
    fi

    if systemctl is-enabled --quiet "$SYSTEMD_ALLOWANCE_TIMER" 2>/dev/null; then
        local sched
        sched=$(systemctl show "$SYSTEMD_ALLOWANCE_TIMER" -p NextElapseUSecRealtime --value 2>/dev/null || echo "unknown")
        echo -e "  Allowance:     ${CYAN}ENABLED${NC} (next: $sched)"
    else
        echo -e "  Allowance:     ${YELLOW}NOT SET${NC}"
    fi

    echo ""
}

cmd_unblock() {
    require_root
    verify_password

    warn "Temporarily unblocking YouTube..."
    # Pause the enforcement timer
    systemctl stop "$SYSTEMD_TIMER" 2>/dev/null || true

    nft_unblock
    hosts_unblock
    remove_browser_doh

    echo ""
    echo -e "${YELLOW}YouTube is unblocked. Run 'sudo youtube-blocker reblock' to re-enable.${NC}"
    echo -e "${YELLOW}The systemd enforcement timer is paused. It will resume on reboot.${NC}"
    echo ""
}

cmd_reblock() {
    require_root
    nft_block
    hosts_block
    disable_browser_doh
    ok "All layers re-applied."
}

cmd_force_unblock() {
    # Used internally by the allowance timer — no password needed
    require_root
    systemctl stop "$SYSTEMD_TIMER" 2>/dev/null || true
    nft_unblock
    hosts_unblock_silent
    remove_browser_doh
    ok "Force-unblocked for allowance window."
}

cmd_uninstall() {
    require_root
    verify_password

    warn "Removing YouTube Blocker completely..."

    # Remove immutable flags
    chattr -i /usr/local/sbin/youtube-blocker 2>/dev/null || true
    chattr -i "$PASSWORD_FILE" 2>/dev/null || true

    # Stop and remove systemd units
    systemctl stop "$SYSTEMD_TIMER" 2>/dev/null || true
    systemctl disable "$SYSTEMD_TIMER" 2>/dev/null || true
    systemctl stop "$SYSTEMD_ALLOWANCE_TIMER" 2>/dev/null || true
    systemctl disable "$SYSTEMD_ALLOWANCE_TIMER" 2>/dev/null || true
    rm -f "/etc/systemd/system/$SYSTEMD_SERVICE"
    rm -f "/etc/systemd/system/$SYSTEMD_TIMER"
    rm -f "/etc/systemd/system/$SYSTEMD_ALLOWANCE_SERVICE"
    rm -f "/etc/systemd/system/$SYSTEMD_ALLOWANCE_TIMER"
    systemctl daemon-reload

    # Remove firewall
    nft_unblock

    # Remove hosts entries
    hosts_unblock
    remove_browser_doh

    # Remove files
    rm -f /usr/local/sbin/youtube-blocker
    rm -rf /etc/youtube-blocker
    rm -f /etc/sudoers.d/youtube-blocker
    rm -f /etc/profile.d/youtube-blocker-friction.sh

    ok "YouTube Blocker completely removed."
}

# ── Main ──────────────────────────────────────────────────────────────────
case "${1:-help}" in
    install)        cmd_install ;;
    status)         cmd_status ;;
    unblock)        cmd_unblock ;;
    reblock)        cmd_reblock ;;
    force-unblock)  cmd_force_unblock ;;
    uninstall)      cmd_uninstall ;;
    *)
        echo ""
        echo -e "${BOLD}YouTube Blocker${NC} — usage:"
        echo ""
        echo "  sudo youtube-blocker install     Full installation (all layers)"
        echo "  sudo youtube-blocker status      Check current block status"
        echo "  sudo youtube-blocker unblock     Temporarily unblock (needs token)"
        echo "  sudo youtube-blocker reblock     Re-apply all blocks"
        echo "  sudo youtube-blocker uninstall   Remove everything (needs token)"
        echo ""
        ;;
esac
