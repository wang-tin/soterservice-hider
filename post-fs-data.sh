#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_FILE="$MODDIR/sus_path.txt"
LOG_FILE="/dev/null"

log_msg() {
    echo "$1"
}

check_and_hide_path() {
    local target_path="$1"
    local retry_time="${2:-0}"
    local retry_count=0
    local max_wait=5

    if [ "$retry_time" -gt 0 ]; then
        max_wait=$retry_time
    fi

    while [ $retry_count -lt $max_wait ]; do
        if [ -e "$target_path" ]; then
            if [ -d "$target_path" ]; then
                mkdir -p "$MODDIR/.empty_$$"
                chmod 755 "$MODDIR/.empty_$$"
                mount -o bind "$MODDIR/.empty_$$" "$target_path" 2>/dev/null
                if mount | grep -q "$target_path"; then
                    log_msg "[SoterHider] Hidden: $target_path"
                    return 0
                fi
            elif [ -f "$target_path" ]; then
                mount -o bind /dev/null "$target_path" 2>/dev/null
                if mount | grep -q "$target_path"; then
                    log_msg "[SoterHider] Hidden: $target_path"
                    return 0
                fi
            fi
        fi
        sleep 1
        retry_count=$((retry_count + 1))
    done

    if [ -e "$target_path" ]; then
        if [ -d "$target_path" ]; then
            mkdir -p "$MODDIR/.empty_$$"
            chmod 755 "$MODDIR/.empty_$$"
            mount -o bind "$MODDIR/.empty_$$" "$target_path" 2>/dev/null
            log_msg "[SoterHider] Hidden (delayed): $target_path"
        elif [ -f "$target_path" ]; then
            mount -o bind /dev/null "$target_path" 2>/dev/null
            log_msg "[SoterHider] Hidden (delayed): $target_path"
        fi
    fi
}

if [ -f "$CONFIG_FILE" ]; then
    while IFS= read -r line; do
        case "$line" in
            \#*) continue ;;
            ''*) continue ;;
            *)
                path=$(echo "$line" | awk '{print $1}')
                retry=$(echo "$line" | awk '{print $2}')
                if [ -n "$path" ]; then
                    check_and_hide_path "$path" "$retry"
                fi
                ;;
        esac
    done < "$CONFIG_FILE"
fi

rm -rf "$MODDIR/.empty_"* 2>/dev/null