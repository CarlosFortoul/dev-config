#!/usr/bin/env bash
# Detect the current operating system for dev-config bootstrap.
# Echoes one of: macos | arch. Exits non-zero on anything unsupported.

detect_os() {
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "macos"
        return 0
    fi

    if [ -f /etc/arch-release ] || command -v pacman >/dev/null 2>&1; then
        echo "arch"
        return 0
    fi

    echo "dev-config: unsupported operating system (only macOS and Arch Linux are supported)." >&2
    return 1
}
