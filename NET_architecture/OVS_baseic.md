
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
