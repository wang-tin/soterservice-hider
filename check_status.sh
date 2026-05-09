#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_FILE="$MODDIR/sus_path.txt"
LOG_FILE="/data/adb/soter_hider.log"

echo "=== SoterService Hider Status Check ==="
echo ""

echo "📋 Configured paths:"
if [ -f "$CONFIG_FILE" ]; then
    grep -v '^#' "$CONFIG_FILE" | grep -v '^$' | while read -r line; do
        path="${line%% *}"
        echo "  - $path"
    done
else
    echo "  No config file found"
fi

echo ""
echo "🔍 Mount status:"
mount | grep -E 'SoterService|soter' || echo "  No mounts found"

echo ""
echo "📂 Directory check:"
if [ -d "/system_ext/app/SoterService" ]; then
    content=$(ls -la "/system_ext/app/SoterService" 2>/dev/null | head -5)
    echo "  /system_ext/app/SoterService exists"
    echo "  Content (should be empty):"
    echo "  $content"
else
    echo "  /system_ext/app/SoterService does not exist"
fi

echo ""
echo "📝 Recent log entries:"
if [ -f "$LOG_FILE" ]; then
    tail -10 "$LOG_FILE"
else
    echo "  No log file found"
fi

echo ""
echo "=== Check completed ==="