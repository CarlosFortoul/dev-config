#!/usr/bin/env bash
# Portable shell config sourced by both zsh and bash.
# Machine-specific settings and secrets live in ~/.config/shell/local.sh (gitignored).

# ---- Aliases ----
alias n='nvim'
alias c='claude'
alias k='kubectl'
alias ks='k9s'

# ---- Python venv prompt handled by our own prompt, not the default prefix ----
export VIRTUAL_ENV_DISABLE_PROMPT=1

# ---- Machine-specific overrides / secrets (gitignored) ----
# Seeded from shell/local.sh.example by install.sh. Put brew/mise activation,
# 1Password, work env, and any tokens here.
if [ -f "$HOME/.config/shell/local.sh" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.config/shell/local.sh"
fi
