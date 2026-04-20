cat << 'EOF' > checkemmc.sh
#!/bin/sh

# ========================================================
# 脚本名称: checkemmc.sh
# 功能: 自动识别 eMMC/SD 品牌、检测寿命、清理并初始化引导区
# 更新说明: 针对东芝 0x11 ID 优化，支持 6 位十六进制解析
# ========================================================

# 品牌解析函数：精准匹配 ManfID
decode_manfid() {
    # 提取 ID 的最后两位（忽略前导零和 0x）
    local raw_id=$(echo "$1" | sed 's/0x//g' | tr '[:upper:]' '[:lower:]')
    local id=$(printf "%s" "$raw_id" | tail -c 2)
    
    case "$id" in
        "02") echo "Toshiba/Kioxia (东芝/铠侠)" ;;
        "11") echo "Toshiba (东芝)" ;;             # 针对型号 064G70 等东芝颗粒
        "13"|"2c"|"fe") echo "Micron (镁光)" ;;
        "15") echo "Samsung (三星)" ;;
        "45") echo "SanDisk (闪迪)" ;;
        "70") echo "Kingston (金士顿)" ;;
        "90"|"ad") echo "SK Hynix (海力士)" ;;
        "ae") echo "SST" ;;
        "c0") echo "BIWIN (佰维)" ;;
        "d1") echo "SigmaTel" ;;
        "e5") echo "Dahua (大华)" ;;
        *) echo "未知品牌 (0x$id)" ;;
    esac
}

# 1. 扫描所有 MMC 存储设备
echo "[*] 正在扫描存储设备..."
candidate_list=""
count=0

# 检查环境是否存在 mmc-utils
HAS_MMC=0
command -v mmc >/dev/null 2>&1 && HAS_MMC=1

for dev_path in /sys/block/mmcblk*; do
    dev_name=$(basename "$dev_path")
    
    # 获取 ManfID (厂商ID)
    manfid=$(cat "$dev_path/device/manfid" 2>/dev/null)
    [ -z "$manfid" ] && continue
    
    count=$((count + 1))
    brand=$(decode_manfid "$manfid")
    name=$(cat "$dev_path/device/name" 2>/dev/null)
    size_sectors=$(cat "$dev_path/size" 2>/dev/null)
    size_gb=$((size_sectors / 2 / 1024 / 1024))
    
    # 判断是否为 eMMC (检查是否有引导分区)
    dev_type="SD/TF Card"
    [ -d "$dev_path/${dev_name}boot0" ] && dev_type="eMMC 芯片"

    echo "[$count] 设备: /dev/$dev_name | 类型: $dev_type"
    echo "    >> 品牌: $brand | 型号: $name | 容量: ${size_gb}GB"
    candidate_list="$candidate_list $dev_name"
done

# 2. 设备确认逻辑
if [ "$count" -eq 0 ]; then
    echo "[-] 错误: 未发现任何 MMC 设备。"
    exit 1
fi

echo ""
read -p "请根据编号选择要操作的设备 [1-$count]: " selection
TARGET_DEV=$(echo $candidate_list | awk "{print \$$selection}")

if [ -z "$TARGET_DEV" ]; then
    echo "[-] 输入错误，脚本退出。"
    exit 1
fi

DEVICE="/dev/$TARGET_DEV"
SYS_PATH="/sys/block/$TARGET_DEV"

# 3. 增强型健康检测
if [ "$HAS_MMC" -eq 1 ]; then
    echo "--------------------------------------------------"
    echo "[*] 正在解析 $DEVICE 健康数据..."
    # 尝试读取 ExtCSD
    HEALTH=$(mmc extcsd read "$DEVICE" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        get_hex() {
            echo "$HEALTH" | grep -i "$1" | sed -n 's/.*\(0x[0-9a-fA-F]\{2\}\).*/\1/p' | head -n 1
        }

        decode_life() {
            case "$1" in
                "0x01") echo "0% - 10% (极佳)" ;;
                "0x02") echo "10% - 20%" ;;
                "0x0a") echo "90% - 100% (耗尽)" ;;
                *) [ -n "$1" ] && echo "使用率约 $(printf %d $1)0%" || echo "不支持" ;;
            esac
        }

        EOL=$(get_hex "Pre EOL information")
        SLC=$(get_hex "LIFE_TIME_EST_TYP_A")
        MLC=$(get_hex "LIFE_TIME_EST_TYP_B")

        echo " >> 预警状态 (EOL): $([ "$EOL" = "0x01" ] && echo "正常" || echo "异常($EOL)")"
        echo " >> SLC 区域寿命: $(decode_life $SLC)"
        echo " >> MLC 区域寿命: $(decode_life $MLC)"
    else
        echo "[!] 注意: 该设备未返回 ExtCSD 信息（可能是普通 SD 卡或底层驱动限制）。"
    fi
    echo "--------------------------------------------------"
fi

# 4. 危险操作执行阶段
echo "⚠️  绝对警告：该操作将永久抹除 $DEVICE 的引导区和分区表！"
echo "如果是当前运行系统的磁盘，设备将立即崩溃且无法再次启动。"
read -p "你确定要执行此操作吗？(请输入大写 YES 确认): " final_confirm

if [ "$final_confirm" != "YES" ]; then
    echo "操作已取消。"
    exit 0
fi

# 步骤 1: 尝试解锁 boot 分区写保护
if [ -d "$SYS_PATH/${TARGET_DEV}boot0" ]; then
    echo "[1/4] 解锁 boot0/1 写保护..."
    echo 0 > "$SYS_PATH/${TARGET_DEV}boot0/force_ro" 2>/dev/null
    echo 0 > "$SYS_PATH/${TARGET_DEV}boot1/force_ro" 2>/dev/null
    
    echo "[2/4] 正在物理擦除引导分区 (boot0/boot1)..."
    dd if=/dev/zero of="/dev/${TARGET_DEV}boot0" bs=1M count=4 status=none 2>/dev/null
    dd if=/dev/zero of="/dev/${TARGET_DEV}boot1" bs=1M count=4 status=none 2>/dev/null
    
    # 步骤 2: 重新配置引导分区使能 (JEDEC 标准)
    if [ "$HAS_MMC" -eq 1 ]; then
        echo "[3/4] 正在设置 eMMC 引导使能位 (Enable Part 1)..."
        mmc bootpart enable 7 1 "$DEVICE" 2>/dev/null
    fi
else
    echo "[1-3/4] 检测为非 eMMC 芯片，跳过引导区特定操作。"
fi

# 步骤 3: 抹除主数据区前缀 (彻底销毁分区表)
echo "[4/4] 正在抹除主分区数据 (前 100MB)..."
dd if=/dev/zero of="$DEVICE" bs=1M count=100 status=progress

echo "--------------------------------------------------"
echo "任务完成！$DEVICE 已被完全初始化。"
EOF

chmod +x checkemmc.sh
echo "[+] 脚本已就绪，请输入 ./checkemmc.sh 开始运行。"
