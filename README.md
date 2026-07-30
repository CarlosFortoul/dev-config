# dev-config

Self-bootstrapping dev environment for **macOS** and **Arch Linux**. The repo is the
single source of truth: `install.sh` installs packages and **symlinks** every config into
place, so editing a file in the repo or in `~/.config` edits the same file — no copy,
save, or sync step.

Tracks: Neovim (LazyVim), tmux + plugins, zsh + bash, git.

---

## What it does

`install.sh` runs four idempotent steps:

1. **Packages** — installs the tools listed in `packages/Brewfile` (macOS) or
   `packages/arch.txt` (Arch).
2. **Link configs** — symlinks each repo file to its home location (see [Layout](#layout)).
   Anything already there is moved to `<file>.bak.N` first — **never deleted**.
3. **Seed local files** — copies two gitignored templates into place for your
   machine-specific settings and secrets (see [Machine-specific config](#machine-specific-config)).
4. **Post-setup** — clones TPM (tmux plugin manager) and runs a headless `Lazy sync` so
   Neovim plugins install without opening the editor.

Re-run `install.sh` any time. Already-linked files are left as-is; existing `.local` files
are never overwritten.

---

## macOS setup

### 1. Command line tools + Homebrew

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After Homebrew installs, follow its final note to add `brew` to your PATH (or just open a
new shell once `~/.zprofile` is linked in step 3 — it activates brew automatically).

### 2. Clone

```sh
git clone https://github.com/CarlosFortoul/dev-config.git ~/dev-config
cd ~/dev-config
```

### 3. Install

```sh
./install.sh
```

Installs everything in `packages/Brewfile` (neovim, tmux, ripgrep, fd, fzf, lazygit, gh,
mise, node, go, python, k9s, kubectl, JetBrains Mono Nerd Font, …), links all configs,
seeds the two `.local` files, clones TPM, and syncs Neovim plugins.

### 4. Finish

See [After install](#after-install) below.

---

## Arch Linux setup

Assumes an [omarchy](https://omarchy.org)-style base (the Neovim config uses omarchy theme
hot-reload). A plain Arch install works too — you just won't get the omarchy theme sync.

### 1. Base tools

```sh
sudo pacman -S --needed git base-devel
```

Optional but recommended — an AUR helper for packages outside the core repos:

```sh
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd ..
```

### 2. Clone

```sh
git clone https://github.com/CarlosFortoul/dev-config.git ~/dev-config
cd ~/dev-config
```

### 3. Install

```sh
./install.sh
```

Runs `sudo pacman -S --needed` over `packages/arch.txt` (neovim, tmux, ripgrep, fd, fzf,
lazygit, github-cli, mise, nodejs, npm, go, python, k9s, kubectl, JetBrains Mono Nerd
Font, …), links all configs, seeds the two `.local` files, clones TPM, and syncs Neovim
plugins. If an AUR helper is missing, the script warns and skips AUR-only entries — install
those by hand.

### 4. Finish

See [After install](#after-install) below.

---

## After install

Same on both operating systems:

1. **Fill in `~/.gitconfig.local`** — name, email, commit signing. Template:
   `git/gitconfig.local.example`. Commit signing (1Password SSH) is commented out by
   default so commits work immediately; uncomment and set `signingkey` + `program` once
   you want it. macOS program path is `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`;
   Arch is `/opt/1Password/op-ssh-sign`.
2. **Fill in `~/.config/shell/local.sh`** — machine-specific shell setup and secrets.
   Template: `shell/local.sh.example`. Common entries: `mise activate`, extra PATH
   (`~/.local/bin`, windsurf), work environment variables, tokens.
3. **Install tmux plugins** — open tmux, press `prefix + I` (prefix is `Ctrl-Space`).
4. **Reload your shell** — open a new terminal (or `exec $SHELL`) so the linked rc files
   take effect.

Both `.local` files are gitignored — secrets and per-machine differences never land in the
repo.

---

## Layout

| Repo path                | Symlinked to                            | Purpose |
|--------------------------|-----------------------------------------|---------|
| `config/nvim`            | `~/.config/nvim`                        | Neovim (LazyVim) |
| `config/tmux`            | `~/.config/tmux`                        | tmux config + TPM plugin list |
| `shell/shared.sh`        | `~/.config/dev-config-shell/shared.sh`  | aliases/exports sourced by both shells |
| `shell/zshrc`            | `~/.zshrc`                              | zsh interactive (vcs_info prompt) |
| `shell/zprofile`         | `~/.zprofile`                           | login shell — OS-guarded brew activation |
| `shell/bashrc`           | `~/.bashrc`                             | bash interactive |
| `git/gitconfig`          | `~/.gitconfig`                          | portable git config + `[include]` of local |

Seeded (gitignored, not symlinked):

| Template                        | Copied to                     |
|---------------------------------|-------------------------------|
| `shell/local.sh.example`        | `~/.config/shell/local.sh`    |
| `git/gitconfig.local.example`   | `~/.gitconfig.local`          |

Package manifests: `packages/Brewfile` (macOS), `packages/arch.txt` (Arch).

---

## How it fits together

- **Shell:** the linked `~/.zshrc` / `~/.bashrc` source
  `~/.config/dev-config-shell/shared.sh` (a symlink to `shell/shared.sh`), which sources
  `~/.config/shell/local.sh` last. Portable aliases live in `shared.sh`; anything
  machine-specific overrides it in `local.sh`.
- **Git:** `~/.gitconfig` holds only portable settings and ends with
  `[include] path = ~/.gitconfig.local`, so your identity and signing stay off the repo.
- **brew activation** in `zprofile` is OS-guarded — one file works on macOS
  (`/opt/homebrew`) and Linux (`/home/linuxbrew`), and no-ops where brew is absent.

---

## Everyday use

- **Edit configs** directly in the repo (`~/dev-config/...`) or in `~/.config/...` — same
  file. Commit and push from the repo to save.
- **New machine** — clone, run `./install.sh`, fill the two `.local` files. Done.
- **Add a package** — add it to `packages/Brewfile` and/or `packages/arch.txt`, re-run
  `./install.sh`.
- **Add a tracked config** — drop the file in the repo, add a `link` line to `install.sh`,
  re-run.

---

## Recovering a replaced file

`install.sh` never deletes. If it backed something up:

```sh
ls ~/.zshrc.bak.*        # find the backup
mv ~/.zshrc.bak.0 ~/.zshrc   # restore it (removes the symlink)
```

---

## Testing without touching your real home

Run the whole thing against a throwaway `HOME`, skipping package install and post-setup:

```sh
HOME=/tmp/fakehome DEV_CONFIG_SKIP_PACKAGES=1 DEV_CONFIG_SKIP_POST=1 ./install.sh
```

Env toggles:

| Variable                     | Effect |
|------------------------------|--------|
| `DEV_CONFIG_SKIP_PACKAGES=1` | skip the package-install step |
| `DEV_CONFIG_SKIP_POST=1`     | skip TPM clone + Neovim `Lazy sync` |

---

## Requirements

- **macOS:** Xcode command line tools + Homebrew.
- **Arch:** `git` + `base-devel`; an AUR helper (`yay`/`paru`) recommended.
- A terminal set to a Nerd Font (e.g. JetBrains Mono Nerd Font). On macOS, if tmux `Alt`
  keybindings misbehave, set the terminal to send Option as Meta.
