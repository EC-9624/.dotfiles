# Dotfiles

Personal dotfiles managed with GNU Stow.

## Layout

- `home/`: files stowed into `$HOME`
- `packages/bundle`: minimal Homebrew bundle for tools this config expects
- `dot`: helper for setup, restow, and basic checks

## Bootstrap

```bash
 git clone <your-repo-url> ~/Code/dotfiles
 cd ~/Code/dotfiles
./dot init
```

## Commands

```bash
./dot init
./dot stow
./dot doctor
```
