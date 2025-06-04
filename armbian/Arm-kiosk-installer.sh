#!/bin/bash

# be new
apt-get update

# get software
apt-get install \
    unclutter \
    xorg \
    chromium-browser \
    openbox \
    lightdm \
    locales \
    -y

# dir
mkdir -p /home/kiosk/.config/openbox

# create group
groupadd -f kiosk

# create user if not exists
id -u kiosk &>/dev/null || useradd -m kiosk -g kiosk -s /bin/bash 

# rights
chown -R kiosk:kiosk /home/kiosk

# remove virtual consoles
if [ -e "/etc/X11/xorg.conf" ]; then
  mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
fi
cat > /etc/X11/xorg.conf << EOF
Section "ServerFlags"
    Option "DontVTSwitch" "true"
EndSection
EOF

# create config
if [ -e "/etc/lightdm/lightdm.conf" ]; then
  mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.backup
fi
cat > /etc/lightdm/lightdm.conf << EOF
[Seat:*]
xserver-command=X -nocursor -nolisten tcp
autologin-user=kiosk
autologin-session=openbox
EOF

# create autostart
if [ -e "/home/kiosk/.config/openbox/autostart" ]; then
  mv /home/kiosk/.config/openbox/autostart /home/kiosk/.config/openbox/autostart.backup
fi
cat > /home/kiosk/.config/openbox/autostart << EOF
#!/bin/bash

# 设置你要打开的网址
KIOSK_URL="http://59.41.215.229:8081/amsTest2/?id=1026-3&passKey=143d242b8db646228ecdbd3fd0795d8c1026-3&wework_cfm_code=MhqF97FF7mzguPrurhxy9eeOJ3WTMxCNWxji5rhvy8G8nPx%2B4yP9ibWQqjyyzesmH4nPze%2FF5Ol3ePEU7diecTLGag1wPDoDSXxAawkqXV0QBWBNXjN5QuH9mYaAcuXN7eUTcUjBH99HhMa9PKXywAt%2BG6nvvXxoNQ%3D%3D"

# 启动后隐藏鼠标指针（0.1秒无操作后）
unclutter -idle 0.1 -grab -root &

# 禁用屏幕保护和电源管理，防止休眠黑屏
xset -dpms        # 关闭显示器电源管理
xset s off        # 关闭屏幕保护
xset s noblank    # 禁止屏幕空白

# 自动设置分辨率
xrandr --auto

# 杀掉所有旧的 Chromium 实例，防止重复启动
pkill -f chromium-browser

# 等待 X 启动完成，防止竞态条件
sleep 1

# 启动 Chromium kiosk 模式，只要没崩溃就不再重启
while true; do
  echo "$(date): Launching Chromium to $KIOSK_URL" >> /tmp/kiosk.log

  chromium-browser \
    --noerrdialogs \
    --no-memcheck \
    --no-first-run \
    --start-maximized \
    --disable-translate \
    --disable-infobars \
    --disable-suggestions-service \
    --disable-save-password-bubble \
    --disable-session-crashed-bubble \
    --kiosk "$KIOSK_URL"

  echo "$(date): Chromium exited unexpectedly" >> /tmp/kiosk.log
  sleep 5
done &
EOF

echo "Done!"
