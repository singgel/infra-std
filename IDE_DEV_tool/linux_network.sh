#查看开机信息
dmesg
#查看文件版本
md5sum

-------------

ip netns exec port-y5juxi07st ifconfig ? mtu 1000 #修改mtu的大小
# 添加并启动虚拟网卡tap设备(https://juejin.cn/post/7057833934947614750)
ip tuntap add dev tap0 mode tap 
ip tuntap add dev tap1 mode tap 
ip link set tap0 up
ip link set tap1 up
# 配置IP
ip addr add 10.0.0.1/24 dev tap0
ip addr add 10.0.0.2/24 dev tap1
# 添加netns(https://segmentfault.com/a/1190000038171918)
ip netns add ns0
ip netns add ns1
# 将虚拟网卡tap0，tap1分别移动到ns0和ns1中
ip link set tap0 netns ns0
ip link set tap1 netns ns1

# 创建一对veth(https://typesafe.cn/posts/linux-veth-pair/)
ip link add veth0 type veth peer name veth1
# 将veth移动到netns中
ip link set veth0 netns ns0
ip link set veth1 netns ns1
# 启动
ip netns exec ns0 ip link set veth0 up
ip netns exec ns1 ip link set veth1 up
#修改路由出口为veth
ip netns exec ns0 ip route change 10.0.0.0/24 via 0.0.0.0 dev veth0
ip netns exec ns1 ip route change 10.0.0.0/24 via 0.0.0.0 dev veth1

# 添加网桥(https://typesafe.cn/posts/linux-bridge/)
brctl addbr br0
# 启动网桥
ip link set br0 up

# 新增三个netns
ip netns add ns0
ip netns add ns1
ip netns add ns2

# 新增两对veth
ip link add veth0-ns type veth peer name veth0-br
ip link add veth1-ns type veth peer name veth1-br
ip link add veth2-ns type veth peer name veth2-br

# 将veth的一端移动到netns中
ip link set veth0-ns netns ns0
ip link set veth1-ns netns ns1
ip link set veth2-ns netns ns2

# 将netns中的本地环回和veth启动并配置IP
ip netns exec ns0 ip link set lo up
ip netns exec ns0 ip link set veth0-ns up
ip netns exec ns0 ip addr add 10.0.0.1/24 dev veth0-ns

ip netns exec ns1 ip link set lo up
ip netns exec ns1 ip link set veth1-ns up
ip netns exec ns1 ip addr add 10.0.0.2/24 dev veth1-ns

ip netns exec ns2 ip link set lo up
ip netns exec ns2 ip link set veth2-ns up
ip netns exec ns2 ip addr add 10.0.0.3/24 dev veth2-ns

# 将veth的另一端启动并挂载到网桥上
ip link set veth0-br up
ip link set veth1-br up
ip link set veth2-br up
brctl addif br0 veth0-br
brctl addif br0 veth1-br
brctl addif br0 veth2-br


#ip link是与OSI七层模型的第二层数据链路层有关
ip link show                    # 显示网络接口信息
ip link set eth0 up             # 开启网卡
ip link set eth0 down            # 关闭网卡
ip link set eth0 promisc on      # 开启网卡的混合模式
ip link set eth0 promisc offi    # 关闭网卡的混合模式
ip link set eth0 txqueuelen 1200 # 设置网卡队列长度
ip link set eth0 mtu 1400        # 设置网卡最大传输单元
ip link | grep -E '^[0-9]' | awk -F: '{print $2}' #获取主机所有网络接口
ip -s link #显示所有网络接口的统计数据
ip -s -s link ls eth0 #获取一个特定网络接口的信息

#ip address (ip addr)就是与第三层网络层有关
ip addr show     # 显示网卡IP信息
ip addr add 192.168.0.1/24 dev eth0 # 为eth0网卡添加一个新的IP地址192.168.0.1
ip addr del 192.168.0.1/24 dev eth0 # 为eth0网卡删除一个IP地址192.168.0.1

ip route show # 显示系统路由
ip route add default via 192.168.1.254   # 设置系统默认路由
ip route list                 # 查看路由信息
ip route add 192.168.4.0/24  via  192.168.0.254 dev eth0 # 设置192.168.4.0网段的网关为192.168.0.254,数据走eth0接口
ip route add default via  192.168.0.254  dev eth0        # 设置默认网关为192.168.0.254
ip route del 192.168.4.0/24   # 删除192.168.4.0网段的网关
ip route del default          # 删除默认路由
ip route delete 192.168.1.0/24 dev eth0 # 删除路由
ip route get 119.75.216.20 #通过 IP 地址查询路由包从哪条路由来
ip route flush cache #刷新路由表

ip neigh list #显示邻居表

-------------
#OVS的术语解释(https://typesafe.cn/posts/ovs-learn-1/)
ovs-vsctl add-br br-int #添加网桥
ovs-vsctl list-br #查询网桥列表
ovs-vsctl del-br br-int #删除网桥

# 添加Internal Port 
ovs-vsctl add-port br-int vnet0 -- set Interface vnet0 type=internal
# 把网卡vnet0启动并配置IP
ip link set vnet0 up
ip addr add 192.168.0.1/24 dev vnet0
# 设置VLAN tag
ovs-vsctl set Port vnet0 tag=100
# 移除vnet0上面的VLAN tag配置
ovs-vsctl remove Port vnet0 tag 100
# 设置vnet0允许通过的VLAN tag
ovs-vsctl set Port vnet0 trunks=100,200
# 移除vnet0允许通过的的VLAN tag配置
ovs-vsctl remove Port vnet0 trunks 100,200

# 设置VLAN mode
ovs-vsctl set port <port name> VLAN_mode=trunk|access|native-tagged|native-untagged
# 设置VLAN tag
ovs-vsctl set port <port name> tag=<1-4095>
# 设置VLAN trunk
ovs-vsctl set port <port name> trunk=100,200
# 移除Port的属性
ovs-vsctl remove port <port name> <property name> <property value>
# 查看Port的属性
ovs-vsctl list interface <port name>

-------------
#查看iptables的变化（流量没有离开本机）
watch -n 1 "iptables -t filter -nvL "

-------------
#抓包(https://www.cnblogs.com/jiujuan/p/9017495.html)
#抓包监控流量
tcpdump -i eth0 port 1314 -nnn
#抓指定的目的地
tcpdump -i eth0 dst host 169.254.169.254

#抓包发送给目的服务器10.60.18.80的请求包和响应包
#请求包抓取
tcpdump -n -X -i bond0 dst host 10.60.18.80
#响应包抓取
tcpdump -n -X -i bond0 src host 10.60.18.80
#12500端口上抓包
tcpdump -n -X -i any port 12500  icmp

-------------
#表名为 nat、filter 或是 mangle 三张表中的一张，如果不填默认是filter表
iptables -vnL -t [表名] --line-numbers
#列出指定表的指定链的规则
iptables -t [表名] -vnL [链名]

-------------
#使用 SCP 将文件从远程复制到本地
scp <Username>@<IPorHost>:<PathToFile>   <LocalFileLocation>

-------------
一、并行性和shell命令command|script|shell
#重启webservers主机组的所有机器，每次重启10 台
ansible webservers -a "/sbin/reboot" -f 10
#以ju 用户身份在webservers组的所有主机运行foo 命令
ansible webservers -a "/usr/bin/foo" -u ju
#以ju 用户身份sudo 执行命令foo（--ask-sudo-pass (-K) 如果有sudo 密码请使用此参数）
ansible webservers -a "/usr/bin/foo" -u ju --sudo [--ask-sudo-pass]
#也可以sudo 到其他用户执行命令非root
ansible webservers -a "/usr/bin/foo" -u username -U otheruser [--ask-sudo-pass]
#默认情况下，ansible 使用的module 是command，这个模块并不支持shell 变量和管道等，若想使用shell 来执行模块，请使用-m 参数指定shell 模块
#使用shell 模块在远程主机执行命令或脚本
ansible dbservers -m shell -a 'echo $TERM'
ansible dbservers -m shell -a '/tmp/test.sh'
#script命令模块，在远程主机执行主控端本地的脚本文件，相当于scp+shell
ansible dbservers -m script -a '/tmp/test.sh 111  222'
二、传输文件copy|file
#拷贝本地的/etc/hosts 文件到myserver主机组所有主机的/tmp/hosts（空目录除外）,如果使用playbooks 则可以充分利用template 模块
ansible myserver -m copy -a "src=/etc/hosts dest=/tmp/hosts mode=600 owner=ju group=ju"
#file 模块允许更改文件的用户及权限
ansible webservers -m file -a "dest=/srv/foo/a.txt mode=600"
ansible webservers -m file -a "dest=/srv/foo/b.txt mode=600 owner=ju group=ju"
#使用file 模块创建目录，类似mkdir -p
ansible webservers -m file -a "dest=/path/to/c mode=755 owner=ju group=ju state=directory"
#使用file 模块删除文件或者目录
ansible webservers -m file -a "dest=/path/to/c state=absent"
三、获取远程文件信息stat
ansible webservers -m stat -a "path=/etc/password"
四、下载指定定url到远程主机get_url
ansible webservers -m get_url -a "url=  mode=0440 force=yes"
五、管理软件包yum
#确保acme 包已经安装，但不更新
ansible webservers -m yum -a "name=acme state=present"
#确保安装包到一个特定的版本
ansible webservers -m yum -a "name=acme-1.5 state=present"
#确保一个软件包是最新版本
ansible webservers -m yum -a "name=acme state=latest"
#确保一个软件包没有被安装
ansible webservers -m yum -a "name=acme state=absent"
#Ansible 支持很多操作系统的软件包管理，使用时-m 指定相应的软件包管理工具模块，如果没有这样的模块，可以自己定义类似的模块或者使用command 模块来安装软件包
六、用户和用户组user
#使用user 模块对于创建新用户和更改、删除已存在用户非常方便
ansible all -m user -a "name=foo password=<crypted password here>"
ansible all -m user -a "name=foo state=absent"
生成加密密码方法
mkpasswd --method=SHA-512
pip install passlib
python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.encrypt(getpass.getpass())"
七、服务管理service
#确保webservers 组所有主机的httpd 是启动的
ansible webservers -m service -a "name=httpd state=started"
#重启webservers 组所有主机的httpd 服务
ansible webservers -m service -a "name=httpd state=restarted"
#确保webservers 组所有主机的httpd 是关闭的
ansible webservers -m service -a "name=httpd state=stopped192.168.116"
八、后台运行
#长时间运行的操作可以放到后台执行，ansible 会检查任务的状态；在主机上执行的同一个任务会分配同一个job ID
#后台执行命令3600s，-B 表示后台执行的时间
ansible all -B 3600 -a "/usr/bin/long_running_operation --do-stuff"
#检查任务的状态
ansible all -m async_status -a "jid=123456789"
#后台执行命令最大时间是1800s 即30 分钟，-P 每60s 检查下状态默认15s
ansible all -B 1800 -P 60 -a "/usr/bin/long_running_operation --do-stuff"
九、搜集系统信息setup
#通过命令获取所有的系统信息
#搜集主机的所有系统信息
ansible all -m setup
#搜集系统信息并以主机名为文件名分别保存在/tmp/facts 目录
ansible all -m setup --tree /tmp/facts
#搜集和内存相关的信息
ansible all -m setup -a 'filter=ansible_*_mb'
#搜集网卡信息
ansible all -m setup -a 'filter=ansible_eth[0-2]'
十、计划任务cron
ansible all -m cron -a 'name="jutest" hour="5" job="/bin/bash /tmp/test.sh"'
效果如下：
* 5 * * *  /bin/bash /tmp/test.sh
十一、挂载模块mount
ansible all -m mount -a 'name=/mnt src=/dev/sda5 fstype=ext4 opts=rostate=present'
十二、通过Ansible实现批量免密
ssh-keygen -t rsa
ansible webservers -i /etc/ansible/hosts  -m authorized_key -a "user=root key='{{ lookup('file','/root/.ssh/id_rsa.pub') }}'" -k

-------------
#查看连接数
netstat -n | awk '/^tcp/ {++state[$NF]} END {for(key in state) print key,"t",state[key]}'
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
#发现有SYNs包被丢弃，即有可能是半连接队列溢出
#连接队列包括两种，一个是半连接队列（syn queue），一个是全连接队列（accept queue）；
netstat -s | grep LISTEN
#查看stock的连接
ss -xln | grep tmp
#查看socket文件的具体信息
stat /tmp/stream.sock
ncat -U /tmp/tbsocket1

-------------
#要查看cpu波动情况的，尤其是多核机器上
mpstat -P 2,3,4,5
#该命令可间隔2秒钟采样一次CPU的使用情况，每个核的情况都会显示出来
mpstat -P ALL 2 5

#查看内存占用前10名的程序
ps aux | sort -k4,4nr | head -n 10
top -p 2913
cat /proc/2913/status 
#对于内存泄露
dmesg | grep oom-killer
#显示已经运行的进程的CPU亲和性
taskset -p pid
#法获取某进程中运行中的线程数量（PID指的是进程ID）
ls /proc/PID/task | wc -l

-------------
$ iotop -oP
#命令的含义：只显示有I/O行为的进程
$ iostat -dtxNm 2 10
#查看磁盘io状况
$ dstat -r -l -t --top-io
#用dstat命令看下io前几名的进程
$ dstat --top-bio-adv
#找到那个进程占用IO最多
$ pidstat -d 1
#命令的含义：展示I/O统计，每秒更新一次

-------------
#rpm包使用
rpm -ivh ipm软件安装包
rpm -qa | grep mn-collector #查看版本
rpm -qlf /usr/local/bin/cc_controller_dr

-------------
# curl json格式化
curl https://news-at.zhihu.com/api/4/news/latest | python -m json.tool
/export/Shell/check_active_hostgroup.sh

