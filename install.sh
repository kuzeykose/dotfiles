#!/usr/bin/env bash
# Symlink configs from this repo into $HOME. Idempotent.
# Existing non-symlink files (or symlinks pointing elsewhere) are backed up
# to ~/.dotfiles_backup/<timestamp>/ before being replaced.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.dotfiles_backup"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

# source (relative to repo) : target (relative to $HOME)
MANIFEST=(
  "shell/zshrc:.zshrc"
  "shell/zshenv:.zshenv"
  "shell/profile:.profile"
  "git/gitconfig:.gitconfig"
  "git/gitignore_global:.config/git/ignore"
  "editor/nvim:.config/nvim"
  "editor/zed/settings.json:.config/zed/settings.json"
  "editor/zed/keymap.json:.config/zed/keymap.json"
  "ssh/config:.ssh/config"
)

backup_made=0
ensure_backup_dir() {
  if [ "$backup_made" -eq 0 ]; then
    mkdir -p "$BACKUP_DIR"
    backup_made=1
  fi
}

link_one() {
  local src="$DOTFILES_DIR/$1"
  local dest="$HOME/$2"

  if [ ! -e "$src" ]; then
    printf '  SKIP    %s (source missing)\n' "$2"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      printf '  OK      %s -> %s\n' "$2" "$1"
      return
    fi
    ensure_backup_dir
    mkdir -p "$(dirname "$BACKUP_DIR/$2")"
    mv "$dest" "$BACKUP_DIR/$2"
    printf '  BACKUP  %s (was symlink -> %s)\n' "$2" "$current"
  elif [ -e "$dest" ]; then
    ensure_backup_dir
    mkdir -p "$(dirname "$BACKUP_DIR/$2")"
    mv "$dest" "$BACKUP_DIR/$2"
    printf '  BACKUP  %s -> %s\n' "$2" "$BACKUP_DIR/$2"
  fi

  ln -s "$src" "$dest"
  printf '  LINK    %s -> %s\n' "$2" "$1"
}

printf 'Installing dotfiles from %s\n' "$DOTFILES_DIR"
for entry in "${MANIFEST[@]}"; do
  link_one "${entry%%:*}" "${entry##*:}"
done

if [ "$backup_made" -eq 1 ]; then
  printf '\nBackups saved to %s\n' "$BACKUP_DIR"
else
  printf '\nNo backups needed.\n'
fi
printf 'Done.\n'
