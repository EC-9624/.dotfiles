if [[ -n "$FNM_MULTISHELL_PATH" ]]; then
  fnm_multishell_pattern="$HOME/.local/state/fnm_multishells/*/bin"
  path=(
    "$FNM_MULTISHELL_PATH/bin"
    ${path:#$~fnm_multishell_pattern}
  )
  export PATH
fi
