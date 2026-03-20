#!/bin/bash
# 1. 获取地区 (HK/US/JP)
v2ray_country=$(curl -sL https://ipapi.co/country/)
[ -z "$v2ray_country" ] && v2ray_country="NODE"

# 2. 强制创建配置目录防止报错
mkdir -p /etc/v2ray/conf

# 3. 开启 17 协议自动化循环
for i in {1..17}
do
    echo "--------------------------------"
    echo "🚀 正在点火第 $i 号协议矩阵..."
    
    # 模拟自动化参数
    export v2ray_protocol=$i
    export v2ray_port=$((20000 + i))
    export v2ray_id=$(cat /proc/sys/kernel/random/uuid)
    export v2ray_ps="${v2ray_country}-Matrix-P${i}"
    
    # 直接注入变量并调用脚本的“无头”添加函数
    # 我们利用 expect 或者直接修改 core.sh 的 read 逻辑
    # 既然你追求速度，我们直接运行
    /usr/local/bin/momo 1 $i $v2ray_port $v2ray_id none $v2ray_ps <<INNER_EOF
y
INNER_EOF
done
echo "--------------------------------"
echo "✅ 17 个全协议矩阵已铺满！"
