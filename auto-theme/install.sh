#!/bin/bash
# install.sh — auto-theme installer

set -e

USERNAME=$(whoami)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[auto-theme]${NC} $*"; }
warn()  { echo -e "${YELLOW}[auto-theme]${NC} $*"; }
error() { echo -e "${RED}[auto-theme]${NC} $*"; exit 1; }

# --- Detect AUR helper ---
detect_aur() {
    for helper in paru yay; do
        if command -v "$helper" &>/dev/null; then
            AUR_HELPER="$helper"
            info "Using $AUR_HELPER"
            return
        fi
    done
    warn "No AUR helper found (paru/yay). Installing sunwait manually from AUR."
    AUR_HELPER=""
}

# --- Install sunwait ---
install_sunwait() {
    if command -v sunwait &>/dev/null; then
        info "sunwait already installed, skipping."
        return
    fi

    if [[ -n "$AUR_HELPER" ]]; then
        "$AUR_HELPER" -S --noconfirm sunwait
    else
        info "Building sunwait from AUR manually..."
        TMP=$(mktemp -d)
        git clone https://aur.archlinux.org/sunwait.git "$TMP/sunwait"
        cd "$TMP/sunwait"
        makepkg -si --noconfirm
        cd "$SCRIPT_DIR"
        rm -rf "$TMP"
    fi
}

# --- Validate repo files ---
check_files() {
    local missing=()
    for f in theme-init.sh theme-init.service theme-reschedule.service \
              theme-reschedule.timer theme-resume.service; do
        [[ ! -f "$SCRIPT_DIR/$f" ]] && missing+=("$f")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing files: ${missing[*]}\nRun this script from the repo root."
    fi
}

# --- Deploy files ---
deploy() {
    info "Installing script..."
    mkdir -p "$HOME/.local/bin"
    cp "$SCRIPT_DIR/theme-init.sh" "$HOME/.local/bin/theme-init.sh"
    chmod +x "$HOME/.local/bin/theme-init.sh"

    info "Installing user systemd units..."
    mkdir -p "$HOME/.config/systemd/user"
    cp "$SCRIPT_DIR/theme-init.service"       "$HOME/.config/systemd/user/"
    cp "$SCRIPT_DIR/theme-reschedule.service" "$HOME/.config/systemd/user/"
    cp "$SCRIPT_DIR/theme-reschedule.timer"   "$HOME/.config/systemd/user/"

    info "Installing system systemd unit..."
    sed -e "s/INSTALL_USER/${USERNAME}/g" \
        -e "s/INSTALL_UID/$(id -u)/g" \
        "$SCRIPT_DIR/theme-resume.service" \
        | sudo tee /etc/systemd/system/theme-resume@.service > /dev/null
}

# --- Enable units ---
enable_units() {
    info "Reloading systemd..."
    systemctl --user daemon-reload
    sudo systemctl daemon-reload

    info "Enabling user units..."
    systemctl --user enable --now theme-init.service
    systemctl --user enable --now theme-reschedule.timer

    info "Enabling system resume hook for $USERNAME..."
    sudo systemctl enable --now "theme-resume@${USERNAME}.service"
}

# --- Verify ---
verify() {
    echo ""
    info "Verifying installation..."
    local ok=true

    systemctl --user is-enabled theme-init.service &>/dev/null \
        && info "✓ theme-init.service enabled" \
        || { warn "✗ theme-init.service not enabled"; ok=false; }

    systemctl --user is-enabled theme-reschedule.timer &>/dev/null \
        && info "✓ theme-reschedule.timer enabled" \
        || { warn "✗ theme-reschedule.timer not enabled"; ok=false; }

    sudo systemctl is-enabled "theme-resume@${USERNAME}.service" &>/dev/null \
        && info "✓ theme-resume@${USERNAME}.service enabled" \
        || { warn "✗ theme-resume@${USERNAME}.service not enabled"; ok=false; }

    [[ -x "$HOME/.local/bin/theme-init.sh" ]] \
        && info "✓ theme-init.sh installed" \
        || { warn "✗ theme-init.sh missing"; ok=false; }

    echo ""
    if $ok; then
        info "Installation complete! Check the log with:"
        echo "    tail -f ~/.local/share/auto-theme/auto-theme.log"
    else
        warn "Installation completed with warnings. Check the output above."
    fi
}

# --- Main ---
info "Starting auto-theme installation..."
check_files
detect_aur
install_sunwait
deploy
enable_units
verify
