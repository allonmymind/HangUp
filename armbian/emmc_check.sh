#!/bin/sh

# ========================================================
# 脚本名称: emmc_multi_tool.sh
# 优化点: 支持多 MMC 设备识别，提供交互式选择
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
        
        # 获取基础信息
        manfid=$(cat "$dev_path/device/manfid" 2>/dev/null)
        name=$(cat "$dev_path/device/name" 2>/dev/null)
        size_sectors=$(cat "$dev_path/size" 2>/dev/null)
        size_gb=$((size_sectors / 2 / 1024 / 1024))
        
        # 存入列表并显示
        echo "[$count] 设备: /dev/$dev_name | 品牌ID: $manfid | 型号: $name | 容量: ${size_gb}GB"
        candidate_list="$candidate_list $dev_name"
    fi
done

# 2. 设备确认逻辑
if [ "$count" -eq 0 ]; then
    echo "[-] 错误: 未发现任何含有引导分区的 eMMC 设备。"
    exit 1
elif [ "$count" -eq 1 ]; then
    # 只有一个设备，直接锁定
    TARGET_DEV=$(echo $candidate_list | awk '{print $1}')
    echo "[!] 自动锁定唯一设备: /dev/$TARGET_DEV"
else
    # 多个设备，要求用户选择
    echo ""
    read -p "监测到多个 eMMC 设备，请输入编号 [1-$count] 选择目标: " selection
    TARGET_DEV=$(echo $candidate_list | awk "{print \$$selection}")
    
    if [ -z "$TARGET_DEV" ]; then
        echo "[-] 输入错误，退出。"
        exit 1
    fi
fi

# 3. 路径变量初始化
DEVICE="/dev/$TARGET_DEV"
SYS_PATH="/sys/block/$TARGET_DEV"

echo "--------------------------------------------------"
echo "确认目标设备: $DEVICE"
echo "--------------------------------------------------"

# 4. 寿命检测 (mmc-utils)
if command -v mmc >/dev/null 2>&1; then
    echo "[*] 正在读取 $DEVICE 的健康数据..."
    HEALTH=$(mmc extcsd read "$DEVICE")
    EOL=$(echo "$HEALTH" | grep "Pre EOL information" | awk '{print $NF}')
    SLC=$(echo "$HEALTH" | grep "Device life time estimation \[EXT_CSD_DEVICE_LIFE_TIME_EST_TYP_A\]" | awk '{print $NF}')
    MLC=$(echo "$HEALTH" | grep "Device life time estimation \[EXT_CSD_DEVICE_LIFE_TIME_EST_TYP_B\]" | awk '{print $NF}')
    
    echo "    - 状态 (EOL): $EOL"
    echo "    - 寿命消耗 (SLC/MLC): $SLC / $MLC"
    
    if [ "$EOL" = "0x03" ]; then
        echo "警告: 该芯片状态极差，可能无法完成写入。"
    fi
fi

# 5. 执行清理与使能逻辑
read -p "最后确认：清空 $DEVICE 引导区并使能 Boot Part 1？(y/N): " final_confirm
[ "$final_confirm" != "y" ] && exit 0

echo "[1/4] 解锁 boot0/1 写保护..."
echo 0 > "$SYS_PATH/${TARGET_DEV}boot0/force_ro"
echo 0 > "$SYS_PATH/${TARGET_DEV}boot1/force_ro"

echo "[2/4] 抹除引导分区..."
dd if=/dev/zero of="/dev/${TARGET_DEV}boot0" bs=512 count=1024 status=none
dd if=/dev/zero of="/dev/${TARGET_DEV}boot1" bs=512 count=1024 status=none

echo "[3/4] 使能引导寄存器 (mmc bootpart)..."
if command -v mmc >/dev/null 2>&1; then
    mmc bootpart enable 7 1 "$DEVICE"
    # 简单校验
    mmc extcsd read "$DEVICE" | grep "Boot configuration bytes" | grep "0x38" >/dev/null
    if [ $? -eq 0 ]; then
        echo "    - 配置成功。"
    else
        echo "    - 配置失败，请检查写入保护。"
    fi
fi

echo "[4/4] 抹除主分区表 (100MB)..."
dd if=/dev/zero of="$DEVICE" bs=1M count=100 status=progress

echo "操作完毕。"