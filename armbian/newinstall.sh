#!/bin/bash
#$1=ubuntu,debian...
#$2=armv7,armv8,arrch64,arm64...
:<<!
echo '输入 1 到 4 之间的数字:'
echo '你输入的数字为:'
read aNum
case $aNum in
    1)  echo '你选择了 1'
    ;;
    2)  echo '你选择了 2'
    ;;
    3)  echo '你选择了 3'
    ;;
    4)  echo '你选择了 4'
    ;;
    *)  echo '你没有输入 1 到 4 之间的数字'
    ;;
esac
!




# 1.修改时区为东八区

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
echo "已修改时区为CST东八区！！！"


# 2.换源为国内清华源****$1

sudo sed -i 's/ports.$1.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

echo "已修改为国内清华源！！！"


# 3.安装更新
apt update && apt upgrade -y
Y
Y
Y
Y

echo "已完成软件更新！！！"


# 4.安装docker以及docker-compose   *************$2

curl -sSL https://get.daocloud.io/docker | sh && docker --version
#echo "显示docker版本号代表安装成功！！！"
echo "docker安装成功！！！"

wget https://ghproxy.com/https://github.com/docker/compose/releases/download/v2.11.2/docker-compose-linux-$2 -O /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && docker-compose --version
#echo "显示docker版本号代表安装成功！！！"
echo "docker-compose安装成功！！！"

#docker镜像加速
echo "{\"registry-mirrors\":[\"https://hub-mirror.c.163.com/\"]}" >> /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker
echo "docker镜像加速设置成功！！！"


#5
