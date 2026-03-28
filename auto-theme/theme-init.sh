#!/bin/bash
# theme-init.sh — offline-first, suspend-safe auto light/dark switcher

LOGFILE="$HOME/.local/share/auto-theme/auto-theme.log"
CACHE="$HOME/.local/share/auto-theme/location.cache"

mkdir -p "$(dirname "$LOGFILE")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

# --- Location detection ---
get_location() {
    # 1. Try IP geolocation (needs internet, max 5s)
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

    # 2. Use last known location from cache
    if [[ -f "$CACHE" ]]; then
        LAT=$(awk '{print $1}' "$CACHE")
        LON=$(awk '{print $2}' "$CACHE")
        log "Location via cache: $LAT $LON"
        return
    fi

    # 3. No location available at all
    log "ERROR: Could not determine location. No internet, no cache."
    notify-send "auto-theme" "Could not determine location. Connect to internet once to initialize." 2>/dev/null || true
    exit 1
}

# --- Safe time-to-minutes conversion ---
to_minutes() {
    local t=$1
    local h m
    h=$(echo "$t" | cut -d':' -f1 | sed 's/^0*//')
    m=$(echo "$t" | cut -d':' -f2 | sed 's/^0*//')
    echo $(( ${h:-0} * 60 + ${m:-0} ))
}

# --- Theme application ---
apply_theme() {
    local mode=$1

    if gsettings set org.gnome.desktop.interface color-scheme "prefer-$mode" 2>/dev/null; then
        log "Applying $mode mode — gsettings OK"
    else
        log "WARNING: gsettings failed for $mode mode (session bus may not be ready)"
    fi

    # Add your per-app hooks here:
    # ln -sf ~/.config/alacritty/themes/$mode.toml ~/.config/alacritty/theme.toml
    # pkill -USR1 alacritty 2>/dev/null
    # pkill dunst; DUNST_THEME=$mode dunst &
    # echo "$mode" > ~/.cache/current-theme

    notify-send "Theme" "Switched to $mode mode" 2>/dev/null || true
}

# --- Cancel any existing one-shot timers safely ---
cancel_timers() {
    for unit in theme-light theme-dark; do
        systemctl --user stop         "${unit}.timer"   2>/dev/null || true
        systemctl --user stop         "${unit}.service" 2>/dev/null || true
        systemctl --user reset-failed "${unit}.service" "${unit}.timer" 2>/dev/null || true
    done
}

# --- Schedule today's timers and apply current theme ---
schedule_next() {
    get_location

    TIMES=$(sunwait list 1 $LAT $LON | tail -1)
    SUNRISE=$(echo "$TIMES" | cut -d',' -f1 | tr -d ' ')
    SUNSET=$(echo "$TIMES"  | cut -d',' -f2 | tr -d ' ')

    # Validate — also catches polar edge cases (99:99, --:--, etc.)
    if [[ ! "$SUNRISE" =~ ^[0-9]{1,2}:[0-9]{2}$ ]] || [[ ! "$SUNSET" =~ ^[0-9]{1,2}:[0-9]{2}$ ]]; then
        log "ERROR: Could not parse times from sunwait: '$TIMES' (polar region / bad output?)"
        log "Keeping current theme unchanged."
        exit 0
    fi

    log "Sunrise: $SUNRISE  Sunset: $SUNSET"
    cancel_timers

    # Integer minute arithmetic — no string comparison edge cases
    NOW_MIN=$(to_minutes "$(date +%H:%M)")
    RISE_MIN=$(to_minutes "$SUNRISE")
    SET_MIN=$(to_minutes "$SUNSET")

    # Zero-pad for systemd calendar format
    SUNRISE_PAD=$(printf "%02d:%02d" $((RISE_MIN / 60)) $((RISE_MIN % 60)))
    SUNSET_PAD=$(printf "%02d:%02d" $((SET_MIN  / 60)) $((SET_MIN  % 60)))

    # Only schedule future timers
    if (( NOW_MIN < RISE_MIN )); then
        systemd-run --user --on-calendar="${SUNRISE_PAD}:00" --unit=theme-light -- \
            bash -c "$HOME/.local/bin/theme-init.sh light" 2>/dev/null || \
            log "WARNING: Could not schedule light timer (user bus unavailable, will retry at midnight)"
        log "Scheduled light at $SUNRISE_PAD"
    fi

    if (( NOW_MIN < SET_MIN )); then
        systemd-run --user --on-calendar="${SUNSET_PAD}:00" --unit=theme-dark -- \
            bash -c "$HOME/.local/bin/theme-init.sh dark" 2>/dev/null || \
            log "WARNING: Could not schedule dark timer (user bus unavailable, will retry at midnight)"
        log "Scheduled dark at $SUNSET_PAD"
    fi

    # Apply correct theme right now
    if (( NOW_MIN >= RISE_MIN && NOW_MIN < SET_MIN )); then
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
