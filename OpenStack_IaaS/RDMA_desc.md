# 简介
什么是RDMA在数据中心领域，远程直接内存访问（英语：remote direct memory access，RDMA）是一种绕过远程主机操作系统内核访问其内存中数据的技术，由于不经过操作系统，不仅节省了大量CPU资源，同样也提高了系统吞吐量、降低了系统的网络通信延迟，尤其适合在大规模并行计算机集群中有广泛应用。在基于NVMe over Fabric的数据中心中，RDMA可以配合高性能的NVMe SSD构建高性能、低延迟的存储网络。  
  
RDMA支持零复制网络传输，通过使网络适配器直接在应用程序内存间传输数据，不再需要在应用程序内存与操作系统缓冲区之间复制数据。这种传输不需要中央处理器、CPU缓存或上下文切换参与，并且传输可与其他系统操作并行。当应用程序执行RDMA读取或写入请求时，应用程序数据直接传输到网络，从而减少延迟并实现快速的消息传输。  
但是，这种策略也表现出目标节点不会收到请求完成的通知（单向通信）等相关的若干问题。  
  
如其他高性能计算（HPC）互连技术一样，截至2013年，由于需要安装不同的网络基础设施，RDMA已得到了有限的接受。但是，诸如iWARP等新标准也使以太网RDMA被实现于物理层，它使用TCP/IP作为传输方式，将基于标准的解决方案相结合，带来了RDMA的性能和低延迟优势以及较低的成本  

# RDMA 三种不同的硬件实现
RDMA作为一种host-offload, host-bypass技术，使低延迟、高带宽的直接的内存到内存的数据通信成为了可能。目前支持RDMA的网络协议有：  
## InfiniBand(IB):   
从一开始就支持RDMA的新一代网络协议。由于这是一种新的网络技术，因此需要支持该技术的网卡和交换机。  
  
## RDMA基于融合以太网(RoCE): 
即RDMA over Converged Ethernet, 允许通过以太网执行RDMA的网络协议。这允许在标准以太网基础架构(交换机)上使用RDMA，只不过网卡必须是支持RoCE的特殊的NIC。  
  
## 互联网广域RDMA协议(iWARP): 
即RDMA over TCP, 允许通过TCP执行RDMA的网络协议。这允许在标准以太网基础架构(交换机)上使用RDMA，只不过网卡要求是支持iWARP(如果使用CPU offload的话)的NIC。否则，所有iWARP栈都可以在软件中实现，但是失去了大部分的RDMA性能优势。  
  
## InfiniBand - RDMA

基于以太网融合的RDMA（RoCE）基于融合以太网的RDMA（英语：RDMA over Converged Ethernet，缩写RoCE）是一个网络协议，允许在一个以太网网络上使用远程直接内存访问（RDMA）。RoCE有RoCE v1和RoCE v2两个版本。RoCE v1是一个以太网链路层协议，因此允许同一个以太网广播域中的任意两台主机间进行通信。RoCE v2是一个网络层协议，因而RoCE v2数据包可以被路由。虽然RoCE协议受益于融合以太网网络的特征，但该协议也可用于传统或非融合的以太网网络

网络密集型应用程序（如网络存储或群集计算）需要具有高带宽且低延迟的网络基础架构。RDMA相比其他网络应用程序接口（诸如Berkeley套接字）的优势是更低的延迟、更低的CPU占用，以及更高的带宽。RoCE协议有着比其前身iWARP协议更低的延迟。  
  
##  RoCE v1RoCE 
v1是一个以太网链路层协议，因此允许同一个以太网广播域中的任意两台主机间进行通信。Ethertype为0x8915。它要符合以太网协议的帧长度限制：常规以太网帧为1500字节，巨型帧为9000字节。  
##  RoCE v2RoCE 
v2是一个网络层协议，因而RoCE v2数据包可以被路由。  
RoCEv2协议构筑于UDP/IPv4或UDP/IPv6协议之上。UDP目标端口号4791已保留给RoCE v2。因为RoCEv2数据包是可路由的，所以RoCE v2协议时被称为Routable RoCE或RRoCE。  
虽然一般不保证UDP数据包的传达顺序，但RoCEv2规范要求，有相同UDP源端口及目标地址的数据包不得改变顺序。  
除此之外，RoCEv2定义了一种拥塞控制机制，使用IP ECN位用于标记，CNP帧用于送达通知。软件对RoCE v2的支持在不断涌现。Mellanox OFED2.3或更高版本支持RoCE v2，Linux内核v4.5也提供支持。  
  
RoCE与InfiniBand相比RoCE定义了如何在以太网上执行RDMA，InfiniBand架构规范则定义了如何在一个InfiniBand网络上执行RDMA。RoCE预期为将主要面向群集的InfiniBand应用程序带入到一个寻常的以太网融合结构  

# RoCE与InfiniBand协议之间的技术差异：  
##  链路级流量控制
InfiniBand使用一个积分算法来保证无损的HCA到HCA通信。RoCE运行在以太网之上，其实现可能需要“无损以太网”以达到类似于InfiniBand的性能特征，无损以太网一般通过以太网流量控制或优先流量控制（PFC）配置。配置一个数据中心桥接（DCB）以太网网络可能比配置InfiniBand网络更为复杂。  
##  拥塞控制
Infiniband定义了基于FECN/BECN标记的拥塞控制，RoCEv2则定义了一个拥塞控制协议，它使用ECN标记在标准交换机中的实现，以及CNP帧用于送达确认。  
可用的InfiniBand交换机始终有比以太网交换机更低的延迟。  
一台特定类型以太网交换机的端口至端口延迟为230纳秒，而有相同端口数量的一台InfiniBand交换机为100纳秒  

RoCE与iWARP相比相比RoCE协议定义了如何使用以太网和UDP/IP帧执行RDMA，iWARP协议定义了如何基于一个面向连接的传输（如传输控制协议，TCP）执行RDMA。RoCE v1受限于单个广播域，RoCE v2和iWARP封包则可以路由。在大规模数据中心和大规模应用程序（即大型企业、云计算、Web 2.0应用程序等）中使用iWARP时，大量连接的内存需求，以及TCP的流量和可靠性控制，将会导致可扩展性和性能问题。此外，RoCE规范中定义了多播，而当前的iWARP规范中没有定义如何执行多播RDMA。  
iWARP中的可靠性由协议本身提供，因为TCP/IP为可靠传输。相比而言，RoCEv2采用UDP/IP，这使它有更小的开销和更好的性能，但不提供固有可靠性，因此可靠性必须搭配RoCEv2实现。其中一种解决方案是，使用融合以太网交换机使局域网变得可靠。这需要局域网内的所有交换机支持融合太网，并防止RoCEv2数据包通过诸如互联网等不可靠的广域网传输。另一种解决方案是增加RoCE协议的可靠性（即可靠的RoCE），向RoCE添加手，通过牺牲性能为代价提供可靠性。  
  

# 参考资料
- [基于融合以太网的RDMA-wikipedia.](https://zh.wikipedia.org/wiki/%E5%9F%BA%E4%BA%8E%E8%9E%8D%E5%90%88%E4%BB%A5%E5%A4%AA%E7%BD%91%E7%9A%84RDMA)
- [远程直接内存访问 - wikipedia.](https://zh.wikipedia.org/wiki/%E8%BF%9C%E7%A8%8B%E7%9B%B4%E6%8E%A5%E5%86%85%E5%AD%98%E8%AE%BF%E9%97%AE)
[RDMA专栏-知乎](https://www.zhihu.com/column/rdmatechnology)
[RDMA技术详解（一）：RDMA概述 - 知乎.](https://zhuanlan.zhihu.com/p/55142557)
https://en.wikipedia.org/wiki/IWARP