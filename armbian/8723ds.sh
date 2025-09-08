#!/bin/bash
# 一键安装 RTL8723DS 驱动脚本
# 适用于 Armbian，内核需要有 headers

set -e

echo "=== 1. 安装编译环境 ==="
sudo apt update
sudo apt install -y build-essential linux-headers-$(uname -r) git

# 检查内核头文件是否存在
if [ ! -d "/lib/modules/$(uname -r)/build" ]; then
    echo "错误：未找到内核头文件，请先安装 linux-headers-$(uname -r)"
    exit 1
fi

echo "=== 2. 获取源码 ==="
if [ -d "rtl8723ds" ]; then
    echo "已存在 rtl8723ds 目录，执行 git pull 更新源码"
    cd rtl8723ds
    git pull
else
    git clone https://github.com/lwfinger/rtl8723ds.git
    cd rtl8723ds
fi

echo "=== 3. 编译驱动 ==="
make clean
make

echo "=== 4. 安装驱动到系统 ==="
sudo make install

echo "=== 5. 加载模块 ==="
sudo modprobe -v 8723ds

echo "=== 6. 检查驱动状态 ==="
dmesg | grep 8723 || echo "提示：内核日志里未找到 8723 关键字，请检查上面输出是否有错误"
ip link | grep wlan || echo "提示：未发现 wlan 接口，可能加载失败"

echo "=== 完成！ ==="
echo "如需开机自动加载，请执行：echo 8723ds | sudo tee -a /etc/modules"
