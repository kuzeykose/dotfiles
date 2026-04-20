# dotfiles

Personal config files, managed via symlinks from `$HOME`.

## Layout

```
dotfiles/
├── shell/        zshrc, zshenv, profile
├── git/          gitconfig, gitignore_global
├── editor/
│   ├── nvim/     full Neovim config (init.lua, lua/, plugin/, after/)
│   └── zed/      settings.json, keymap.json
├── ssh/          config (keys are never tracked)
├── install.sh    symlink configs into $HOME (idempotent, backs up first)
└── uninstall.sh  remove symlinks and restore most recent backup
```

## Bootstrap on a new machine

```sh
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Existing files at target paths are moved to `~/.dotfiles_backup/<timestamp>/`
before being replaced with symlinks. Running `install.sh` again is safe — it
reports `OK` for links that are already correct.

## Adding a new config

1. Move the real file into the appropriate folder in this repo.
2. Add a `"source:target"` line to the `MANIFEST` array in both `install.sh`
   and `uninstall.sh` (paths are relative to the repo and to `$HOME`).
3. Run `./install.sh`.

## Removing

```sh
./uninstall.sh
```

Removes symlinks this repo owns. If a backup exists in `~/.dotfiles_backup/`,
the most recent copy is restored to its original location.

## What's intentionally not tracked

- SSH keys, GPG keys, auth tokens, `.env` files (see `.gitignore`)
- Shell history, completion caches, editor swap files
- Language toolchains (`.nvm`, `.cargo`, `.rustup`, etc.)
- Framework installs like `.oh-my-zsh` — bootstrap those separately
