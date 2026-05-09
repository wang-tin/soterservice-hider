#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_FILE="$MODDIR/sus_path.txt"

add_hide_path() {
    local new_path="$1"

    if [ -z "$new_path" ]; then
        echo "Usage: add_hide_path <path>"
        return 1
    fi

    if ! grep -q "^$new_path$" "$CONFIG_FILE" 2>/dev/null; then
        echo "$new_path" >> "$CONFIG_FILE"
        echo "Added: $new_path"
    else
        echo "Path already exists: $new_path"
    fi
}

remove_hide_path() {
    local target_path="$1"

    if [ -z "$target_path" ]; then
        echo "Usage: remove_hide_path <path>"
        return 1
    fi

    sed -i "\|^$target_path$|d" "$CONFIG_FILE"
    umount "$target_path" 2>/dev/null
    echo "Removed: $target_path"
}

list_hide_paths() {
    echo "Current hidden paths:"
    grep -v '^#' "$CONFIG_FILE" | grep -v '^$'
}

"$@"