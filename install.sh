#!/usr/bin/env bash
# dev-config bootstrap: install packages, symlink configs, seed local files, post-setup.
# Safe to re-run — every step is idempotent. Existing files are backed up, never deleted.
#
# Env toggles (mainly for testing):
#   DEV_CONFIG_SKIP_PACKAGES=1   skip the package-install step
#   DEV_CONFIG_SKIP_POST=1       skip TPM clone + Lazy sync
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/os.sh
. "$SCRIPT_DIR/lib/os.sh"
# shellcheck source=lib/link.sh
. "$SCRIPT_DIR/lib/link.sh"

OS="$(detect_os)"
echo "dev-config: detected OS = $OS"

# ---------------------------------------------------------------------------
# 1. Packages
# ---------------------------------------------------------------------------
install_packages() {
    case "$OS" in
    macos)
        if ! command -v brew >/dev/null 2>&1; then
            echo "  Homebrew not found. Install it from https://brew.sh, then re-run." >&2
            return 1
        fi
        echo "  brew bundle..."
        brew bundle --file "$SCRIPT_DIR/packages/Brewfile"
        ;;
    arch)
        echo "  pacman -S --needed..."
        grep -vE '^\s*(#|$)' "$SCRIPT_DIR/packages/arch.txt" | sudo pacman -S --needed -
        if ! command -v yay >/dev/null 2>&1 && ! command -v paru >/dev/null 2>&1; then
            echo "  note: no AUR helper (yay/paru) found — install AUR entries manually."
        fi
        ;;
    esac
}

if [ "${DEV_CONFIG_SKIP_PACKAGES:-0}" = "1" ]; then
    echo "==> Packages (skipped)"
else
    echo "==> Packages"
    install_packages
fi

# ---------------------------------------------------------------------------
# 2. Symlink configs
# ---------------------------------------------------------------------------
echo "==> Linking configs"
link "$SCRIPT_DIR/config/nvim"        "$HOME/.config/nvim"
link "$SCRIPT_DIR/config/tmux"        "$HOME/.config/tmux"
link "$SCRIPT_DIR/shell/shared.sh"    "$HOME/.config/dev-config-shell/shared.sh"
link "$SCRIPT_DIR/shell/zshrc"        "$HOME/.zshrc"
link "$SCRIPT_DIR/shell/zprofile"     "$HOME/.zprofile"
link "$SCRIPT_DIR/shell/bashrc"       "$HOME/.bashrc"
link "$SCRIPT_DIR/git/gitconfig"      "$HOME/.gitconfig"

# ---------------------------------------------------------------------------
# 3. Seed gitignored local files
# ---------------------------------------------------------------------------
echo "==> Seeding local files"
seed() {
    local template="$1" target="$2"
    if [ -e "$target" ]; then
        echo "  ok:   $target (exists, left untouched)"
    else
        mkdir -p "$(dirname "$target")"
        cp "$template" "$target"
        echo "  seed: $target (from $(basename "$template")) — fill in your values"
    fi
}
seed "$SCRIPT_DIR/shell/local.sh.example"        "$HOME/.config/shell/local.sh"
seed "$SCRIPT_DIR/git/gitconfig.local.example"   "$HOME/.gitconfig.local"

# ---------------------------------------------------------------------------
# 4. Post-setup: TPM + Lazy sync
# ---------------------------------------------------------------------------
if [ "${DEV_CONFIG_SKIP_POST:-0}" = "1" ]; then
    echo "==> Post-setup (skipped)"
else
    echo "==> Post-setup"
    TPM_DIR="$HOME/.config/tmux/plugins/tpm"
    if [ -d "$TPM_DIR" ]; then
        echo "  ok:   tpm already cloned"
    else
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    fi

    if command -v nvim >/dev/null 2>&1; then
        echo "  nvim: Lazy sync..."
        nvim --headless "+Lazy! sync" +qa || echo "  warn: Lazy sync returned non-zero"
    else
        echo "  warn: nvim not found — skipping Lazy sync"
    fi
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
cat <<'DONE'

dev-config: done.
Next steps:
  1. Fill in ~/.gitconfig.local        (name, email, signing)
  2. Fill in ~/.config/shell/local.sh  (brew/mise activation, work env, tokens)
  3. Open tmux and press  prefix + I   to install tmux plugins
  4. Open a new shell so the new rc files take effect
DONE
