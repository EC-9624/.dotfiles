export EDITOR="nvim"
export VISUAL="nvim"

export HOMEBREW_PREFIX="/opt/homebrew"

export PNPM_HOME="$HOME/Library/pnpm"
export BUN_INSTALL="$HOME/.bun"

typeset -U path PATH
path=(
  "$HOME/.opencode/bin"
  "$HOME/.local/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.local/share/fnm/aliases/default/bin"
  "/Applications/Obsidian.app/Contents/MacOS"
  "$HOMEBREW_PREFIX/bin"
  "$HOMEBREW_PREFIX/sbin"
  "/usr/local/bin"
  "/usr/local/sbin"
  "$PNPM_HOME"
  "$HOME/.cargo/bin"
  $path
  "$HOME/go/bin"
)

export PATH
