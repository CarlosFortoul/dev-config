# macOS setup downloads

Use this checklist on the new MacBook Pro before loading the config.

## 1. Apple command line tools

```sh
xcode-select --install
```

## 2. Homebrew

Install Homebrew from https://brew.sh, then install the required tools:

```sh
brew install git neovim tmux node ripgrep fd fzf lazygit tree-sitter go python shellcheck
```

Recommended terminal/font extras:

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

If you use iTerm2:

```sh
brew install --cask iterm2
```

## 3. Clone and load this repo

```sh
git clone https://github.com/CarlosFortoul/dev-config.git ~/dev-config
cd ~/dev-config
bash ./dev-env.sh -l
```

## 4. tmux plugins

TPM is required for the tmux plugins listed in `tmux/tmux.conf`.

```sh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

Start tmux, then press `Ctrl-Space` followed by `I` to install plugins.

## 5. Neovim plugins and language tools

Open Neovim once:

```sh
nvim
```

Lazy.nvim will install plugins automatically. Mason will install the configured language servers:

- `lua_ls`
- `pyright`
- `gopls`

Useful optional Mason packages for this config:

```vim
:MasonInstall stylua shfmt prettier
```

## 6. Terminal settings

Use a Nerd Font in your terminal, such as JetBrainsMono Nerd Font. If tmux `Alt` keybindings do not work on macOS, configure the terminal to send Option as Meta.
