# znehAC's Dotfiles

Bare Git repo for tracking my personal Linux config and setup scripts.

## 🛠️ Install

```bash
git clone --bare git@github.com:znehAC/dotfiles.git $HOME/.dotfiles
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dot config --local status.showUntrackedFiles no
dot checkout
```

## 📦 Restore System

```bash
.setup/setup.sh
```

- installs packages
- restores wallpaper, SDDM theme, user icon
- re-applies Firefox user config
- installs fonts
- sets up everything for Hyprland

## 💾 Backup Dotfiles

```bash
.setup/save.sh
```

- stages & commits tracked files
- backs up wallpaper, themes, fonts, Firefox config
- logs package list

## 🧙 Tips

- edit tracked files normally (they live in `$HOME`)
- use `dot status`, `dot add`, `dot commit` etc.
- no `.git` folder cluttering your home

> ⚠️ these dotfiles are aggressively personal and occasionally stupid.
use at your own risk. don’t judge my keybinds.
