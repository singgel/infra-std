<!--
 * @Author: your name
 * @Date: 2022-04-18 17:08:59
 * @LastEditTime: 2022-04-21 11:36:57
 * @LastEditors: Please set LastEditors
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 * @FilePath: /infra-std/IDE_DEV_tool/linux_OPS_command.md
-->

### curl
$ curl http://XXX |python -m json.tool  | python -m
格式化json输出  

# 磁盘  
## linux查看哪个进程占用磁盘IO  
$ vmstat 2  
执行vmstat命令，可以看到r值和b值较高，r 表示运行和等待cpu时间片的进程数，如果长期大于1，说明cpu不足，需要增加cpu。  
b 表示在等待资源的进程数，比如正在等待I/O、或者内存交换等。

### [IO等待导致性能下降](https://serverfault.com/questions/363355/io-wait-causing-so-much-slowdown-ext4-jdb2-at-99-io-during-mysql-commit)
$ iotop -oP  
命令的含义：只显示有I/O行为的进程  

$ iostat -dtxNm 2 10  
查看磁盘io状况

$ dstat -r -l -t --top-io  
用dstat命令看下io前几名的进程

$ dstat --top-bio-adv  
找到那个进程占用IO最多

$ pidstat -d 1  
命令的含义：展示I/O统计，每秒更新一次  

### [Linux 挂载管理(mount)](https://www.cnblogs.com/chenmh/p/5097530.html)  
$ vim /etc/fstab  
mount挂载分区在系统重启之后需要重新挂载，修改/etc/fstab文件可使挂载永久生效

$ mount -t ext4 /dev/sdb1 /sdb1  
-t:指定文件系统类型

$ mount -o remount,noatime,data=writeback,barrier=0,nobh /dev/sdb  
remount:重新挂载文件系统。
noatime:每次访问文件时不更新文件的访问时间。
async:适用缓存，默认方式。

---
# 文件
### 进程占用
$ fuser -m /dev/sdb  
查看文件系统占用的进程

$ lsof /dev/sdb  
查看正在被使用的文件，losf命令是list open file的缩写

---
### [文件句柄](https://cloud.tencent.com/developer/article/1810406)  
$ ulimit -a  
查看一个进程能打开多少文件句柄，其中3个是：标准输入、标准输出、标准错误。  

$ lsof -n|awk '{print $2}'| sort | uniq -c | sort -nr | head
统计进程的句柄占用

$ sudo strace -p 106954
追踪当前进程正在干什么

---  
# 网络
### [Linux网络监控工具大全](https://baijiahao.baidu.com/s?id=1683499342813958473&wfr=spider&for=pc)
$ netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'  
tcp连接状态和连接数  


---
### [tcpdump工具](https://cloud.tencent.com/developer/article/1730820)
$ tcpdump -i p3p1 icmp  
$ tcpdump -i br0 -nneevvv host 10.207.146.55 and icmp  
在p3p1上tcpdump抓包看看icmp为啥被超时了  

### [ethtool工具](https://developer.aliyun.com/article/544872)
$ ethtool –S ethX
查询网卡上收发包统计

### [dig工具](https://www.dounaite.com/article/629dfea60eb48b8cec76c300.html)
$ Dig www.163.com + trace
首先从根域名（.）获得负责.com域名的服务器,从.com域服务器获得负责163.com的域名服务器,从负责163.com的域名服务器中查询到所需的记录

$ nslookup -qt=mx jd.com
指定DNS查询服务器和查询不同的DNS记录，包括A记录、CNAME记录、MX记录等。

---  
### [Mac中的一些网络命令](https://tonydeng.github.io/2016/07/07/use-lsof-to-replace-netstat/)
$ lsof -itcp -n  
当前用户名下启动的链接数  

$ lsof -itcp -stcp:listen  
当前用户名下监听的端口  

$ netstat -antvp tcp  
使用 netstat 命令查看连接数  