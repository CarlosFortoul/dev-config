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
NVIM_SRC="$HOME/.config/nvim"
TMUX_SRC="$HOME/.config/tmux"

# Define destination paths
NVIM_DST="$DEST_DIR/nvim"
TMUX_DST="$DEST_DIR/tmux"

# Function to copy configuration safely
copy_config() {
    local src=$1
    local dst=$2
    if [ -d "$src" ]; then
        rm -rf "$dst"
        mkdir -p "$(dirname "$dst")"
        cp -r "$src" "$dst"
        echo "Copied $src to $dst"
    else
        echo "Source directory $src does not exist. Skipping."
    fi
}

# Copy Neovim and tmux configurations
if [ "$MODE" == "save" ]; then
    copy_config "$NVIM_SRC" "$NVIM_DST"
    copy_config "$TMUX_SRC" "$TMUX_DST"
elif [ "$MODE" == "load" ]; then
    copy_config "./nvim" "$NVIM_SRC"
    copy_config "./tmux" "$TMUX_SRC"
fi

