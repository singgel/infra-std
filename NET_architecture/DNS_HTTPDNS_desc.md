1.  # DNS

**域名系统（Domain Name System，DNS）** 是一项提供**域名和IP地址映射查询**的互联网基础服务。

## 1.1 基本概念

众所周知，IP地址标识了主机的地址，但是IP地址 却难以被人所记忆，后来大家搞了个域名。

**域名(Domain Name)** 是一个可以在互联网上**标识主机或主机组的名称**，相当于 IP 地址的别名；这个名称通常是有特定含义的，相对于IP地址，域名更容易被人理解和记忆。

而域名和IP地址(组) 的映射关系，我们需要使用类似通讯录的本子记录起来，比如放在我们主机的Host文件中，当基于域名发起网络请求时，只要到Host文件中查一下就行了：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1e5a3b85a6b546d69d5c4a241877a3f0~tplv-k3u1fbpfcp-zoom-1.image)

***

伴随着域名越来越多，Host文件也越来越难管理，映射规则一改变，每个用户都要去修改自己的文件，工作重复且容易出错。这时候可以搞个服务器出来，**专门处理这个映射关系**，用户需要查域名对应的主机时，只要到这个服务器查一下就行了。

这类服务器被称之为 **域名解析服务器（Domain Name Server），** 专门用来解析域名：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/99b3647431f84d0da1b62736adee3920~tplv-k3u1fbpfcp-zoom-1.image)

我们的主机可以通过 /etc/resolv.conf 直接配置DNS服务器，如：`nameserver 10.91.0.1` ；

这个和我们**本地主机直接关联的** **DNS** **服务器 通常被称作 LocalDNS**，**Local是相对于本机**来讲的。如果通过[DHCP](https://blog.51cto.com/longlei/2063336)自动配置，LocalDNS 一般由互联网服务提供商（ISP，如联通、电信）提供；当然，你也可以配置为任意一台DNS服务器，比如[阿里提供的公共DNS服务器](https://www.alidns.com/knowledge?type=SETTING_DOCS#user_linux)。

***

一般而言，LocalDNS并不直接管理 域名和IP地址(组)的映射关系，而是到其他DNS服务器进行查询，查到结果后会缓存起来，下次就可以直接返回了。

为了保证数据的一致，**DNS的资源记录都会有一个TTL字段**（Time to Live），超过这个时间后，DNS服务器会将记录对应的缓存删除，下次再重新获取最新的数据。

无论是 **域名和IP地址(组)的映射 还是TTL**，是由**域名对应的 【权威DNS服务器】** 进行管理，其本身的DNS资源记录 不会自动过期。相对而言，基于缓存获取的DNS服务器可以认为是**非权威DNS服务器**。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/75d632549c0c4f90962454f20f840b22~tplv-k3u1fbpfcp-zoom-1.image)

## 1.2 域名、区域（DNS解析范围）

域名（Domain Name）是分层管理的：

-   最高层的域是根域(root)，空字符串。

-   根域下一层就是第二层次的顶级域（top-level domains，TLD）：

    -   按组织性质划分：com(商业组织)、org(非盈利组织)、edu(教育组织)、gov(政府机构)等
    -   按国家划分：cn(中国)、uk(英国)、us(美国)、.jp(日本)

-   顶级域下就是普通的域了，**公司或个人注册的域名**一般都是这些普通的域，如**baidu**.com

-   每个普通域下可以继续划分子域，如 **tieba**.baidu.com 、**www**.baidu.com

从域的命名空间上看：

1.  所有的域名都挂在 根域下；
1.  baidu.com域以及其所有子域 都挂在 com域下；
1.  tieba.baidu.com/a.tieba.baidu.com/www.baidu.com都挂在 baidu.com域下；

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/70a784e821fa486091902e1e6068bf3a~tplv-k3u1fbpfcp-zoom-1.image)

> 严格来讲，【www.baidu.com】对应的 域名应该为 【www.baidu.com.】最后的点之后为根域

***

那么域名和DNS服务器是怎样对应的呢？以**根域名DNS服务器**（Root Name Server）为例，它会管理 根域下的所有域名和IP地址(组)的映射关系吗？

事实上并不会，**DNS服务器只会负责一个区域**（Zone）的解析工作；**一个区域只是域中的一部分。**

如下图，**根域名DNS服务器**只管 根区域的事，如果有 www.baidu.com 这样的地址过来，它告诉你去.com区域那边解析：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a53a7e35c7ad4f1cb5882936cfd11d90~tplv-k3u1fbpfcp-zoom-1.image)

所谓**域中的一部分**，看下图可能理解更加容易，比如：

1.  DNS服务器A <-> baidu.com区域：管理 baidu.com和www.baidu.com

    1.  如果域名是baidu.com、www.baidu.com 则可以直接给出结果；
    1.  如果域名是aa.tieba.baidu.com 则让它到tieba.baidu.com区域对应的DNS服务器查找（当然，也可以使用CNAME转到其他域名上，见1.4节）

1.  DNS服务器B <-> tieba.baidu.com区域：管理 tieba.baidu.com以及其下的所有子域名的映射。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7210d809713143a9b502e0cd58c11892~tplv-k3u1fbpfcp-zoom-1.image)

## 1.3 迭代查询和递归查询

当我们输入www.baidu.com访问一个网站是，一个基本的流程为：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/aabd90cbbddc42fa8ede492eacea8dfb~tplv-k3u1fbpfcp-zoom-1.image)

从LocalDNS的角度看：根域DNS服务器为了减轻负载，并没有自己去查最终结果返回；而是返回 .com域的DNS服务器地址，让LocalDNS自己迭代去查，这个流程称之为 **迭代查询**；

如果根域DNS服务器 自己到 .com域DNS查，.com到 baidu.com域DNS查...最终得到结果返回给LocalDNS，这个流程就被称之为 **递归查询** 了。显然根域是不允许给LocalDNS做递归查询的，不然全世界都过来，压力就太大了。

递归的意思是找了谁谁就一定要给出答案，从 **我的主机 的角度**看，LocalDNS是直接给出了最终结果，我的主机 不用再到其他DNS服务器查了，我的主机 -> LocalDNS 这块可以认为是递归查询：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bf19d80984dd440aa2e86d2f00f14aa9~tplv-k3u1fbpfcp-zoom-1.image)

## 1.4 DNS的资源记录（Resource Record, RR）

DNS服务器中资源记录类型主要包含：

| 记录类型                  | 含义                                                          | 例子                                                                                                               |
| --------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| A（Address）            | 域名 > IPV4                                                   | baidu.com. 3600 IN A 39.156.69.79（IN表示因特网的意思）                                                                    |
| AAAA                  | 域名 > IPV6                                                   | a.root-servers.net. 3600 IN AAAA 2001:503:ba3e::2:30                                                             |
| CNAME（Canonical Name） | 域名 > 另外一个域名                                                 | www.baidu.com. 3600 IN CNAME www.a.shifen.com.                                                                 |
| NS（Name Server）       | 指定(子)域名由哪个区域DNS服务器处理；NS记录通常和A记录一起，表示(子)域名将转到哪个Name Server处理 | 比如 baidu.com的DNS服务器中：tieba.baidu.com. 3600 IN NS dns.tieba.baidu.com.dns.tieba.baidu.com. 3600 IN A 39.156.69.79 |
| MX                    | 发送时的邮箱域名 > 真正邮箱服务的域名                                        | 比如自己申请了一个域名：aaa.com，新增MX记录：aaa.com. 3600 IN MX 10 mx1.qq.com.当发送123456@aaa.com，会解析到mx1.qq.com对应的ip地址            |

CNAME的好处主要在于：

1.  A记录方便管理：比如 域名A 和 域名B 都指向 同一组IP，如果都各自绑定A记录，后期维护就比较麻烦了。一种解决就是新增一个域名C，由域名C直接和 IP组绑定；域名A/B只需增加一个CNAME指过去域名C即可。
1.  用于CDN加速：即将域名转向由CDN服务商提供的域名，从而提高CDN加速服务
2.  # HTTP DNS

## 2.1 传统DNS的问题

### 2.1.1 不稳定的性能

尽管有距离较近的DNS服务器能够做缓存，但是TTL过后，仍然会到更远的DNS服务器查询，这时候会导致一个情况：就是好的时候几毫秒就行了，坏的时候则可能达到秒级（[有赞称遇过1.5s的case](https://tech.youzan.com/youzan-webview-goldwing-one/)）；

解决的方案主要是 做一些预加载动作（prefetch），HTTPDNS的客户端会专门处理这块。

另外一个情况是域名过多，可能一个页面的数据会涉及多个域名，每个都会有一定的DNS解析损耗。

解决的方案主要是 对域名进行收敛，聚合分散的域名，参考：[浅谈域名发散与域名收敛](https://github.com/chokcoco/cnblogsArticle/issues/1)

### 2.1.2 不准确​的调度（负载均衡/CDN）

理想的情况下：我们应该可以实时观察和调度各个地区、各个运营商的网络流量 以及 服务器资源；而用户则应该总能 获取到 访问速度最快的IP地址（离得近+不跨网）。

事实上，传统DNS要做到这点并不容易，主要体现在：

1.  **DNS缓存**：当域名有缓存后，在TTL时间内是不会再去访问 权威DNS服务器了，这段时间内**作出任何调整**，**客户端都是无感知**的，比如某个机房出事了，需要临时将部分IP删除，以保证用户正常访问，但是显然TTL时间内还是会有问题；又或者新增了一些和用户邻近的IP，用户TTL时间内还是不会去访问等等。尽管可以缩短TTL以减少不一致的时间，但是问题依然存在；

1.  **运营商问题**：用户常用的LocalDNS都是由网络运营商提供的（电信/联通/移动），如果LocalDNS直接发起请求到权威DNS服务器，权威DNS服务器会根据 请求者的IP 做负载均衡和CDN加速，比如广东电信就返回广东电信那边的IP。以下两种情况会导致这种策略失效：

    1.  **运营商偷工减料**：一些小运营商自己的DNS服务器不做迭代查询，而是直接转到另外一个运营商的DNS服务器做解析，**来源IP的运营商改变** 导致 **DNS的调度策略有问题**。
    1.  **LocalDNS出口NAT**：比如电信的LocalDNS，尽管没转到其他的DNS，但是它的出口网络的IP地址变成了其他运营商的IP地址了（如联通），同样导致 **来源IP的运营商发生变化，导致DNS调度策略有问题**。

更详细的介绍可以参考：[腾讯提出的传统DNS的问题](https://mp.weixin.qq.com/s/u6-53Kp9Jb48dKWzaJOKig)

### 2.1.3 域名劫持

由于 DNS 缺乏 **加密、认证、完整性保护**的安全机制，容易引发网络完全问题。

DNS目前主流的通信协议为无需建立连接的UDP协议：

1.  请求时：LocalDNS发送域名到上层的DNS，UDP报文会带有一个序列号；
1.  响应时：LocalDNS收到响应报文，找到那个序列号对应的请求进行处理：缓存域名和IP地址。

如果有攻击者在上层DNS返回结果前，直接给LocalDNS发送一个UDP报文（猜对了序列号），那LocalDNS会直接接受这个报文了，从而导致域名指向的IP由攻击者指定。

***

常见[域名劫持现象](https://help.aliyun.com/knowledge_detail/62842.html)：

-   广告劫持：用户正常页面指向到广告页面。

<!---->

-   恶意劫持：域名指向IP被改变，将用户访问流量引到挂马，盗号等对用户有害页面的劫持。

<!---->

-   LocalDNS缓存：为了降低跨网流量及用户访问速度进行的一种劫持，导致域名映射不能按时更新。

## 2.2 HTTPDNS 基本介绍

HTTPDNS是**基于HTTP协议**，面向多端应用（移动端APP，PC客户端应用）的域名解析服务，具有域名防劫持、精准调度、实时解析生效的特性。

HTTPDNS服务和普通的业务服务类似，只不过它是专门用于解析域名的。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/df6738cf176146ad92c50324d98a8f1a~tplv-k3u1fbpfcp-zoom-1.image)

###