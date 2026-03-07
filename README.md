# Dotfiles

Personal dotfiles managed with GNU Stow.

## Layout

- `home/`: files stowed into `$HOME`
- `packages/bundle`: minimal Homebrew bundle for tools this config expects
- `dot`: helper for setup, restow, and basic checks

## Bootstrap

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./dot init
```

## Commands

```bash
./dot init
./dot stow
./dot doctor
```

## Notes

- Keep secrets in local-only files such as `~/.zshrc.local`.
- `home/.config/opencode/opencode.json.tui-migration.bak` is intentionally tracked.
- `home/.config/opencode/node_modules/` and `home/.config/opencode/resources/repos/` stay untracked.
