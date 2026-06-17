# === 1. Bootstrapping (Auto-instalação) === ZGEN_DIR="${HOME}/.zgen"
if [[ -d "$ZGEN_DIR" && ! -f "$ZGEN_DIR/zgen.zsh" ]]; then
    rm -rf "$ZGEN_DIR"
fi

if [[ ! -f "$ZGEN_DIR/zgen.zsh" ]]; then
    if [[ -f "/usr/share/zsh/share/zgen.zsh" ]]; then
        ZGEN_SOURCE="/usr/share/zsh/share/zgen.zsh"
    else
        echo "🚀 Instalando zgen localmente..."
        git clone https://github.com/tarjoilija/zgen.git "$ZGEN_DIR"
        ZGEN_SOURCE="$ZGEN_DIR/zgen.zsh"
    fi
else
    ZGEN_SOURCE="$ZGEN_DIR/zgen.zsh"
fi
source "$ZGEN_SOURCE"

# === 2. Plugins (zgen) ===
if ! zgen saved; then
    echo "📦 Instalando plugins..."
    
    zgen load zsh-users/zsh-autosuggestions
    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-history-substring-search
    
    zgen load catppuccin/zsh-syntax-highlighting "" main
    
    zgen oh-my-zsh
    
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/extract
    zgen oh-my-zsh plugins/fzf

    zgen save
fi

# === 3. Completion & Fuzzy Match ===
autoload -Uz compinit colors add-zsh-hook
compinit
colors

setopt prompt_subst
setopt append_history
setopt menu_complete

# Permite completar no meio da palavra (Fuzzy Matching)
# m:{a-zA-Z}={A-Za-z} -> case insensitive
# r:|[._-]=* r:|=* -> permite completar após separadores
# l:|=* r:|=* -> permite completar em qualquer lugar (substring)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# === 4. History ===
HISTSIZE=500000
SAVEHIST=500000
HISTFILE=~/.zsh_history
setopt hist_ignore_all_dups
setopt share_history
setopt inc_append_history
setopt extended_history

# === 5. Word Chars & UX ===
WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
WORDCHARS=${WORDCHARS//[\/\.=-]/}

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
zstyle ':zsh-syntax-highlighting:*' theme 'catppuccin_latte'

# === 6. Aliases & Functions ===
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

if [[ "$OSTYPE" == "darwin"* ]]; then
    command -v gls >/dev/null 2>&1 && alias ls='gls --color=auto'
fi

wind() {
    "$HOME/.local/bin/wrappers/windsurf" "${@:-.}"
}

uvvenv() {
    uv venv "$@"
    while [[ ! -f .venv/bin/activate ]]; do sleep 0.1; done
    if [[ ! -f .envrc ]]; then
        echo 'export VIRTUAL_ENV=".venv"; layout python' > .envrc
    fi
    direnv allow
}

# === 7. Keybinds ===
bindkey -e
[[ -f ~/.zsh/keybinds.zsh ]] && source ~/.zsh/keybinds.zsh

# === 8. Init External Tools ===
eval "$(starship init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(direnv hook zsh)"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH:$HOME/homebrew/bin"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# macOS specific path
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"

# === 9. Final Touch ===
PROMPT_EOL_MARK=""
TRAPWINCH() { zle && zle reset-prompt }

if [[ -f ~/.zprofile ]]; then
  source ~/.zprofile
fi

fastfetch
