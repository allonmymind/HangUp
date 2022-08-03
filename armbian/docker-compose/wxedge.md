version: '3'
services:
  wxedge:
    image: onething1/wxedge
    network_mode: "host"
    container_name: wxedge
    hostname: wxy
    restart: always
    privileged: true
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - /media/wxedge_storage:/storage:rw
    tmpfs:
      - /tmp
      - /run
      
