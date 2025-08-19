#!/bin/bash

# Usage function
usage() {
    echo "Usage: $0 [-w | -p | -l]"
    echo "  -w    Save config to work directory"
    echo "  -p    Save config to personal directory"
    echo "  -l    Load dev config into /.config folder"
    exit 1
}

# Parse flags
while getopts ":pwl" opt; do
  case ${opt} in
    p )
      DEST_DIR="$HOME/dev-config"
      MODE="save"
      ;;
    w )
      DEST_DIR="/mnt/c/Users/Carlos_Fortoul/dev-config"
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
NVIM_SRC_PLUGINS="$HOME/.config/nvim/lua"
NVIM_SRC_INIT="$HOME/.config/nvim/init.lua"
NVIM_SRC="$HOME/.config/nvim"
TMUX_SRC="$HOME/.config/tmux/tmux.conf"

# Define destination paths
TMUX_DST="$DEST_DIR/tmux"
NVIM_DST="$DEST_DIR/nvim"
NVIM_DST_PLUGINS="$DEST_DIR/nvim/lua"

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

# Copy Neovim and tmux configurations
if [ "$MODE" == "save" ]; then
    copy_config "$TMUX_SRC" "$TMUX_DST/tmux.conf"
    copy_config "$NVIM_SRC_INIT" "$NVIM_DST/init.lua"
    copy_config "$NVIM_SRC_PLUGINS" "$NVIM_DST_PLUGINS"
elif [ "$MODE" == "load" ]; then
    copy_config "./tmux/tmux.conf" "$TMUX_SRC"
    copy_config "./nvim" "$NVIM_SRC"
fi

