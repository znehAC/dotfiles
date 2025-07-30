#!/usr/bin/env zsh

sessions=($(tmux list-sessions -F "#{session_name}" 2>/dev/null))

for sess in $sessions; do
  attached_clients=$(tmux list-clients -t "$sess" 2>/dev/null | wc -l)
  if (( attached_clients == 0 )); then
    panes=($(tmux list-panes -t "$sess" -F "#{pane_pid}"))
    running_process=0
    for pid in $panes; do
      kids=$(pgrep -P "$pid" | grep -v -E "^(bash|zsh|fish|tmux|sh)$" | wc -l)
      if (( kids > 0 )); then
        running_process=1
        break
      fi
    done

    if (( running_process == 0 )); then
      tmux kill-session -t "$sess" &>/dev/null
    fi
  fi
done

if [[ -n "$1" ]]; then
  tmux new-session -A -s "$1"
else
  tmux new-session
fi
