

echo "111111"| passwd root --stdin


yum install -y xorg-x11-xauth xorg-x11-fonts-* xorg-x11-font-utils xorg-x11-fonts-Type1 xclock
service sshd restart
# 重新连接ssh
xclock # 测试是否显示
echo 'export DISPLAY=192.168.199.188:0.0' >> /home/oracle/.bash_profile # 可能需要设置display
