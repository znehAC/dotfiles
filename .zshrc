# prompt
autoload -Uz colors && colors
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
setopt prompt_subst

git_branch() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  [[ -n $branch ]] && echo "%F{magenta}%B($branch)%b%f"
}

PROMPT='%F{blue}%1~%f ❯ '
RPROMPT='$(git_branch)'

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt append_history

# keybinds
bindkey -e

# suggestions + syntax
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# catppuccin theme
source ~/.config/zsh/catppuccin-syntax/themes/catppuccin_latte-zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# aliases
alias ll='ls -lh'
alias gs='git status'
alias dc='docker compose'
alias docker-compose='docker compose'
alias nano='micro'
alias sudo='sudo '

source ~/.zsh/keybinds.zsh

wind() {
  windsurf "${@:-.}" &>/dev/null &
}

TRAPWINCH() {
  zle && zle reset-prompt
}


export PATH="$HOME/bin:$PATH"
export MICRO_TRUECOLOR=1
export MICRO_CLIPBOARD=external
export EDITOR=micro
fastfetch
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
