# keybinds.zsh

bindkey '^?' backward-delete-char
bindkey '^[[3~' delete-char
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

bindkey '^I'  autosuggest-accept
bindkey '^[[Z' reverse-menu-complete 
bindkey '^[[3;5~' kill-word           # ctrl+delete
bindkey '^H' backward-kill-word     # ctrl+backspace

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
