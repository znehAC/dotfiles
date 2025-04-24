- `git clone --bare git@github.com:znehAC/dotfiles.git $HOME/.dotfiles`

- `alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'`

- `dot config --local status.showUntrackedFiles no`

- `dot checkout`
