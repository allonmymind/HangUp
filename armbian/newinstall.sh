#!/bin/bash
#$1=ubuntu,debian...
#$2=armv7,armv8,aarch64,arm64...
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




echo "^^^^^^^^^^^^^^^^^^^^1.正在修改时区为东八区^^^^^^^^^^^^^^^^^^^^"

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

echo "####################已修改时区为CST东八区！！！##########################"


echo "^^^^^^^^^^^^^^^^^^^^2.换源为国内清华源^^^^^^^^^^^^^^^^^^^^^^^^"

sudo sed -i "s/ports.$1.com/mirrors.tuna.tsinghua.edu.cn\/$1-ports/g" /etc/apt/sources.list

echo "####################已修改为国内清华源！！!##############################"


echo "^^^^^^^^^^^^^^^^^^^^3.正在安装更新^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
apt update && apt upgrade -y
echo "###############################已完成软件更新！！！####################################"


echo "^^^^^^^^^^^^^^^^^^^^^5.正在安装docker以及docker-compose^^^^^^^^^^^^^^^^^^^^^^^"

curl -sSL https://get.daocloud.io/docker | sh && docker --version
#echo "显示docker版本号代表安装成功！！！"
echo "##############################docker安装成功！！！######################################"

wget https://ghproxy.com/https://github.com/docker/compose/releases/download/v2.11.2/docker-compose-linux-$2 -O /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && docker-compose --version
#echo "显示docker版本号代表安装成功！！！"
echo "#############################docker-compose安装成功！！！################################"

#docker镜像加速
echo "{\"registry-mirrors\":[\"https://hub-mirror.c.163.com/\"]}" >> /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker
echo "###############################docker镜像加速设置成功！！！##################################"


# 5.创建目录并下载容器配置文件
mkdir /root/clash && cd /root/clash && wget -O docker-compose.yml https://ghproxy.com/https://raw.githubusercontent.com/allonmymind/HangUp/main/armbian/docker-compose/clash.yml

mkdir /root/wxedge && cd /root/wxedge && wget -O docker-compose.yml https://ghproxy.com/https://raw.githubusercontent.com/allonmymind/HangUp/main/armbian/docker-compose/wxedge.yml

mkdir /root/xxqg && cd /root/xxqg && wget -O docker-compose.yml https://ghproxy.com/https://raw.githubusercontent.com/allonmymind/HangUp/main/armbian/docker-compose/xxqg.yml

mkdir /root/drpy && cd /root/drpy && wget -O docker-compose.yml https://ghproxy.com/https://raw.githubusercontent.com/allonmymind/HangUp/main/armbian/docker-compose/drpy.yml














