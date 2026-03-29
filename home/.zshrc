# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)

# extra tab completions
fpath=(/opt/homebrew/share/zsh-completions $fpath)
source "$ZSH/oh-my-zsh.sh"

# environment
export OPENCODE_DISABLE_DEFAULT_PLUGINS=true
export OPENCODE_SERVER_URL="http://127.0.0.1:4096"

# vim editing
set -o vi

# prompt
eval "$(starship init zsh)"

# node
eval "$(fnm env --shell zsh --use-on-cd)"

# bun completions
source "$HOME/.bun/_bun"

# history (shared across terminals)
HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS

# history navigation
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey -M viins '^P' up-line-or-beginning-search
bindkey -M viins '^N' down-line-or-beginning-search

# fuzzy finder
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
if [[ -n "${LS_COLORS:-}" ]]; then
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always $realpath | head -200'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --color=always $realpath | head -200'

# plugins
source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh

# fuzzy finder keybindings only (Ctrl-R, Ctrl-T, Alt-C)
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

# smarter directory jumping (z, zi)
eval "$(zoxide init zsh)"

# command autosuggestions
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
  forward-char
  end-of-line
  vi-forward-char
  vi-end-of-line
  emacs-forward-word
  vi-forward-word
  vi-forward-word-end
  vi-add-eol
)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey -M viins '^A' autosuggest-accept

# syntax highlighting (keep this near the end of .zshrc)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# aliases
alias ls="eza --icons=always"
alias ll="eza --icons=always -l --group-directories-first"
alias la="eza --icons=always -la --group-directories-first"

# functions
function y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  cwd="$(<"$tmp")"
  if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

opencode() {
  if [[ "$#" -eq 0 ]]; then
    if [[ -n "${OPENCODE_SERVER_PASSWORD:-}" ]]; then
      command opencode attach "$OPENCODE_SERVER_URL" -p "$OPENCODE_SERVER_PASSWORD" --dir "$PWD"
    else
      command opencode attach "$OPENCODE_SERVER_URL" --dir "$PWD"
    fi
  else
    command opencode "$@"
  fi
}

# machine-specific overrides and secrets
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
