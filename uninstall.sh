#!/usr/bin/env bash
# Remove symlinks created by install.sh. If a backup exists in
# ~/.dotfiles_backup/, restore the most recent one.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.dotfiles_backup"

MANIFEST=(
  "shell/zshrc:.zshrc"
  "shell/zshenv:.zshenv"
  "shell/profile:.profile"
  "git/gitconfig:.gitconfig"
  "git/gitignore_global:.config/git/ignore"
  "editor/nvim:.config/nvim"
  "editor/zed/settings.json:.config/zed/settings.json"
  "editor/zed/keymap.json:.config/zed/keymap.json"
  "terminal/tmux.conf:.tmux.conf"
)

latest_backup_for() {
  local rel="$1"
  [ -d "$BACKUP_ROOT" ] || return 1
  local found
  found="$(find "$BACKUP_ROOT" -mindepth 2 -maxdepth 6 -path "*/$rel" 2>/dev/null | sort | tail -1)"
  [ -n "$found" ] && printf '%s' "$found"
}

unlink_one() {
  local src="$DOTFILES_DIR/$1"
  local rel="$2"
  local dest="$HOME/$rel"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      rm "$dest"
      printf '  UNLINK  %s\n' "$rel"
    else
      printf '  SKIP    %s (symlink points elsewhere: %s)\n' "$rel" "$current"
      return
    fi
  elif [ -e "$dest" ]; then
    printf '  SKIP    %s (not a symlink managed by this repo)\n' "$rel"
    return
  else
    printf '  MISS    %s (nothing to remove)\n' "$rel"
  fi

  local backup
  if backup="$(latest_backup_for "$rel")" && [ -n "$backup" ]; then
    mkdir -p "$(dirname "$dest")"
    mv "$backup" "$dest"
    printf '  RESTORE %s (from %s)\n' "$rel" "$backup"
  fi
}

printf 'Uninstalling dotfiles symlinks\n'
for entry in "${MANIFEST[@]}"; do
  unlink_one "${entry%%:*}" "${entry##*:}"
done
printf 'Done.\n'
