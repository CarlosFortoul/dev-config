#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$SCRIPT_DIR"
MODE=""

# Usage function
usage() {
    echo "Usage: $0 [-w | -p | -l] [-d repo_dir]"
    echo "  -w    Save config to the work dev-config directory"
    echo "  -p    Save config to \$HOME/Personal/dev-config"
    echo "  -l    Load this repo's config into \$HOME/.config"
    echo "  -d    Override the dev-config repo directory"
    exit 1
}

# Parse flags
while getopts ":pwld:" opt; do
  case ${opt} in
    p )
      DEST_DIR="$HOME/Personal/dev-config"
      MODE="save"
      ;;
    w )
      if [ "$(uname -s)" = "Darwin" ]; then
        DEST_DIR="$HOME/dev-config"
      else
        DEST_DIR="/mnt/c/Users/Carlos_Fortoul/personal/dev-config"
      fi
      MODE="save"
      ;;
    l )
      MODE="load"
      ;;
    d )
      DEST_DIR="$OPTARG"
      ;;
    \? )
      usage
      ;;
  esac
done

# Ensure a flag was provided
if [ -z "$MODE" ]; then
    usage
fi

# Define source paths
NVIM_SRC_INIT="$HOME/.config/nvim/init.lua"
NVIM_SRC="$HOME/.config/nvim"
TMUX_SRC="$HOME/.config/tmux/tmux.conf"

# Define destination paths
TMUX_DST="$DEST_DIR/tmux"
NVIM_DST="$DEST_DIR/nvim"
NVIM_DST_LUA="$DEST_DIR/nvim/lua"

# Function to copy configuration safely
copy_config() {
    local src=$1
    local dst=$2

    if [ -d "$src" ]; then
        rm -rf "$dst"
        mkdir -p "$(dirname "$dst")"
        cp -r "$src" "$dst"
        echo "Copied directory $src to $dst"
    elif [ -f "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "Copied file $src to $dst"
    else
        echo "Source $src does not exist. Skipping."
    fi
}

load_config() {
    mkdir -p "$HOME/.config"
    copy_config "$DEST_DIR/tmux/tmux.conf" "$TMUX_SRC"
    copy_config "$DEST_DIR/nvim" "$NVIM_SRC"
}

copy_by_extension() {
    local src_dir=$1
    local dst_dir=$2
    local extensions=("json" "lua" "toml")

    if [ ! -d "$src_dir" ]; then
        echo "Source directory $src_dir does not exist. Skipping."
        return
    fi

    mkdir -p "$dst_dir"

    for ext in "${extensions[@]}"; do
        for file in "$src_dir"/*."$ext"; do
            [ -f "$file" ] || continue
            cp "$file" "$dst_dir/"
            echo "Copied $file to $dst_dir/"
        done
    done
}

# Copy Neovim and tmux configurations
if [ "$MODE" == "save" ]; then
    copy_config "$TMUX_SRC" "$TMUX_DST/tmux.conf"
    copy_config "$NVIM_SRC_INIT" "$NVIM_DST/init.lua"
    copy_config "$NVIM_SRC/lua/plugins" "$NVIM_DST_LUA/plugins"
    copy_config "$NVIM_SRC/lua/config" "$NVIM_DST_LUA/config"
    copy_by_extension "$NVIM_SRC" "$NVIM_DST"
elif [ "$MODE" == "load" ]; then
    load_config
fi
