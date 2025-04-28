# === Zsh basic setup ===
autoload -Uz compinit colors add-zsh-hook
compinit
colors
setopt prompt_subst
zstyle ':completion:*' menu select
setopt append_history

# === Prompt functions ===
git_branch() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  local branch color
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [[ -n $branch ]]; then
    if ! git diff --quiet --ignore-submodules HEAD 2>/dev/null; then
      color=red  # uncommitted changes
    elif ! git diff --cached --quiet --ignore-submodules 2>/dev/null; then
      color=yellow  # staged but uncommitted
    else
      color=green  # clean
    fi
    echo "%{%F{$color}%}%B($branch)%b%{%f%}"
  fi
}

venv_info() {
  [[ -n "$VIRTUAL_ENV" ]] && echo "%{%F{green}%}🐍%{%f%} "
}

# === Prompt ===
PROMPT='$(venv_info)%{%F{blue}%}%1~%{%f%} ❯ '
RPROMPT='$(git_branch)'

# === History ===
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# === Plugins ===
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/catppuccin-syntax/themes/catppuccin_latte-zsh-syntax-highlighting.zsh

# === Aliases ===
alias ll='ls -lh'
alias gs='git status'
alias dc='docker compose'
alias docker-compose='docker compose'
alias nano='micro'
alias sudo='sudo '
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# === Keybinds ===
bindkey -e
source ~/.zsh/keybinds.zsh

# === Fastfetch on fresh terminal only ===
if [[ -z "$ZSH_SUBSHELL" && -n "$DISPLAY" ]]; then
  if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
  fi
fi

# === Winch handler for window resize ===
TRAPWINCH() {
  zle && zle reset-prompt
}

# === Environment ===
export PATH="$HOME/bin:$PATH"
export MICRO_TRUECOLOR=1
export MICRO_CLIPBOARD=external
export EDITOR=micro
