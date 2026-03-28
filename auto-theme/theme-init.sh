#!/bin/bash
# theme-init.sh — offline-first, suspend-safe auto light/dark switcher
# Handles: location detection, suspend/resume, timezone changes, unit collisions

LOGFILE="$HOME/.local/share/auto-theme/auto-theme.log"
CACHE="$HOME/.local/share/auto-theme/location.cache"

mkdir -p "$(dirname "$LOGFILE")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

# --- Location detection ---
get_location() {
    # 1. Try geoclue with up to 15s wait (longer for cold boot)
    if command -v /usr/lib/geoclue-2.0/demos/where-am-i &>/dev/null; then
        RESULT=$(/usr/lib/geoclue-2.0/demos/where-am-i -t 15 2>/dev/null)
        RAW_LAT=$(echo "$RESULT" | grep -oP 'Latitude:\s*\K[-\d.]+')
        RAW_LON=$(echo "$RESULT" | grep -oP 'Longitude:\s*\K[-\d.]+')
        if [[ -n "$RAW_LAT" && -n "$RAW_LON" ]]; then
            LAT=$(echo "$RAW_LAT" | tr -d '-')$([ "${RAW_LAT:0:1}" = "-" ] && echo "S" || echo "N")
            LON=$(echo "$RAW_LON" | tr -d '-')$([ "${RAW_LON:0:1}" = "-" ] && echo "W" || echo "E")
            log "Location via geoclue: $LAT $LON"
            echo "$LAT $LON" > "$CACHE"
            return
        fi
    fi

    # 2. Try IP geolocation (needs internet, max 5s)
    RESULT=$(curl -sf --max-time 5 "https://ipinfo.io/json" 2>/dev/null)
    if [[ -n "$RESULT" ]]; then
        COORDS=$(echo "$RESULT" | grep -oP '"loc":\s*"\K[^"]+')
        RAW_LAT=$(echo "$COORDS" | cut -d',' -f1)
        RAW_LON=$(echo "$COORDS" | cut -d',' -f2)
        if [[ -n "$RAW_LAT" ]]; then
            LAT=$(echo "$RAW_LAT" | tr -d '-')$([ "${RAW_LAT:0:1}" = "-" ] && echo "S" || echo "N")
            LON=$(echo "$RAW_LON" | tr -d '-')$([ "${RAW_LON:0:1}" = "-" ] && echo "W" || echo "E")
            log "Location via IP: $LAT $LON"
            echo "$LAT $LON" > "$CACHE"
            return
        fi
    fi

    # 3. Use last known location from cache
    if [[ -f "$CACHE" ]]; then
        LAT=$(awk '{print $1}' "$CACHE")
        LON=$(awk '{print $2}' "$CACHE")
        log "Location via cache: $LAT $LON"
        return
    fi

    # 4. No location available at all
    log "ERROR: Could not determine location. No geoclue, no internet, no cache."
    log "Connect to the internet once and rerun: ~/.local/bin/theme-init.sh"
    notify-send "auto-theme" "Could not determine location. Connect to internet once to initialize." 2>/dev/null
    exit 1
}

# --- Theme application ---
apply_theme() {
    local mode=$1
    log "Applying $mode mode"

    # GTK
    gsettings set org.gnome.desktop.interface color-scheme "prefer-$mode"

    # Add your per-app hooks here:
    # Example app hook for alacritty:
    # ln -sf ~/.config/alacritty/themes/$mode.toml ~/.config/alacritty/theme.toml
    # pkill -USR1 alacritty 2>/dev/null
    # echo "$mode" > ~/.cache/current-theme

    notify-send "Theme" "Switched to $mode mode" --icon=weather-clear 2>/dev/null
}

# --- Cancel any existing one-shot timers safely ---
cancel_timers() {
    for unit in theme-light theme-dark; do
        systemctl --user stop "${unit}.timer" 2>/dev/null
        systemctl --user stop "${unit}.service" 2>/dev/null
        # reset-failed so systemd-run can reuse the unit name
        systemctl --user reset-failed "${unit}.service" "${unit}.timer" 2>/dev/null
    done
}

# --- Schedule today's timers and apply current theme ---
schedule_next() {
    get_location

    TIMES=$(sunwait list 1 $LAT $LON | tail -1)
    SUNRISE=$(echo "$TIMES" | cut -d',' -f1 | tr -d ' ')
    SUNSET=$(echo "$TIMES"  | cut -d',' -f2 | tr -d ' ')

    if [[ ! "$SUNRISE" =~ ^[0-9]{2}:[0-9]{2}$ ]] || [[ ! "$SUNSET" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
        log "ERROR: Could not parse times from sunwait: '$TIMES'"
        exit 1
    fi

    log "Sunrise: $SUNRISE  Sunset: $SUNSET"
    cancel_timers

    NOW=$(date +%H:%M)

    # Only schedule future timers — skip ones that already passed today
    if [[ "$NOW" < "$SUNRISE" ]]; then
        systemd-run --user --on-calendar="${SUNRISE}:00" --unit=theme-light -- \
            bash -c "$HOME/.local/bin/theme-init.sh light"
        log "Scheduled light at $SUNRISE"
    fi

    if [[ "$NOW" < "$SUNSET" ]]; then
        systemd-run --user --on-calendar="${SUNSET}:00" --unit=theme-dark -- \
            bash -c "$HOME/.local/bin/theme-init.sh dark"
        log "Scheduled dark at $SUNSET"
    fi

    # Apply correct theme right now
    if [[ "$NOW" > "$SUNRISE" && "$NOW" < "$SUNSET" ]]; then
        apply_theme light
    else
        apply_theme dark
    fi
}

# --- Entrypoint ---
case "$1" in
    light)    apply_theme light ;;
    dark)     apply_theme dark ;;
    schedule) schedule_next ;;
    *)        schedule_next ;;
esac
