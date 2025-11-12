#if [ -z "$TMUX" ]; then
#    smart-tsession.sh
#fi

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

# === zgen plugin manager ===
source /usr/share/zsh/share/zgen.zsh

# check if there's no init script
if ! zgen saved; then
    # specify plugins here
    zgen load zsh-users/zsh-autosuggestions
    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-history-substring-search
    
    # Catppuccin theme for zsh-syntax-highlighting
    zgen load catppuccin/zsh-syntax-highlighting


    # generate the init script from plugins above
    zgen save
fi

zstyle ':zsh-syntax-highlighting:*' theme 'catppuccin_latte'

if [[ -f ~/.zprofile ]]; then
  source ~/.zprofile
fi


# === Prompt ===
eval "$(starship init zsh)"
PROMPT_EOL_MARK=""

TRAPWINCH() {
  zle && zle reset-prompt
}

uvvenv() {
    uv venv "$@"
    # wait for the venv's activate script (means venv is fully created)
    while [[ ! -f .venv/bin/activate ]]; do
        sleep 0.1
    done
    if [[ ! -f .envrc ]]; then
        echo 'export VIRTUAL_ENV=".venv"; layout python' > .envrc
    fi
    direnv allow
}

alias ll='ls -lh'
alias gs='git status'
alias dc='docker compose'
alias docker-compose='docker compose'
alias nano='micro'
alias sudo='sudo '
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias history='atuin history list'
alias nvcc8='nvcc -arch=sm_80'
alias vim='nvim'

wind() {
  "$HOME/.local/bin/wrappers/windsurf" "${@:-.}"
}
# === Keybinds ===
bindkey -e
source ~/.zsh/keybinds.zsh

fastfetch

# fc -R ~/.zsh_history
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(direnv hook zsh)"
