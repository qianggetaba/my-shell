# my-shell
shell utils

工作，学习时掌握的shell奇技淫巧 -- 【水滴石穿,绳锯木断】




### 使用shell脚本mysql binlog 转sql语句
[binlog2sql.sh](binlog2sql.sh)

### 命令行无交互修改用户密码
[misc.sh#L3](misc.sh#L3)

### centos开启X11转发，使用XManager实现gui安装linux软件
[misc.sh#L6](misc.sh#L6)

### 使用网络快速获取与设置正确的系统时间
[misc.sh#L13](misc.sh#L13)

### 公钥私钥配对检查，没有输出就是正确的配对
[misc.sh#L18](misc.sh#L18)

### 通过私钥生成公钥
[misc.sh#L23](misc.sh#L23)

### fdisk无交互命令行分区，虽然可以用parted命令，但是好像与fdisk的分区有区别
[misc.sh#L26](misc.sh#L26)

### 合并从bilibili缓存的视频，m4s文件转mp4，放在缓存的合集目录下，该目录下序号的文件夹
[bili.sh](bili.sh)


### 合并一个从百度云盘下载的视频，流畅模式(经百度转码的m3u8文件)为mp4，放在一个下载的流畅视频文件目录内，与m3u8文件同级
[bdy.sh](bdy.sh)
```批量合并多个视频，在多少视频文件夹上级目录
for one_dir in $(ls -AF | egrep "^\..*/$");do
  cd $one_dir;
  if [ ! -f "bdy.sh" ];then
    rm -rf *.txt *.mp4 \.*m3u8.mp4 *.ts ts_list.txt bdy.sh;
    \cp -rf ../bdy.sh .;
    bash bdy.sh;
  fi
  cd ..;
done
```

### 快速搭建，采用kerberos作为认证的hdfs单机模式，供开发调试代码，单机hdfs很容易部署，但是单机认证的hdfs，你肯定不会
[hdfs-keytab.txt](hdfs-keytab.txt)

