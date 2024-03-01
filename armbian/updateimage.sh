#!/bin/bash

# 检查输入参数是否为空
if [ -z "$1" ]; then
    echo "Usage: $0 <container_name>"
    exit 1
fi

# 设置容器名称
CONTAINER_NAME=$1

# 运行 watchtower 一次性更新指定容器
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --cleanup -c $CONTAINER_NAME
