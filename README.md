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
├── terminal/     tmux.conf, ghostty.config
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

1. **Move** the real config file into the appropriate folder in this repo.
2. **Register** it in the `MANIFEST` array in **both** `install.sh` and
   `uninstall.sh`. Each entry is `"source:target"`, where `source` is relative
   to this repo and `target` is relative to `$HOME`.
3. **Link** it by running `./install.sh` (creates the symlink, no-op if
   already linked).
4. **Commit** the new file and manifest changes.

Example — adding a Starship prompt config at `~/.config/starship.toml`:

```sh
mv ~/.config/starship.toml ~/dotfiles/shell/starship.toml
# Edit install.sh + uninstall.sh, add to MANIFEST:
#   "shell/starship.toml:.config/starship.toml"
./install.sh
git add -A && git commit -m "Add starship config"
```

## Removing a single tracked config

When you no longer want a file managed by this repo:

1. **Unlink** the symlink in `$HOME`: `rm ~/.path/to/config`
2. **Delete** the file from the repo: `rm ~/dotfiles/<folder>/<file>`
3. **Unregister** by removing its line from `MANIFEST` in both `install.sh`
   and `uninstall.sh`.
4. **Commit** the removal.

Example — removing a tmux config:

```sh
rm ~/.tmux.conf
rm ~/dotfiles/terminal/tmux.conf
# Remove "terminal/tmux.conf:.tmux.conf" from MANIFEST in both scripts
git add -A && git commit -m "Remove tmux config"
```

## Uninstalling everything

```sh
./uninstall.sh
```

Removes every symlink this repo owns from `$HOME`. If a backup exists in
`~/.dotfiles_backup/`, the most recent copy is restored in place. The repo
itself is untouched — delete `~/dotfiles` manually if you want it gone.

## What's intentionally not tracked

- SSH keys, GPG keys, auth tokens, `.env` files (see `.gitignore`)
- Shell history, completion caches, editor swap files
- Language toolchains (`.nvm`, `.cargo`, `.rustup`, etc.)
- Framework installs like `.oh-my-zsh` — bootstrap those separately
