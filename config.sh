#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_FILE="$MODDIR/sus_path.txt"

add_path() {
    local new_path="$1"
    
    if [ -z "$new_path" ]; then
        echo "ERROR: No path provided"
        return 1
    fi
    
    if ! echo "$new_path" | grep -q "^/"; then
        echo "ERROR: Path must start with /"
        return 1
    fi
    
    if grep -q "^$new_path$" "$CONFIG_FILE" 2>/dev/null; then
        echo "ERROR: Path already exists"
        return 1
    fi
    
    echo "$new_path" >> "$CONFIG_FILE"
    echo "SUCCESS: Added $new_path"
    return 0
}

remove_path() {
    local target_path="$1"
    
    if [ -z "$target_path" ]; then
        echo "ERROR: No path provided"
        return 1
    fi
    
    sed -i "\|^$target_path$|d" "$CONFIG_FILE"
    echo "SUCCESS: Removed $target_path"
    return 0
}

list_paths() {
    grep -v '^#' "$CONFIG_FILE" | grep -v '^$' | awk '{print $1}'
}

case "$1" in
    add)
        add_path "$2"
        ;;
    remove)
        remove_path "$2"
        ;;
    list)
        list_paths
        ;;
    *)
        echo "Usage: $0 {add|remove|list} [path]"
        exit 1
        ;;
esac