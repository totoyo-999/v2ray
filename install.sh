#!/bin/bash
# totoyo-999 2026 算力矩阵 - SS2026 纯净版
warp-cli settings set-mtu 1280 || warp-cli set-custom-mtu 1280
warp-cli connect

MY_UUID=$(sing-box generate uuid)
MY_SS_KEY=$(openssl rand -base64 32)
MY_KEYPAIR=$(sing-box generate keypair)
MY_PRIVATE_KEY=$(echo "$MY_KEYPAIR" | awk '/Private key/ {print $3}')
MY_PUBLIC_KEY=$(echo "$MY_KEYPAIR" | awk '/Public key/ {print $3}')
MY_IP="68.64.181.89"

mkdir -p /etc/sing-box/
cat > /etc/sing-box/config.json <<JSON
{
  "log": { "level": "info" },
  "inbounds": [{ "type": "mixed", "listen": "::", "listen_port": 2080 }],
  "outbounds": [
    { "type": "vless", "tag": "1-vless-reality-直连", "server": "$MY_IP", "server_port": 17011, "uuid": "$MY_UUID", "tls": { "enabled": true, "server_name": "www.microsoft.com", "reality": { "enabled": true, "private_key": "$MY_PRIVATE_KEY", "short_id": ["16754"] } } },
    { "type": "shadowsocks", "tag": "2-ss-2026-直连", "server": "$MY_IP", "server_port": 29496, "method": "2022-blake3-aes-256-gcm", "password": "$MY_SS_KEY" },
    { "type": "wireguard", "tag": "warp-out", "server": "162.159.193.10", "server_port": 2408, "mtu": 1280, "system_interface": false },
    { "type": "vless", "tag": "10-vless-warp-隧道", "server": "$MY_IP", "server_port": 18414, "uuid": "$MY_UUID", "detour": "warp-out" }
  ]
}
JSON

systemctl restart sing-box
echo "--------------------------------------------------"
echo "🚀 2026 矩阵已注入 v2ray 仓库！"
echo "SS-2026 链接:"
echo "ss://$(echo -n "2022-blake3-aes-256-gcm:$MY_SS_KEY" | base64 -w0)@$MY_IP:29496#2-SS2026-Direct"
