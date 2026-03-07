. "$HOME/.cargo/env"

if [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"

  case ":$PATH:" in
    *":$HOMEBREW_PREFIX/bin:"*) ;;
    *) export PATH="$HOMEBREW_PREFIX/bin:$PATH" ;;
  esac

  case ":$PATH:" in
    *":$HOMEBREW_PREFIX/sbin:"*) ;;
    *) export PATH="$HOMEBREW_PREFIX/sbin:$PATH" ;;
  esac
fi
