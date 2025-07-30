#!/usr/bin/env bash
# ~/.local/bin/hypr-dynrules.sh
# float browser extension / oauth pop‑ups (zen, firefox, etc.)

browsers='^(zen|firefox|chromium|brave)$'
titles='^(Extension:|[Ll]og(in|in )|[Ss]ign in|[Aa]uth|[Cc]onnect|[Cc]onfirm|[Pp]ermission|[Gg]rant)'

while sleep 0.02; do
  hyprctl clients -j | jq -c '.[] | select(.floating==false)' |
  while read -r w; do
    addr=$(jq -r .address <<<"$w")    # e.g. 0x55...
    cls=$(jq -r .class   <<<"$w")
    ttl=$(jq -r .title   <<<"$w")

    if [[ $cls =~ $browsers && $ttl =~ $titles ]]; then
      hyprctl dispatch togglefloating "address:$addr"
    fi
  done
done
