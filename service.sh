#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_FILE="$MODDIR/sus_path.txt"
EMPTY_DIR="$MODDIR/empty"

mkdir -p "$EMPTY_DIR"
chmod 755 "$EMPTY_DIR"

hide_path() {
    local target="$1"
    
    if [ ! -e "$target" ]; then
        return 1
    fi
    
    if mount 2>/dev/null | grep -q "$target"; then
        return 0
    fi
    
    if [ -d "$target" ]; then
        mount -o bind "$EMPTY_DIR" "$target" 2>/dev/null
        if mount 2>/dev/null | grep -q "$target"; then
            echo "[SoterHider] Service: Hidden directory: $target"
            return 0
        fi
    elif [ -f "$target" ]; then
        mount -o bind /dev/null "$target" 2>/dev/null
        if mount 2>/dev/null | grep -q "$target"; then
            echo "[SoterHider] Service: Hidden file: $target"
            return 0
        fi
    fi
    return 1
}

sleep 5

if [ -f "$CONFIG_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        case "$line" in
            ""|\#*) continue ;;
        esac
        
        target_path="${line%% *}"
        
        if [ -n "$target_path" ] && [ "${target_path:0:1}" = "/" ]; then
            hide_path "$target_path"
        fi
    done < "$CONFIG_FILE"
fi