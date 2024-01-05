# Linux connection tracking  
https://arthurchiao.art/blog/conntrack-design-and-implementation-zh/  
CT 中，一个元组（tuple）定义的一条数据流（flow ）就表示一条连接（connection）。  
后面会看到 UDP 甚至是 ICMP 这种三层协议在 CT 中也都是有连接记录的  
但不是所有协议都会被连接跟踪  
  
Netfilter 是 Linux 内核中一个对数据 包进行控制、修改和过滤（manipulation and filtering）的框架。它在内核协议 栈中设置了若干hook 点，以此对数据包进行拦截、过滤或其他处理。  
Netfilter 只是 Linux 内核中的一种连接跟踪实现。  
换句话说，只要具备了 hook 能力，能拦截到进出主机的每个包，完全可以在此基础上自 己实现一套连接跟踪。  
  
NAT 依赖连接跟踪的结果。连接跟踪最重要的使用场景就是 NAT。  
eg：如果在 VIP 和 Real IP 节点之间使用的 NAT 技术（也可以使用其他技术），那客户端访 问服务端时，L4LB 节点将做双向 NAT（Full NAT）  
  
来看个更具体的防火墙应用：OpenStack 主机防火墙解决方案 —— 安全组（security group）。  
Linux 中有 conntrack 模块，但基于 conntrack 的防火墙工作在 IP 层（L3），通过 iptables 控制，  
而 OVS 是 L2 模块，无法使用 L3 模块的功能，RedHat 在 2016 年提出了一个 OVS conntrack 方案 [7]，从那以后，才有可能干掉 Linux bridge 而仍然具备安全组的功能。  
  
 查看/加载/卸载 nf_conntrack 模块  
> $ modinfo nf_conntrack  
> $ rmmod nf_conntrack_netlink nf_conntrack  
重新加载：  
> $ modprobe nf_conntrack  
 加载时还可以指定额外的配置参数，例如：  
> $ modprobe nf_conntrack nf_conntrack_helper=1 expect_hashsize=131072  
 sysctl 配置项  
> $ sysctl -a | grep nf_conntrack  
 丢包监控  
> $ cat /proc/net/stat/nf_conntrack  
> $ conntrack -S  
  
## 连接太多导致 conntrack table 被打爆  
### 业务层（应用层）现象  
存在随机、偶发的新建连接超时（connect timeout）。  
例如，如果业务用的是 Java，那对应的是 jdbc4.CommunicationsException communications link failure 之类的错误。  
已有连接正常。  
也就是没有 read timeout 或 write timeout 之类的报错，报错都集中为 connect timeout。  
### 网络层现象  
抓包会看到三次握手的第一个 SYN 包被宿主机静默丢弃了。  
需要注意的是，常规的网卡统计（ifconfig）和内核统计（/proc/net/softnet_stat） 无法反映出这些丢包。  
1s+ 之后出发 SYN 重传，或者还没重传连接就关闭了。  
第一个 SYN 的重传是 1s，这个是内核代码里写死的，不可配置（具体实现见 附录）。  
  
### 解决方式  
调大 conntrack 表  
运行时配置（经实际测试，不会对现有连接造成影响）：  
> $ sysctl -w net.netfilter.nf_conntrack_max=524288  
> $ sysctl -w net.netfilter.nf_conntrack_buckets=131072 # 推荐配置 hashsize=nf_conntrack_count/4  
持久化配置：  
> $ echo 'net.netfilter.nf_conntrack_max = 524288' >> /etc/sysctl.conf  
> $ echo 'net.netfilter.nf_conntrack_buckets = 131072' >> /etc/sysctl.conf  
  
#### 减小 GC 时间  
还可以调小 conntrack 的 GC（也叫 timeout）时间，加快过期 entry 的回收。  
nf_conntrack 针对不同 TCP 状态（established、fin_wait、time_wait 等）的 entry 有不同的 GC 时间。  
例如，默认的 established 状态的 GC 时间是 423000s（5 天）。设置成这么长的 可能原因是：TCP/IP 协议中允许 established 状态的连接无限期不发送任何东西（但仍然活着） [8]，协议的具体实现（Linux、BSD、Windows 等）会设置各自允许的最大 idle timeout。为防止 GC 掉这样长时间没流量但实际还活着的连接，就设置一个足够保守的 timeout 时间。[8] 中建议这个值不小于 2 小时 4 分钟（作为对比和参考， Cilium 自己实现的 CT 中，默认 established GC 是 6 小时）。 但也能看到一些厂商推荐比这个小得多的配置，例如 20 分钟。  
如果对自己的网络环境和需求非常清楚，那可以将这个时间调到一个合理的、足够小的值; 如果不是非常确定的话，还是建议保守一些，例如设置 6 个小时 —— 这已经比默认值 5 天小多了。  
> $ sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established = 21600  
持久化：  
> $ echo 'net.netfilter.nf_conntrack_tcp_timeout_established = 21600' >> /etc/sysctl.conf  
  
#第一个 SYN 包的重传间隔计算（Linux 4.19.118 实现）  
// net/ipv4/tcp_output.c  
#根据 nf_conntrack_max 计算 conntrack 模块所需的内存  
> $ cat /proc/slabinfo | head -n2; cat /proc/slabinfo | grep conntrack  
---

# 深入理解 iptables 和 netfilter 架构
https://arthurchiao.art/blog/deep-dive-into-iptables-and-netfilter-arch-zh/  
netfilter 提供了 5 个 hook 点。包经过协议栈时会触发内核模块注册在这里的处理函数 。触发哪个 hook 取决于包的方向（ingress/egress）、包的目的地址、包在上一个 hook 点是被丢弃还是拒绝等等。  
下面几个 hook 是内核协议栈中已经定义好的：  
> NF_IP_PRE_ROUTING: 接收到的包进入协议栈后立即触发此 hook，在进行任何路由判断 （将包发往哪里）之前  
> NF_IP_LOCAL_IN: 接收到的包经过路由判断，如果目的是本机，将触发此 hook  
> NF_IP_FORWARD: 接收到的包经过路由判断，如果目的是其他机器，将触发此 hook  
> NF_IP_LOCAL_OUT: 本机产生的准备发送的包，在进入协议栈后立即触发此 hook  
> NF_IP_POST_ROUTING: 本机产生的准备发送的包或者转发的包，在经过路由判断之后， 将触发此 hook  
  
iptables 使用 table 来组织规则（nat、filter）  
在每个 table 内部，规则被进一步组织成 chain（PREROUTING、INPUT、FORWARD、OUTPUT、POSTROUTING）  
内置的 chain 名字和 netfilter hook 名字是一一对应的：  
> filter table 是最常用的 table 之一，用于判断是否允许一个包通过。  
> nat table 用于实现网络地址转换规则。  
> mangle（修正）table 用于修改包的 IP 头。  
> raw table 定义的功能非常有限，其唯一目的就是提供一个让包绕过连接跟踪的框架。  
> security table 的作用是给包打上 SELinux 标记，以此影响 SELinux 或其他可以解读 SELinux 安全上下文的系统处理包的行为。这些标记可以基于单个包，也可以基于连接。  
---
  
# Linux网络包接收过程  
https://zhuanlan.zhihu.com/p/256428917  
//在Linux的源代码中，网络设备驱动对应的逻辑位于driver/net/ethernet, 其中intel系列网卡的驱动在driver/net/ethernet/intel目录下。  
内核和网络设备驱动是通过中断的方式来处理的。当设备上有数据到达的时候，会给CPU的相关引脚上触发一个电压变化，以通知CPU来处理数据。对于网络模块来说，由于处理过程比较复杂和耗时，如果在中断函数中完成所有的处理，将会导致中断处理函数（优先级过高）将过度占据CPU，将导致CPU无法响应其它设备，例如鼠标和键盘的消息。因此Linux中断处理函数是分上半部和下半部的。上半部是只进行最简单的工作，快速处理然后释放CPU，接着CPU就可以允许其它中断进来。剩下将绝大部分的工作都放到下半部中，可以慢慢从容处理。  
  
//file: kernel/softirq.c  
系统初始化的时候在kernel/smpboot.c中调用了smpboot_register_percpu_thread， 该函数进一步会执行到spawn_ksoftirqd（位于kernel/softirq.c）来创建出softirqd进程。该进程数量不是1个，而是N个，其中N等于你的机器的核数。  
  
//file: net/core/dev.c  
如果看一下ip_rcv和udp_rcv等函数的代码能看到很多协议的处理过程。例如，ip_rcv中会处理netfilter和iptable过滤，如果你有很多或者很复杂的 netfilter 或 iptables 规则，这些规则都是在软中断的上下文中执行的，会加大网络延迟。再例如，udp_rcv中会判断socket接收队列是否满了。对应的相关内核参数是net.core.rmem_max和net.core.rmem_default。如果有兴趣，建议大家好好读一下inet_init这个函数的代码。  
  
//file: drivers/net/ethernet/intel/igb/igb_main.c  
网卡驱动实现了ethtool所需要的接口，也在这里注册完成函数地址的注册。当 ethtool 发起一个系统调用之后，内核会找到对应操作的回调函数。相信你这次能彻底理解ethtool的工作原理了吧？ 这个命令之所以能查看网卡收发包统计、能修改网卡自适应模式、能调整RX 队列的数量和大小，是因为ethtool命令最终调用到了网卡驱动的相应方法，而不是ethtool本身有这个超能力。  
从网卡硬件中断的层面就可以设置让收到的包被不同的 CPU处理。（可以通过 irqbalance ，或者修改 /proc/irq/IRQ_NUMBER/smp_affinity能够修改和CPU的绑定行为）。  
  
## 硬中断  
网卡的接收队列。网卡在分配给自己的RingBuffer中寻找可用的内存位置，找到后DMA引擎会把数据DMA到网卡之前关联的内存里，这个时候CPU都是无感的。当DMA操作完成以后，网卡会像CPU发起一个硬中断，通知CPU有数据到达。  
注意：当RingBuffer满的时候，新来的数据包将给丢弃。ifconfig查看网卡的时候，可以里面有个overruns，表示因为环形队列满被丢弃的包。如果发现有丢包，可能需要通过ethtool命令来加大环形队列的长度。  
硬中断处理过程真的是非常短。只是记录了一个寄存器，修改了一下下CPU的poll_list，然后发出个软中断。就这么简单，硬中断工作就算是完成了。  
这里需要注意一个细节，硬中断中设置软中断标记，和ksoftirq的判断是否有软中断到达，都是基于smp_processor_id()的。这意味着只要硬中断在哪个CPU上被响应，那么软中断也是在这个CPU上处理的。所以说，如果你发现你的Linux软中断CPU消耗都集中在一个核上的话，做法是要把调整硬中断的CPU亲和性，来将硬中断打散到不通的CPU核上去。  
  
//file: net/core/dev.c  
收取完数据以后，对其进行一些校验，然后开始设置sbk变量的timestamp, VLAN id, protocol等字段。接下来进入到napi_gro_receive中:  
netif_receive_skb函数会根据包的协议，假如是udp包，会将包依次送到ip_rcv(),udp_rcv()协议处理函数中进行处理。  
pcap逻辑，这里会将数据送入抓包点。tcpdump就是从这个入口获取包的  
  
//file: net/ipv4/ip_input.c  
sock_owned_by_user判断的是用户是不是正在这个socker上进行系统调用（socket被占用），如果没有，那就可以直接放到socket的接收队列中。如果有，那就通过sk_add_backlog把数据包添加到backlog队列。 当用户释放的socket的时候，内核会检查backlog队列，如果有数据再移动到接收队列中。  
sk_rcvqueues_full接收队列如果满了的话，将直接把包丢弃。接收队列大小受内核参数net.core.rmem_max和net.core.rmem_default影响。  
  
当用户执行完recvfrom调用后，用户进程就通过系统调用进行到内核态工作了。如果接收队列没有数据，进程就进入睡眠状态被操作系统挂起。这块相对比较简单，剩下大部分的戏份都是由Linux内核其它模块来表演了。  
  
### 首先在开始收包之前，Linux要做许多的准备工作：  
  
1. 创建ksoftirqd线程，为它设置好它自己的线程函数，后面就指望着它来处理软中断呢。  
2. 协议栈注册，linux要实现许多协议，比如arp，icmp，ip，udp，tcp，每一个协议都会将自己的处理函数注册一下，方便包来了迅速找到对应的处理函数  
3. 网卡驱动初始化，每个驱动都有一个初始化函数，内核会让驱动也初始化一下。在这个初始化过程中，把自己的DMA准备好，把NAPI的poll函数地址告诉内核  
4. 启动网卡，分配RX，TX队列，注册中断对应的处理函数  
  
以上是内核准备收包之前的重要工作，当上面都ready之后，就可以打开硬中断，等待数据包的到来了。  
  
### 当数据到来了以后，第一个迎接它的是网卡：  
  
1. 网卡将数据帧DMA到内存的RingBuffer中，然后向CPU发起中断通知  
2. CPU响应中断请求，调用网卡启动时注册的中断处理函数  
3. 中断处理函数几乎没干啥，就发起了软中断请求  
4. 内核线程ksoftirqd线程发现有软中断请求到来，先关闭硬中断  
5. ksoftirqd线程开始调用驱动的poll函数收包  
6. poll函数将收到的包送到协议栈注册的ip_rcv函数中  
7. ip_rcv函数再讲包送到udp_rcv函数中（对于tcp包就送到tcp_rcv）  
  
## tap/tun  
tap/tun 提供了一台主机内用户空间的数据传输机制。它虚拟了一套网络接口，这套接口和物理的接口无任何区别，可以配置 IP，可以路由流量，不同的是，它的流量只在主机内流通。  
tap/tun 有些许的不同，tun 只操作三层的 IP 包，而 tap 操作二层的以太网帧。  
  
## veth-pair  
veth-pair 是成对出现的一种虚拟网络设备，一端连接着协议栈，一端连接着彼此，数据从一端出，从另一端进。  
它的这个特性常常用来连接不同的虚拟网络组件，构建大规模的虚拟网络拓扑，比如连接 Linux Bridge、OVS、LXC 容器等。  

  
# VLAN 是一项把 L2 网络再做分区隔离的技术。  
https://mp.weixin.qq.com/s/7Ltvj9hJccyK_dI3bAg6mA  
VLAN直接在Ethernet Frame的头部加上4个字节的VLAN ID用来标识不同的二层网络，处理起来也比较简单，在读取Ethernet数据的时候，只需要根据EtherType相应的偏移4个字节就行。  
从技术上讲，VLAN 是一种用“数字”（也就是VLAN ID）标记单个 L2 网段Ethernet Frame的机制。简单来说就像是一个交换机被拆成了多个虚拟交换机，原本的一个广播域也分成了多个。  
  
1. 限制广播域。广播域被限制在一个局域网内，节省了带宽，提高了网络处理能力。  
2. 增强局域网的安全性。不同局域网内的报文在传输时是相互隔离的，即一个VLAN内的用户不能和其它VLAN内的用户直接通信，如果不同VLAN要进行通信，则需要通过路由器或三层交换机等三层设备。  
3. 灵活构建虚拟工作组。用局域网可以划分不同的用户到不同的工作组，同一工作组的用户也不必局限于某一固定的物理范围，网络构建和维护更方便灵活。  
---
  
# VXLAN 是基于 L3 网络构建的虚拟 L2 网络，是一种Overlay网络。  
每个 VXLAN 节点上的出站L2 Ethernet Frame都会被捕获，然后封装成 UDP 数据包，并通过 L3 网络发送到目标 VXLAN 节点。当 L2 Ethernet Frame 到达 VXLAN 节点时，就从 UDP 数据包中提取（解封装），并注入目标设备的网络接口。这种技术称为隧道。  
  
VXLAN Header：增加VXLAN头（8字节），其中包含24比特的VNI字段，用来定义VXLAN网络中不同的租户。  
UDP Header：VXLAN头和原始以太帧一起作为UDP的数据。  
  
1. VXLAN支持大量租户：支持多达1600万个相互隔离的二层网络，解决传统二层网络VLAN资源不足问题。  
2. VXLAN网络易于维护：基于IP网络构建大二层网络，将原始二层数据帧封装成VXLAN报文在IP网络中透传，充分利用现有IP网络技术，部署和维护更容易。  
3. VXLAN网络保证虚拟机动态迁移：采用“MAC in UDP”的封装方式，保证虚拟机迁移前后的IP和MAC不变。  
  
**首先VXLAN是一种Overlay网络，不能独立存在，必须依赖Underlay网络，而在构建Underlay网络时，还是需要借助VLAN。**  
---  
  
# Overlay网络模型  
https://jishuin.proginn.com/p/763bfbd5bdef  
这种于某个通信网络之上构建出的另一个逻辑通信网络通常即10.1.2节提及的Overlay网络或Underlay网络。  
隧道转发的本质是将容器双方的通信报文分别封装成各自宿主机之间的报文，借助宿主机的网络“隧道”完成数据交换。这种虚拟网络的基本要求是各宿主机只需支持隧道协议即可，对于底层网络没有特殊要求。  
  
VXLAN协议是目前最流行的Overlay网络隧道协议之一，它也是由IETF定义的NVO3（Network Virtualization over Layer 3）标准技术之一，采用L2 over L4（MAC-in-UDP）的报文封装模式，将二层报文用三层协议进行封装，可实现二层网络在三层范围内进行扩展，将“二层域”突破规模限制形成“大二层域”。  
那么，同一大二层域就类似于传统网络中VLAN（虚拟局域网）的概念，只不过在VXLAN网络中，它被称作Bridge-Domain，以下简称为BD。类似于不同的VLAN需要通过VLAN ID进行区分，各BD要通过VNI加以标识。但是，为了确保VXLAN机制通信过程的正确性，涉及VXLAN通信的IP报文一律不能分片，这就要求物理网络的链路层实现中必须提供足够大的MTU值，或修改其MTU值以保证VXLAN报文的顺利传输。不过，降低默认MTU值，以及额外的头部开销，必然会影响到报文传输性能。  
  
VXLAN的显著的优势之一是对底层网络没有侵入性，管理员只需要在原有网络之上添加一些额外设备即可构建出虚拟的逻辑网络来。这个额外添加的设备称为VTEP（VXLAN Tunnel Endpoints），它工作于VXLAN网络的边缘，负责相关协议报文的封包和解包等操作，从作用来说相当于VXLAN隧道的出入口设备。  
  
VTEP代表着一类支持VXLAN协议的交换机，而支持VXLAN协议的操作系统也可将一台主机模拟为VTEP，Linux内核自3.7版本开始通过vxlan内核模块原生支持此协议。于是，各主机上由虚拟网桥构建的LAN便可借助vxlan内核模块模拟的VTEP设备与其他主机上的VTEP设备进行对接，形成隧道网络。  
  
## 对于Flannel来说
这个VTEP设备就是各节点上生成flannel.1网络接口，其中的“1”是VXLAN中的BD标识VNI，因而同一Kubernetes集群上所有节点的VTEP设备属于VNI为1的同一个BD。  
  
类似VLAN的工作机制，相同VXLAN VNI在不同VTEP之间的通信要借助二层网关来完成，而不同VXLAN之间，或者VXLAN同非VXLAN之间的通信则需经由三层网关实现。VXLAN支持使用集中式和分布式两种形式的网关：前者支持流量的集中管理，配置和维护较为简单，但转发效率不高，且容易出现瓶颈和网关可用性问题;后者以各节点为二层或三层网关，消除了瓶颈。  
  
补充下：二层网络三层网络定义二层三层是按照逻辑拓扑结构进行的分类，并不是ISO七层模型中的数据链路层和网络层，而是指核心层、汇聚层和接入层。 只有核心层和接入层，没有汇聚层的是二层网络。 核心层、汇聚层和接入层三层都部署的是三层网络。  
补充下：二层网络仅仅通过MAC寻址即可实现通讯，但仅仅是同一个冲突域内;三层网络则需要通过IP路由实现跨网段的通讯，可以跨多个冲突域。  
  
VXLAN网络中的容器在首次通信之前，源VTEP又如何得知目标服务器在哪一个VTEP，并选择正确的路径传输通信报文呢？  
多播：是指同一个BD内的各VTEP加入同一个多播域中，通过多播报文查询目标容器所在的目标VTEP。  
控制中心：则在某个共享的存储服务上保存所有容器子网及相关VTEP的映射信息，各主机上运行着相关的守护进程，并通过与控制中心的通信获取相关的映射信息。Flannel默认的VXLAN后端采用的是后一种方式，它把网络配置信息存储在etcd系统上。  
  
## Underlay网络模型  
Underlay网络就是传统IT基础设施网络，由交换机和路由器等设备组成，借助以太网协议、路由协议和VLAN协议等驱动，它还是Overlay网络的底层网络，为Overlay网络提供数据通信服务。容器网络中的Underlay网络是指借助驱动程序将宿主机的底层网络接口直接暴露给容器使用的一种网络构建技术，较为常见的解决方案有MAC VLAN、IP VLAN和直接路由等。  
  
MAC VLAN支持在同一个以太网接口上虚拟出多个网络接口，每个虚拟接口都拥有唯一的MAC地址，并可按需配置IP地址。通常这类虚拟接口被网络工程师称作子接口，但在MAC VLAN中更常用上层或下层接口来表述。与Bridge模式相比，MAC VLAN不再依赖虚拟网桥、NAT和端口映射，它允许容器以虚拟接口方式直接连接物理接口。  
  
MAC VLAN有Private、VEPA、Bridge和Passthru几种工作模式  
除了Passthru模式外的容器流量将被MAC VLAN过滤而无法与底层主机通信，从而将主机与其运行的容器完全隔离，其隔离级别甚至高于网桥式网络模型，这对于有多租户需求的场景尤为有用。由于各实例都有专用的MAC地址，因此MAC VLAN允许传输广播和多播流量，但它要求物理接口工作于混杂模式，考虑到很多公有云环境中并不允许使用混杂模式，这意味着MAC VLAN更适用于本地网络环境。  
  
IP VLAN类似于MAC VLAN，它同样创建新的虚拟网络接口并为每个接口分配唯一的IP地址，不同之处在于，每个虚拟接口将共享使用物理接口的MAC地址，从而不再违反防止MAC欺骗的交换机的安全策略，且不要求在物理接口上启用混杂模式  
  
虽然支持多种网络模型，但MAC VLAN和IP VLAN不能同时在同一物理接口上使用。Linux内核文档中强调，MAC VLAN和IP VLAN具有较高的相似度，因此，通常仅在必须使用IP VLAN的场景中才不使用MAC VLAN。  
  
“直接路由”模型放弃了跨主机容器在L2的连通性，而专注于通过路由协议提供容器在L3的通信方案。这种解决方案因为更易于集成到现在的数据中心的基础设施之上，便捷地连接容器和主机，并在报文过滤和隔离方面有着更好的扩展能力及更精细的控制模型，因而成为容器化网络较为流行的解决方案之一。  
  
①Flannel host-gw使用存储总线etcd和工作在每个节点上的flanneld进程动态维护路由;  
②Calico使用BGP（Border Gateway Protocol）协议在主机集群中自动分发和学习路由信息。与Flannel不同的是，Calico并不会为容器在主机上使用网桥，而是仅为每个容器生成一对veth设备，留在主机上的那一端会在主机上生成目标地址，作为当前容器的路由条目，如图10-13所示。  
  
显然，较Overlay来说，无论是MAC VLAN、IP VLAN还是直接路由机制的Underlay网络模型的实现，它们因无须额外的报文开销而通常有着更好的性能表现，但对底层网络有着更多的限制条件。  
---
  
# eBPF  
https://mp.weixin.qq.com/s/xnkTIBeVzvMdToPXYrhPMA  
eBPF 使应用程序能在操作系统的内核中运行，并在不更改内核源代码的情况下对内核进行检测。  
eBPF 程序在内核版本之间是可移植的，并且可以自动更新，从而避免了工作负载中断和节点重启。  
eBPF 程序可以在加载时进行验证，以防止内核崩溃或其他不稳定性因素。  
  
eBPF 程序，在内核中运行并对事件做出反应。  
用户空间程序，将 eBPF 程序加载到内核并与之交互。  
BPF Maps (hash maps, arrays, ring / perf buffer)，它允许用户空间程序和内核中的 eBPF 程序之间的数据存储和信息共享。  
  
eBPF 程序使用 BPF 映射实现了内核和用户空间之间的可见性。  
eBPF 之于内核就像 JavaScript 之于 Web 浏览器。  
eBPF 支持下一代服务网格，不需要使用 sidecar 检测 pod ，并可以在不更改任何应用程序或配置的情况下实现高性能。  
