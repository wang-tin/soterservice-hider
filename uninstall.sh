#!/system/bin/sh
MODDIR=${0%/*}
rm -f /data/adb/service.d/soterservice_hider_service.sh 2>/dev/null
rm -rf /data/adb/modules/soterservice_hider 2>/dev/null
rm -f /data/adb/modules_update/soterservice_hider 2>/dev/null