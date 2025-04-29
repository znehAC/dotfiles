#!/bin/bash
# ~/.local/bin/profile.sh — record and generate a flamegraph using local Flamegraph repo

duration=${1:-30}
flamegraph_dir="$HOME/.local/Flamegraph"

# sanity check
if [[ ! -x "$flamegraph_dir/stackcollapse-perf.pl" ]]; then
  echo "❌ Flamegraph tools not found in $flamegraph_dir"
  echo "run: git clone https://github.com/brendangregg/Flamegraph.git $flamegraph_dir"
  exit 1
fi

echo "[+] Recording for ${duration}s (system-wide)..."
sudo perf record -F 99 -a -g -- sleep "$duration"

echo "[+] Translating perf.data to stack traces..."
sudo perf script > perf.out

echo "[+] Collapsing stacks..."
"$flamegraph_dir/stackcollapse-perf.pl" perf.out > out.folded

echo "[+] Rendering SVG..."
"$flamegraph_dir/flamegraph.pl" out.folded > flamegraph.svg

echo "[✓] Done. Open with: xdg-open flamegraph.svg"
