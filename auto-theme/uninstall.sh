#!/bin/bash
# uninstall.sh — auto-theme uninstaller

USERNAME=$(whoami)

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[auto-theme]${NC} $*"; }
warn() { echo -e "${YELLOW}[auto-theme]${NC} $*"; }

# --- Stop and disable user units ---
disable_user_units() {
    info "Stopping and disabling user units..."
    for unit in theme-init.service theme-reschedule.timer theme-light.timer theme-dark.timer; do
        systemctl --user stop    "$unit" 2>/dev/null && info "  stopped $unit"
        systemctl --user disable "$unit" 2>/dev/null && info "  disabled $unit"
    done
    systemctl --user reset-failed 2>/dev/null
}

# --- Stop and disable system unit ---
disable_system_unit() {
    info "Stopping and disabling system resume hook..."
    sudo systemctl stop    "theme-resume@${USERNAME}.service" 2>/dev/null
    sudo systemctl disable "theme-resume@${USERNAME}.service" 2>/dev/null
}

# --- Remove files ---
remove_files() {
    info "Removing script..."
    rm -f "$HOME/.local/bin/theme-init.sh"

    info "Removing user systemd units..."
    rm -f "$HOME/.config/systemd/user/theme-init.service"
    rm -f "$HOME/.config/systemd/user/theme-reschedule.service"
    rm -f "$HOME/.config/systemd/user/theme-reschedule.timer"

    info "Removing system systemd unit..."
    sudo rm -f /etc/systemd/system/theme-resume@.service
    sudo rm -f /etc/systemd/system/suspend.target.wants/theme-resume@${USERNAME}.service
    sudo rm -f /etc/systemd/system/hibernate.target.wants/theme-resume@${USERNAME}.service
    sudo rm -f /etc/systemd/system/hybrid-sleep.target.wants/theme-resume@${USERNAME}.service
}

# --- Reload systemd ---
reload() {
    systemctl --user daemon-reload
    sudo systemctl daemon-reload
    info "systemd reloaded."
}

# --- Optional: remove log and cache ---
remove_data() {
    read -rp "Remove log and location cache? (~/.local/share/auto-theme/) [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.local/share/auto-theme/"
        info "Removed log and cache."
    else
        info "Kept log and cache."
    fi
}

# --- Optional: restore GTK theme ---
restore_gtk() {
    read -rp "Reset GTK color-scheme to 'default'? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        gsettings set org.gnome.desktop.interface color-scheme 'default'
        info "GTK color-scheme reset to default."
    fi
}

# --- Main ---
info "Uninstalling auto-theme..."
disable_user_units
disable_system_unit
remove_files
reload
remove_data
restore_gtk
echo ""
info "auto-theme uninstalled cleanly."
