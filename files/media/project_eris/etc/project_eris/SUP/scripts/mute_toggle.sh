#!/bin/sh
# mute_toggle.sh - Select + Circle to mute/unmute UI sounds
# Mute takes effect on next ui_menu load (game exit or reboot)
# PSCSTORE_SCRIPT_UPDATE_TEST=mute-toggle-marker-2026-05-29

SILENT_WAV="/media/project_eris/etc/project_eris/SUP/scripts/silent.wav"
PSCSTORE_SFX_DIR="/media/project_eris/etc/project_eris/SUP/launchers/pscstore/assets/sfx"
PERSIST_STATE="/data/project_eris_mute.state"
STATE_FILE="/tmp/mute_state"
SELECT_FILE="/tmp/mute_select_held"
CIRCLE_FILE="/tmp/mute_circle_held"
COOLDOWN_FILE="/tmp/mute_cooldown"
UPDATE_LOCK="/tmp/pscstore_update_in_progress"

# Create silent WAV if missing
if [ ! -f "$SILENT_WAV" ]; then
    printf 'RIFF$\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00"V\x00\x00D\xac\x00\x00\x02\x00\x10\x00data\x00\x00\x00\x00' > "$SILENT_WAV"
fi

apply_mounts() {
    [ -f "$UPDATE_LOCK" ] && return 0
    for f in /usr/sony/share/data/sounds/*.wav; do
        mount -o bind "$SILENT_WAV" "$f"
    done
    for f in "$PSCSTORE_SFX_DIR"/*.wav; do
        [ -e "$f" ] || continue
        mount -o bind "$SILENT_WAV" "$f"
    done
}

remove_mounts() {
    for f in /usr/sony/share/data/sounds/*.wav; do
        umount "$f" 2>/dev/null
    done
    for f in "$PSCSTORE_SFX_DIR"/*.wav; do
        [ -e "$f" ] || continue
        umount "$f" 2>/dev/null
    done
}

do_mute() {
    apply_mounts
    echo "1" > "$STATE_FILE"
    echo "1" > "$PERSIST_STATE"
}

do_unmute() {
    remove_mounts
    echo "0" > "$STATE_FILE"
    echo "0" > "$PERSIST_STATE"
}

# On boot - restore persisted mute state BEFORE ui_menu loads
if [ -f "$PERSIST_STATE" ] && [ "$(cat $PERSIST_STATE)" = "1" ]; then
    apply_mounts
    echo "1" > "$STATE_FILE"
else
    echo "0" > "$STATE_FILE"
fi

rm -f "$SELECT_FILE" "$CIRCLE_FILE" "$COOLDOWN_FILE"

while true; do
    /media/project_eris/bin/evtest /dev/input/event1 | while read line; do

        # Ignore everything except actual button events
        echo "$line" | grep -q "type 1 (EV_KEY)" || continue

        if echo "$line" | grep -q "code 314 (BTN_SELECT), value 1"; then
            touch "$SELECT_FILE"
        elif echo "$line" | grep -q "code 314 (BTN_SELECT), value 0"; then
            rm -f "$SELECT_FILE"
        fi

        if echo "$line" | grep -q "code 305 (BTN_EAST), value 1"; then
            touch "$CIRCLE_FILE"
        elif echo "$line" | grep -q "code 305 (BTN_EAST), value 0"; then
            rm -f "$CIRCLE_FILE"
        fi

        if [ -f "$SELECT_FILE" ] && [ -f "$CIRCLE_FILE" ] && [ ! -f "$COOLDOWN_FILE" ]; then
            touch "$COOLDOWN_FILE"
            if [ -f "$UPDATE_LOCK" ]; then
                rm -f "$SELECT_FILE" "$CIRCLE_FILE"
                sleep 1
                rm -f "$COOLDOWN_FILE"
                continue
            fi
            MUTED=$(cat "$STATE_FILE")
            if [ "$MUTED" = "0" ]; then
                do_mute
            else
                do_unmute
            fi
            rm -f "$SELECT_FILE" "$CIRCLE_FILE"
            sleep 1
            rm -f "$COOLDOWN_FILE"
        fi

    done
    sleep 2
done
