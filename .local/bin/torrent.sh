#!/bin/bash
set -e

echo "[+] Cleaning old instances if exist..."
sudo ip netns del vpnns 2>/dev/null || true
sudo ip link del veth0 2>/dev/null || true
sudo iptables -D FORWARD -s 10.200.200.0/24 -o wlp0s20f3 -j ACCEPT 2>/dev/null || true
sudo iptables -D FORWARD -d 10.200.200.0/24 -i wlp0s20f3 -j ACCEPT 2>/dev/null || true

echo "[+] Creating namespace vpnns"
sudo ip netns add vpnns

echo "[+] Creating veth pair veth0 <-> veth1"
sudo ip link add veth0 type veth peer name veth1
sudo ip link set veth1 netns vpnns

echo "[+] Assigning IP addresses"
sudo ip addr add 10.200.200.1/24 dev veth0
sudo ip link set veth0 up
sudo ip netns exec vpnns ip addr add 10.200.200.2/24 dev veth1
sudo ip netns exec vpnns ip link set veth1 up
sudo ip netns exec vpnns ip link set lo up

echo "[+] Setting default route inside namespace"
sudo ip netns exec vpnns ip route add default via 10.200.200.1

echo "[+] Setting up NAT"
sudo iptables -I FORWARD -s 10.200.200.0/24 -o wlp0s20f3 -j ACCEPT
sudo iptables -I FORWARD -d 10.200.200.0/24 -i wlp0s20f3 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o wlp0s20f3 -j MASQUERADE

echo "[+] Bringing up WireGuard inside namespace"
sudo ip netns exec vpnns ip link add dev airvpnns type wireguard
sudo ip netns exec vpnns wg setconf airvpnns /etc/wireguard/airvpnns.conf
sudo ip netns exec vpnns ip link set up dev airvpnns

echo "[+] Setting up socat to forward WebUI"
sudo socat TCP-LISTEN:1111,fork,reuseaddr TCP:10.200.200.2:1111 > /dev/null 2>&1 & disown

echo "[+] Launching qbittorrent-nox inside vpnns"
sudo ip netns exec vpnns qbittorrent-nox --webui-port=1111 & disown
