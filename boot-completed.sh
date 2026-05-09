#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_FILE="$MODDIR/sus_path.txt"
EMPTY_DIR="$MODDIR/empty"
LOG_FILE="/data/adb/soter_hider.log"

mkdir -p "$EMPTY_DIR"
chmod 755 "$EMPTY_DIR"

touch "$LOG_FILE" 2>/dev/null
chmod 644 "$LOG_FILE" 2>/dev/null

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "=== SoterService Hider (boot-completed) started ==="

setenforce 0 2>/dev/null

hide_path() {
    local target="$1"
    local retries="${2:-3}"
    local delay="${3:-2}"
    local attempt=0
    
    while [ $attempt -lt $retries ]; do
        if [ -e "$target" ] || [ -L "$target" ]; then
            break
        fi
        attempt=$((attempt + 1))
        [ $attempt -lt $retries ] && sleep "$delay"
    done
    
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        log "BootCompleted: Path not exists: $target"
        echo "[SoterHider] Path not exists: $target"
        return 1
    fi
    
    if mount | grep -q " $target "; then
        log "BootCompleted: Already hidden: $target"
        echo "[SoterHider] Already hidden: $target"
        return 0
    fi
    
    local mount_result=1
    
    if [ -d "$target" ]; then
        mount -o bind "$EMPTY_DIR" "$target" 2>/dev/null
        mount_result=$?
        
        if [ $mount_result -ne 0 ]; then
            mount --bind "$EMPTY_DIR" "$target" 2>/dev/null
            mount_result=$?
        fi
        
        if [ $mount_result -eq 0 ] && mount | grep -q " $target "; then
            log "BootCompleted: Successfully hidden directory: $target"
            echo "[SoterHider] BootCompleted: Hidden directory: $target"
            return 0
        fi
    elif [ -f "$target" ] || [ -L "$target" ]; then
        mount -o bind /dev/null "$target" 2>/dev/null
        mount_result=$?
        
        if [ $mount_result -ne 0 ]; then
            mount --bind /dev/null "$target" 2>/dev/null
            mount_result=$?
        fi
        
        if [ $mount_result -eq 0 ] && mount | grep -q " $target "; then
            log "BootCompleted: Successfully hidden file: $target"
            echo "[SoterHider] BootCompleted: Hidden file: $target"
            return 0
        fi
    fi
    
    log "BootCompleted: Failed to hide: $target"
    return 1
}

sleep 10

if [ -f "$CONFIG_FILE" ]; then
    log "BootCompleted: Reading config file: $CONFIG_FILE"
    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        case "$line" in
            ""|\#*) continue ;;
        esac
        
        target_path=$(echo "$line" | awk '{print $1}')
        
        if [ -n "$target_path" ] && [ "${target_path:0:1}" = "/" ]; then
            log "BootCompleted: Processing path: $target_path"
            hide_path "$target_path"
        fi
    done < "$CONFIG_FILE"
else
    log "BootCompleted: Config file not found: $CONFIG_FILE"
fi

setenforce 1 2>/dev/null
log "=== SoterService Hider (boot-completed) completed ==="