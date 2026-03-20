#!/bin/bash
# 1. 自动识别国家 (HK/US/JP)
v2ray_country=$(curl -sL https://ipapi.co/country/)
[ -z "$v2ray_country" ] && v2ray_country="NODE"

# 2. 强行补齐系统缺失的“舞台”文件，彻底堵住报错
cat <<SERVICE > /lib/systemd/system/v2ray.service
[Unit]
Description=V2Ray Service
After=network.target
[Service]
ExecStart=/usr/local/bin/v2ray run -confdir /etc/v2ray/conf
Restart=on-failure
[Install]
WantedBy=multi-user.target
SERVICE
systemctl daemon-reload

# 3. 准备配置目录
mkdir -p /etc/v2ray/conf
rm -f /etc/v2ray/conf/*.json

# 4. 开启 17 协议“随机端口”点火循环
used_ports=()

for i in {1..17}
do
    # 随机生成 10000-60000 之间的端口，并确保不重复
    while :; do
        PORT=$((RANDOM % 50001 + 10000))
        [[ ! " ${used_ports[@]} " =~ " ${PORT} " ]] && break
    done
    used_ports+=($PORT)

    UUID=$(cat /proc/sys/kernel/random/uuid)
    PS="${v2ray_country}-Matrix-P${i}"
    IP=$(curl -s ifconfig.me)
    
    # 5. 强行注入原生 JSON 配置
    cat <<JSON > /etc/v2ray/conf/config_${i}.json
{
  "inbounds": [{
    "port": $PORT,
    "protocol": "vmess",
    "settings": { "clients": [{ "id": "$UUID" }] }
  }],
  "outbounds": [{ "protocol": "freedom" }]
}
JSON

    # 6. 生成 Base64 加密的 VMess 链接
    JSON_STR="{\"v\":\"2\",\"ps\":\"$PS\",\"add\":\"$IP\",\"port\":\"$PORT\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"tcp\",\"type\":\"none\",\"path\":\"\",\"tls\":\"\"}"
    VMESS_LINK="vmess://$(echo -n $JSON_STR | base64 -w 0)"
    
    echo "--------------------------------"
    echo "🚀 第 $i 号协议点火成功: $PS"
    echo "📡 随机端口: $PORT"
    echo "🔗 链接: $VMESS_LINK"
done

# 7. 重启 V2Ray 内核
systemctl restart v2ray
echo "--------------------------------"
echo "✅ 17 个高随机性协议矩阵已全部上线！"
echo "💡 提示：所有配置已强行植入 /etc/v2ray/conf/，不再报错。"
