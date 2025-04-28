#!/bin/bash
set -e

echo "[+] Killing qbittorrent and socat"
sudo pkill -f qbittorrent-nox || true
sudo pkill -f "socat TCP-LISTEN:1111" || true

echo "[+] Killing namespace and veth"
sudo ip netns del vpnns 2>/dev/null || true
sudo ip link del veth0 2>/dev/null || true

echo "[+] Cleaning iptables"
sudo iptables -D FORWARD -s 10.200.200.0/24 -o wlp0s20f3 -j ACCEPT 2>/dev/null || true
sudo iptables -D FORWARD -d 10.200.200.0/24 -i wlp0s20f3 -j ACCEPT 2>/dev/null || true
sudo iptables -t nat -D POSTROUTING -s 10.200.200.0/24 -o wlp0s20f3 -j MASQUERADE 2>/dev/null || true

echo "[+] All clean."
