#!/usr/bin/env bash
# Symlink helper for dev-config bootstrap.
# link SOURCE DESTINATION
#   - If DESTINATION is already the correct symlink, does nothing.
#   - If DESTINATION exists (file, dir, or wrong symlink), moves it aside to a
#     non-clobbering DESTINATION.bak.<n> before linking.
#   - Creates the parent directory of DESTINATION as needed.
# Idempotent: re-running after a successful link is a no-op.

link() {
    local source="$1"
    local destination="$2"

    if [ ! -e "$source" ]; then
        echo "  skip: source $source does not exist"
        return 0
    fi

    # Already linked correctly?
    if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]; then
        echo "  ok:   $destination -> $source (already linked)"
        return 0
    fi

    # Something is in the way — back it up without clobbering an existing backup.
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        local backup="$destination.bak"
        local n=0
        while [ -e "$backup.$n" ] || [ -L "$backup.$n" ]; do
            n=$((n + 1))
        done
        mv "$destination" "$backup.$n"
        echo "  back: $destination -> $backup.$n"
    fi

    mkdir -p "$(dirname "$destination")"
    ln -sfn "$source" "$destination"
    echo "  link: $destination -> $source"
}
