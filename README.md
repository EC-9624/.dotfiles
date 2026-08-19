# Dotfiles

Personal dotfiles managed with GNU Stow.

## Layout

- `home/`: files stowed into `$HOME`
- `packages/bundle`: Homebrew bundle for tools this config expects
- `dot`: helper for setup, Oh My Zsh bootstrap, restow, and basic checks
- `home/.zshenv`: minimal PATH and environment shared across zsh contexts

## Bootstrap

```bash
git clone <your-repo-url> ~/Code/dotfiles
cd ~/Code/dotfiles
./dot init
```

`./dot init` installs the Homebrew bundle, Bun, the OpenCode 2 beta, clones `~/.oh-my-zsh` when missing, and stows `home/` into `$HOME`.

## OpenCode 2

OpenCode 2 runs as an isolated `launchd` service on `0.0.0.0:4097`; OpenCode 1 remains on port `4096`. The `opencode2` shell function uses v2's isolated configuration, data, cache, and service discovery.

```bash
launchctl kickstart -k "gui/$(id -u)/ai.opencode2.serve"
opencode2 service status
opencode2 api get /api/health
opencode2 pair
```

Only expose port `4097` on trusted networks. Remote clients must use the pairing information from `opencode2 pair`.

## Themes

Tokyo Night, Rose Pine, and Catppuccin Macchiato are available through a shared terminal-native theme setup. Ghostty, Neovim, Yazi syntax, and OpenCode load theme-specific files through `~/.config/current-theme`; tmux, Starship, lazygit, btop, tmux-palette, and the Yazi interface use the terminal ANSI palette.

```bash
./dot theme tokyo-night
./dot theme rose-pine
./dot theme catppuccin
```

After switching, reload Ghostty with `Cmd+Shift+,` and restart open Neovim, Yazi, and OpenCode sessions.

## Neovim

The Neovim configuration requires Neovim 0.11 or newer. Configured formatters include Prettier, Prettierd, Stylua, and Zigfmt.

Oil handles directory editing, while Neo-tree provides a persistent project tree. FFF provides indexed project file and content search; its native binary is downloaded during plugin installation and can fall back to a local Rust toolchain. Snacks provides buffers, help, recent files, LSP and TODO pickers alongside its dashboard, notification, Git, scratch, and toggle features.

Oxfmt and `tsgo` are optional project-local tools. When present, Oxfmt takes priority over Prettier for supported files, and `tsc.nvim` finds `node_modules/.bin/tsgo` automatically.

`home/.vimrc` is a plugin-free keybinding starter for minimal Vim or Neovim installations. Neovim does not load it automatically; source it from an `init.vim` or copy the mappings when bootstrapping a separate setup.

## Commands

```bash
./dot init
./dot stow
./dot theme tokyo-night
./dot doctor
```
