#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_FILE="$MODDIR/sus_path.txt"
LOG_FILE="/data/adb/soter_hider.log"

echo "=== SoterService Hider Status Check ==="
echo ""

echo "Config file:"
if [ -f "$CONFIG_FILE" ]; then
    echo "  Found: $CONFIG_FILE"
    echo "  Content:"
    grep -v '^#' "$CONFIG_FILE" 2>/dev/null | grep -v '^$' | while read -r line; do
        path=$(echo "$line" | awk '{print $1}')
        echo "    - $path"
    done
else
    echo "  Not found: $CONFIG_FILE"
fi

echo ""
echo "Mount status:"
if mount | grep -q " /system_ext/app/SoterService "; then
    echo "  SUCCESS: /system_ext/app/SoterService is mounted"
    mount | grep "SoterService"
else
    echo "  NOT MOUNTED: /system_ext/app/SoterService"
fi

echo ""
echo "Directory check:"
if [ -d "/system_ext/app/SoterService" ]; then
    echo "  /system_ext/app/SoterService exists (directory)"
    ls -la "/system_ext/app/SoterService" 2>/dev/null | head -5
elif [ -f "/system_ext/app/SoterService" ]; then
    echo "  /system_ext/app/SoterService exists (file)"
    ls -la "/system_ext/app/SoterService" 2>/dev/null
elif mount | grep -q " /system_ext/app/SoterService "; then
    echo "  /system_ext/app/SoterService is hidden (mounted)"
else
    echo "  /system_ext/app/SoterService does not exist"
fi

echo ""
echo "Log file:"
if [ -f "$LOG_FILE" ]; then
    echo "  Found: $LOG_FILE"
    echo "  Last 10 entries:"
    tail -10 "$LOG_FILE"
else
    echo "  Not found: $LOG_FILE"
fi

echo ""
echo "=== Check completed ==="