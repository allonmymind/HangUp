#!/bin/bash

# 提示用户输入网络接口名称
echo "请输入要配置静态IP的网络接口名称（例如 eth0 或 wlan0）："
read INTERFACE

# 提示用户输入静态 IP 地址
echo "请输入静态 IP 地址："
read STATIC_IP

# 提示用户输入子网掩码（例如 255.255.255.0）
echo "请输入子网掩码："
read NETMASK

# 提示用户输入默认网关
echo "请输入网关地址："
read GATEWAY

# 提示用户输入 DNS 服务器
echo "请输入 DNS 服务器地址（多个用空格分隔）："
read DNS_SERVERS

# 配置静态 IP
echo "配置静态 IP..."
sudo nmcli con mod "$INTERFACE" ipv4.method manual ipv4.addresses "$STATIC_IP/$NETMASK" ipv4.gateway "$GATEWAY" ipv4.dns "$DNS_SERVERS"

# 启用配置
echo "启用网络连接..."
sudo nmcli con up "$INTERFACE"

# 显示配置结果
echo "静态 IP 配置已完成。当前网络配置："
nmcli device show "$INTERFACE"
