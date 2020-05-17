

echo "111111"| passwd root --stdin


yum install -y xorg-x11-xauth xorg-x11-fonts-* xorg-x11-font-utils xorg-x11-fonts-Type1 xclock
service sshd restart
# 重新连接ssh
xclock # 测试是否显示
echo 'export DISPLAY=192.168.199.188:0.0' >> /home/oracle/.bash_profile # 可能需要设置display


date -d "$(curl -sI baidu.com| grep -i '^date:'|cut -d' ' -f2-)"
date -d "$(curl -sI baidu.com| grep -i '^date:'|cut -d' ' -f2-)" | xargs -I {} date --date='{}' "+%Y-%m-%d %H:%M:%S"
date -s "$(date -d "$(curl -sI baidu.com| grep -i '^date:'|cut -d' ' -f2-)" | xargs -I {} date --date='{}' "+%Y-%m-%d %H:%M:%S")"


PRIVKEY=mykey
TESTKEY=mykey.pub
diff <( ssh-keygen -y -e -f "$PRIVKEY" ) <( ssh-keygen -y -e -f "$TESTKEY" )


ssh-keygen -y -f id_rsa > id_rsa.pub


sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
    #
  w
EOF
