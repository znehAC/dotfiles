# === Zsh basic setup ===
autoload -Uz compinit colors add-zsh-hook
compinit
colors
setopt prompt_subst
zstyle ':completion:*' menu select
setopt append_history

WORDCHARS=${WORDCHARS//\//}


# === History ===
HISTSIZE=500000
SAVEHIST=500000
HISTFILE=~/.zsh_history
setopt append_history
setopt hist_ignore_all_dups
setopt share_history
setopt inc_append_history
setopt extended_history

# === Plugins ===
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/catppuccin-syntax/themes/catppuccin_latte-zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

if [[ -f ~/.zprofile ]]; then
  source ~/.zprofile
fi


# === Prompt ===
eval "$(starship init zsh)"
# PROMPT='%F{cyan}%n@%m %F{yellow}%1~%f %# '
# RPROMPT=''

TRAPWINCH() {
  zle && zle reset-prompt
}

# === Aliases ===
alias ll='ls -lh'
alias gs='git status'
alias dc='docker compose'
alias docker-compose='docker compose'
alias nano='micro'
alias sudo='sudo '
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias history='atuin history list'
alias nvcc='nvcc -arch=sm_80'

wind() {
  "$HOME/.local/bin/wrappers/windsurf" "${@:-.}"
}
# === Keybinds ===
bindkey -e
source ~/.zsh/keybinds.zsh

if [[ $- == *i* ]]; then
  fastfetch
fi

# fc -R ~/.zsh_history
eval "$(atuin init zsh --disable-up-arrow)"

# === Environment ===
export PATH="$HOME/bin:$PATH"
export MICRO_TRUECOLOR=1
export MICRO_CLIPBOARD=external
export EDITOR=micro


export PATH="$HOME/.npm-global/bin:$PATH"
export PATH=/opt/cuda/bin:$PATH
