#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_FILE="$MODDIR/sus_path.txt"
LOG_FILE="/dev/null"

log_msg() {
    echo "$1"
}

ensure_hide() {
    local target_path="$1"

    if [ -e "$target_path" ]; then
        if ! mount | grep -q "$target_path"; then
            if [ -d "$target_path" ]; then
                mkdir -p "$MODDIR/.empty_$$"
                chmod 755 "$MODDIR/.empty_$$"
                mount -o bind "$MODDIR/.empty_$$" "$target_path" 2>/dev/null
            elif [ -f "$target_path" ]; then
                mount -o bind /dev/null "$target_path" 2>/dev/null
            fi
            if mount | grep -q "$target_path"; then
                log_msg "[SoterHider] Service: Hidden $target_path"
            fi
        fi
    fi
}

sleep 3

if [ -f "$CONFIG_FILE" ]; then
    while IFS= read -r line; do
        case "$line" in
            \#*) continue ;;
            ''*) continue ;;
            *)
                path=$(echo "$line" | awk '{print $1}')
                if [ -n "$path" ]; then
                    ensure_hide "$path"
                fi
                ;;
        esac
    done < "$CONFIG_FILE"
fi