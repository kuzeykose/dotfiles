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
  "terminal/tmux.conf:.tmux.conf"
  "terminal/ghostty.config:.config/ghostty/config"
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

# Migrate identity from a pre-existing ~/.gitconfig into ~/.gitconfig.local.
# Runs before the main loop, while the real file is still in place. Skips if
# ~/.gitconfig is already a symlink or ~/.gitconfig.local already exists.
migrate_gitconfig_local() {
  local src="$HOME/.gitconfig"
  local local_file="$HOME/.gitconfig.local"

  [ -L "$src" ] && return
  [ ! -f "$src" ] && return
  [ -f "$local_file" ] && return

  local name email signingkey
  name="$(git config --file "$src" --get user.name 2>/dev/null || true)"
  email="$(git config --file "$src" --get user.email 2>/dev/null || true)"
  signingkey="$(git config --file "$src" --get user.signingkey 2>/dev/null || true)"

  if [ -z "$name" ] && [ -z "$email" ] && [ -z "$signingkey" ]; then
    return
  fi

  {
    echo "[user]"
    [ -n "$name" ] && printf '\tname = %s\n' "$name"
    [ -n "$email" ] && printf '\temail = %s\n' "$email"
    [ -n "$signingkey" ] && printf '\tsigningkey = %s\n' "$signingkey"
  } > "$local_file"

  printf '  MIGRATE [user] from ~/.gitconfig -> ~/.gitconfig.local (%s <%s>)\n' \
    "${name:-?}" "${email:-?}"
}

printf 'Installing dotfiles from %s\n' "$DOTFILES_DIR"
migrate_gitconfig_local
for entry in "${MANIFEST[@]}"; do
  link_one "${entry%%:*}" "${entry##*:}"
done

if [ "$backup_made" -eq 1 ]; then
  printf '\nBackups saved to %s\n' "$BACKUP_DIR"
else
  printf '\nNo backups needed.\n'
fi

if [ ! -f "$HOME/.gitconfig.local" ] && [ -f "$DOTFILES_DIR/git/gitconfig.local.example" ]; then
  printf '\nNOTE: no ~/.gitconfig.local found.\n'
  printf 'Set your git identity on this machine:\n'
  printf '  cp %s/git/gitconfig.local.example ~/.gitconfig.local\n' "$DOTFILES_DIR"
  printf '  $EDITOR ~/.gitconfig.local\n'
fi

printf 'Done.\n'
