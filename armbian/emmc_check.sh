cat << 'EOF' > checkemmc.sh
#!/bin/sh

# ========================================================
# 脚本名称: checkemmc.sh
# 功能: 自动识别 eMMC、检测寿命、清理引导区、使能引导分区
# ========================================================

# 1. 扫描所有 MMC 存储设备
echo "[*] 正在扫描 MMC 设备..."
candidate_list=""
count=0

for dev_path in /sys/block/mmcblk*; do
    dev_name=$(basename "$dev_path")
    # 过滤条件：必须拥有 boot0 分区才是 eMMC 芯片
    if [ -d "$dev_path/${dev_name}boot0" ]; then
        count=$((count + 1))
        manfid=$(cat "$dev_path/device/manfid" 2>/dev/null)
        name=$(cat "$dev_path/device/name" 2>/dev/null)
        size_sectors=$(cat "$dev_path/size" 2>/dev/null)
        size_gb=$((size_sectors / 2 / 1024 / 1024))
        
        echo "[$count] 设备: /dev/$dev_name | 品牌ID: $manfid | 型号: $name | 容量: ${size_gb}GB"
        candidate_list="$candidate_list $dev_name"
    fi
done

# 2. 设备确认逻辑
if [ "$count" -eq 0 ]; then
    echo "[-] 错误: 未发现任何 eMMC 设备。"
    exit 1
elif [ "$count" -eq 1 ]; then
    TARGET_DEV=$(echo $candidate_list | awk '{print $1}')
    echo "[!] 自动锁定唯一设备: /dev/$TARGET_DEV"
else
    echo ""
    read -p "监测到多个设备，请输入编号 [1-$count]: " selection
    TARGET_DEV=$(echo $candidate_list | awk "{print \$$selection}")
    [ -z "$TARGET_DEV" ] && echo "[-] 输入错误" && exit 1
fi

DEVICE="/dev/$TARGET_DEV"
SYS_PATH="/sys/block/$TARGET_DEV"

# 3. 增强型健康检测
if command -v mmc >/dev/null 2>&1; then
    echo "--------------------------------------------------"
    echo "[*] 正在解析 $DEVICE 健康数据 (ExtCSD)..."
    HEALTH=$(mmc extcsd read "$DEVICE")

    # 提取函数：兼容不同版本的 mmc-utils 输出格式
    get_hex() {
        echo "$HEALTH" | grep -i "$1" | sed -n 's/.*\(0x[0-9a-fA-F]\{2\}\).*/\1/p' | head -n 1
    }

    decode_life() {
        case "$1" in
            "0x01") echo "0% - 10% (极佳)" ;;
            "0x02") echo "10% - 20%" ;;
            "0x03") echo "20% - 30%" ;;
            "0x04") echo "30% - 40%" ;;
            "0x05") echo "40% - 50%" ;;
            "0x06") echo "50% - 60%" ;;
            "0x07") echo "60% - 70%" ;;
            "0x08") echo "70% - 80% (警告)" ;;
            "0x09") echo "80% - 90% (临界)" ;;
            "0x0a") echo "90% - 100% (耗尽)" ;;
            *) echo "未知/不支持 ($1)" ;;
        esac
    }

    EOL=$(get_hex "Pre EOL information")
    SLC=$(get_hex "LIFE_TIME_EST_TYP_A")
    MLC=$(get_hex "LIFE_TIME_EST_TYP_B")

    echo " >> 预警状态 (EOL): $([ "$EOL" = "0x01" ] && echo "正常" || echo "异常($EOL)")"
    echo " >> SLC 区域寿命: $(decode_life $SLC)"
    echo " >> MLC 区域寿命: $(decode_life $MLC)"
    echo "--------------------------------------------------"
else
    echo "[!] 警告: 未找到 mmc-utils 工具，跳过详细健康检测。"
fi

# 4. 执行操作
read -p "确定要擦除引导区并初始化 $DEVICE 吗？(y/N): " final_confirm
[ "$final_confirm" != "y" ] && echo "已取消操作。" && exit 0

echo "[1/4] 解锁 boot0/1 写保护..."
echo 0 > "$SYS_PATH/${TARGET_DEV}boot0/force_ro" 2>/dev/null
echo 0 > "$SYS_PATH/${TARGET_DEV}boot1/force_ro" 2>/dev/null

echo "[2/4] 彻底擦除引导分区 (各 4MB)..."
dd if=/dev/zero of="/dev/${TARGET_DEV}boot0" bs=1M status=none 2>/dev/null
dd if=/dev/zero of="/dev/${TARGET_DEV}boot1" bs=1M status=none 2>/dev/null

echo "[3/4] 写入引导配置 (Enable Boot Part 1)..."
if command -v mmc >/dev/null 2>&1; then
    mmc bootpart enable 7 1 "$DEVICE"
    # 验证位 0x38 = 00111000 (Partition 1 enabled, Ack enabled)
    CONF=$(mmc extcsd read "$DEVICE" | grep "Boot configuration bytes" | sed -n 's/.*\(0x[0-9a-fA-F]\{2\}\).*/\1/p')
    [ "$CONF" = "0x38" ] && echo " >> 配置验证成功: $CONF" || echo " >> 验证提醒: 配置值为 $CONF"
fi

echo "[4/4] 抹除主分区表 (前 100MB)..."
dd if=/dev/zero of="$DEVICE" bs=1M count=100 status=progress

echo "--------------------------------------------------"
echo "所有操作已完成！设备已准备就绪。"
EOF

chmod +x checkemmc.sh
echo "[+] 脚本 checkemmc.sh 已创建并赋予执行权限。"