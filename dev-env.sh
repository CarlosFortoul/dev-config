#!/bin/bash

# Usage function
usage() {
    echo "Usage: $0 [-w | -p | -l]"
    echo "  -w    Save config from work directory"
    echo "  -p    Save config from personal directory"
    echo "  -l    Load dev config into /.config folder"
    exit 1
}

# Parse flags
while getopts ":pwl" opt; do
  case ${opt} in
    p )
      DEST_DIR="$HOME/Personal/dev-config"
      MODE="save"
      ;;
    w )
      DEST_DIR="/mnt/c/Users/Carlos_Fortoul/personal/dev-config"
      MODE="save"
      ;;
    l )
      MODE="load"
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
NVIM_SRC_PLUGINS="$HOME/.config/nvim/lua/plugins"
NVIM_SRC_CONFIG="$HOME/.config/nvim/lua/config"
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
    copy_config "$NVIM_SRC_PLUGINS" "$NVIM_DST_LUA/plugins"
    copy_config "$NVIM_SRC_CONFIG" "$NVIM_DST_LUA/config"
    copy_by_extension "$NVIM_SRC" "$NVIM_DST"
elif [ "$MODE" == "load" ]; then
    copy_config "./tmux/tmux.conf" "$TMUX_SRC"
    copy_config "./nvim" "$NVIM_SRC"
fi

