# RPC定义

RPC（Remote Procedure Call Protocol）远程过程调用协议。一个通俗的描述是：客户端在不知道调用细节的情况下，调用存在于远程计算机上的某个对象，就像调用本地应用程序中的对象一样。比较正式的描述是：一种通过网络从远程计算机程序上请求服务，而不需要了解底层网络技术的协议。那么我们至少从这样的描述中挖掘出几个要点：

-   RPC是协议：既然是协议就只是一套规范，那么就需要有人遵循这套规范来进行实现。目前典型的RPC实现包括：Dubbo、Thrift、GRPC等。这里要说明一下，目前技术的发展趋势来看，实现了RPC协议的应用工具往往都会附加其他重要功能，例如Dubbo还包括了服务治等功能。
-   网络协议和网络IO模型对其透明：既然RPC的客户端认为自己是在调用本地对象。那么传输层使用的是TCP/UDP还是HTTP协议，又或者是一些其他的网络协议它就不需要关心了。既然网络协议对其透明，那么调用过程中，使用的是哪一种网络IO模型调用者也不需要关心。
-   信息格式对其透明：我们知道在本地应用程序中，对于某个对象的调用需要传递一些参数，并且会返回一个调用结果。至于被调用的对象内部是如何使用这些参数，并计算出处理结果的，调用方是不需要关心的。那么对于远程调用来说，这些参数会以某种信息格式传递给网络上的另外一台计算机，这个信息格式是怎样构成的，调用方是不需要关心的。
-   应该有跨语言能力：为什么这样说呢？因为调用方实际上也不清楚远程服务器的应用程序是使用什么语言运行的。那么对于调用方来说，无论服务器方使用的是什么语言，本次调用都应该成功，并且返回值也应该按照调用方程序语言所能理解的形式进行描述。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/52cc9a4856c745e785f4237668b2be09~tplv-k3u1fbpfcp-zoom-1.image)

# RPC主要组成部分

当然，上图是作为RPC的调用者所观察到的现象（而实际情况是客户端或多或少的还是需要知道一些调用RPC的细节）。但是我们是要讲解RPC的基本概念，所以RPC协议内部是怎么回事就要说清楚：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/33127cb74815415386d29dffbc72f31e~tplv-k3u1fbpfcp-zoom-1.image)

**Client：**RPC协议的调用方。就像上文所描述的那样，最理想的情况是RPC Client在完全不知道有RPC框架存在的情况下发起对远程服务的调用。但实际情况来说Client或多或少的都需要指定RPC框架的一些细节。

**Server**在RPC规范中，这个Server并不是提供RPC服务器IP、端口监听的模块。而是远程服务方法的具体实现（在JAVA中就是RPC服务接口的具体实现）。其中的代码是最普通的和业务相关的代码，甚至其接口实现类本身都不知道将被某一个RPC远程客户端调用。

**Stub/Proxy**RPC代理存在于客户端，因为要实现客户端对RPC框架“透明”调用，那么客户端不可能自行去管理消息格式、不可能自己去管理网络传输协议，也不可能自己去判断调用过程是否有异常。这一切工作在客户端都是交给RPC框架中的“代理”层来处理的。

**Message Protocol**在上文我们已经说到，一次完整的client-server的交互肯定是携带某种两端都能识别的，共同约定的消息格式。RPC的消息管理层专门对网络传输所承载的消息信息进行编码和解码操作。目前流行的技术趋势是不同的RPC实现，为了加强自身框架的效率都有一套（或者几套）私有的消息格式。

**Transfer/Network Protocol**传输协议层负责管理RPC框架所使用的网络协议、网络IO模型。例如Hessian的传输协议基于HTTP（应用层协议）；而Thrift的传输协议基于TCP（传输层协议）。传输层还需要统一RPC客户端和RPC服务端所使用的IO模型；

**Selector/Processor**存在于RPC服务端，用于服务器端某一个RPC接口的实现的特性（它并不知道自己是一个将要被RPC提供给第三方系统调用的服务）。所以在RPC框架中应该有一种“负责执行RPC接口实现”的角色。包括：管理RPC接口的注册、判断客户端的请求权限、控制接口实现类的执行在内的各种工作。

**IDL**实际上IDL（接口定义语言）并不是RPC实现中所必须的。但是需要跨语言的RPC框架一定会有IDL部分的存在。这是因为要找到一个各种语言能够理解的消息结构、接口定义的描述形式。如果您的RPC实现没有考虑跨语言性，那么IDL部分就不需要包括，例如JAVA RMI因为就是为了在JAVA语言间进行使用，所以JAVA RMI就没有相应的IDL。

# 影响RPC框架性能的因素

在物理服务器性能相同的情况下，以下几个因素会对一款RPC框架的性能产生直接影响：

**使用的网络****IO模型**RPC服务器可以只支持传统的阻塞式同步IO，也可以做一些改进让RPC服务器支持非阻塞式同步IO，或者在服务器上实现对多路IO模型的支持。这样的RPC服务器的性能在高并发状态下，会有很大的差别。特别是单位处理性能下对内存、CPU资源的使用率。

**基于的网络协议**一般来说您可以选择让您的RPC使用应用层协议，例如HTTP或者HTTP/2协议，或者使用TCP协议，让您的RPC框架工作在传输层。工作在哪一层网络上会对RPC框架的工作性能产生一定的影响，但是对RPC最终的性能影响并不大。但是至少从各种主流的RPC实现来看，没有采用UDP协议做为主要的传输协议的。

**消息封装格式**选择或者定义一种消息格式的封装，要考虑的问题包括：消息的易读性、描述单位内容时的消息体大小、编码难度、解码难度、解决半包/粘包问题的难易度。当然如果您只是想定义一种RPC专用的消息格式，那么消息的易读性可能不是最需要考虑的。消息封装格式的设计是目前各种RPC框架性能差异的最重要原因，这就是为什么几乎所有主流的RPC框架都会设计私有的消息封装格式的原因。dubbo中消息体数据包含dubbo版本号、接口名称、接口版本、方法名称、参数类型列表、参数、附加信息

**Schema 和序列化（Schema & Data Serialization）** ：序列化和反序列化，是对象到二进制数据的转换，程序是可以理解对象的，对象一般含有 schema 或者结构，基于这些语义来做特定的业务逻辑处理。考察一个序列化框架一般会关注以下几点： 

-   **Encoding format**:是 human readable（是否能直观看懂 json） 还是 binary(二进制)。 
-   **Schema declaration**:也叫作契约声明，基于 IDL，比如 Protocol Buffers/Thrift，还是自描述的，比如 JSON、XML另外还需要看是否是强类型的。 
-   **语言平台的中立性**:比如 Java 的 Native Serialization 就只能自己玩，而 Protocol Buffers 可以跨各种语言和平台。 
-   **新老契约的兼容性**:比如 IDL 加了一个字段，老数据是否还可以反序列化成功。 
-   **和压缩算法的契合度**:跑 benchmark (基准)和实际应用都会结合各种压缩算法，例如 gzip、snappy。 
-   **性能**:这是最重要的，序列化、反序列化的时间，序列化后数据的字节大小是考察重点。 

序列化方式非常多，常见的有 Protocol Buffers， Avro，Thrift，XML，JSON，MessagePack，Kyro，Hessian，Protostuff，Java Native Serialize，FST 。

**实现的服务处理管理方式**在高并发请求下，如何管理注册的服务也是一个性能影响点。您可以让RPC的Selector/Processor使用单个线程运行服务的具体实现（这意味着上一个客户端的请求没有处理完，下一个客户端的请求就需要等待）、您也可以为每一个RPC具体服务的实现开启一个独立的线程运行（可以一次处理多个请求，但是操作系统对于“可运行的最大线程数”是有限制的）、您也可以线程池来运行RPC具体的服务实现（目前看来，在单个服务节点的情况下，这种方式是比较好的）、您还可以通过注册代理的方式让多个服务节点来运行具体的RPC服务实现。

# Motan框架

<https://github.com/weibocom/motan/>

## Motan介绍

Motan是一套基于java开发的RPC框架，除了常规的点对点调用外，motan还提供服务治理功能，包括服务节点的自动发现、摘除、高可用和负载均衡等。Motan具有良好的扩展性，主要模块都提供了多种不同的实现，例如支持多种注册中心，支持多种rpc协议等。

## 架构概述

Motan中分为服务提供方(RPC Server)，服务调用方(RPC Client)和服务注册中心(Registry)三个角色。

-   Server提供服务，向Registry注册自身服务，并向注册中心定期发送心跳汇报状态；
-   Client使用服务，需要向注册中心订阅RPC服务，Client根据Registry返回的服务列表，与具体的Sever建立连接，并进行RPC调用。
-   当Server发生变更时，Registry会同步变更，Client感知后会对本地的服务列表作相应调整。

三者的交互关系如下图：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d520724cc5514e62b84bc368eac925d1~tplv-k3u1fbpfcp-zoom-1.image)

## 模块概述

Motan框架中主要有register、transport、serialize、protocol几个功能模块，各个功能模块都支持通过SPI进行扩展，各模块的交互如下图所示：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/308d7fdb8ec64082b0a14fc90f3cb9fc~tplv-k3u1fbpfcp-zoom-1.image)

**register**

用来和注册中心进行交互，包括注册服务、订阅服务、服务变更通知、服务心跳发送等功能；Server端会在系统初始化时通过register模块注册服务，Client端在系统初始化时会通过register模块订阅到具体提供服务的Server列表，当Server 列表发生变更时也由register模块通知Client。

**protocol**

用来进行RPC服务的描述和RPC服务的配置管理，这一层还可以添加不同功能的filter用来完成统计、并发限制等功能。

**serialize**

将RPC请求中的参数、结果等对象进行序列化与反序列化，即进行对象与字节流的互相转换；默认使用对java更友好的hessian2进行序列化。

**transport**

用来进行远程通信，默认使用Netty nio的TCP长链接方式。

**cluster**

Client端使用的模块，cluster是一组可用的Server在逻辑上的封装，包含若干可以提供RPC服务的Server，实际请求时会根据不同的高可用与负载均衡策略选择一个可用的Server发起远程调用。

在进行RPC请求时，Client通过代理机制调用cluster模块，cluster根据配置的HA和LoadBalance选出一个可用的Server，通过serialize模块把RPC请求转换为字节流，然后通过transport模块发送到Server端。

# Dubbo框架

官方网址：<http://dubbo.apache.org/zh-cn/>

## Dubbo介绍

Dubbo是阿里巴巴公司开源的一个高性能优秀的服务框架，使得应用可通过高性能的 RPC 实现服务的输出和输入功能，可以和spring框架无缝集成。是一个分布式服务框架，以及SOA治理方案。其功能主要包括：高性能NIO通讯及多协议集成，服务动态寻址与路由，软负载均衡与容错，依赖分析与降级等。

## Dubbo工作原理

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6a0d5107558c43b88aa5ecb7108d5f4f~tplv-k3u1fbpfcp-zoom-1.image)

## Dubbo架构与设计

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8e8f071c63674c028c89d9044fa3406d~tplv-k3u1fbpfcp-zoom-1.image)

# SOFARPC框架

官方文档：<http://www.sofastack.tech/sofa-rpc/docs/Structure-Intro>

## 介绍

SOFA 是蚂蚁金服自主研发的金融级分布式中间件，包含了构建金融级云原生架构所需的各个组件，包括微服务研发框架，RPC 框架，服务注册中心，分布式定时任务，限流/熔断框架，动态配置推送，分布式链路追踪，Metrics监控度量，分布式高可用消息队列，分布式事务框架，分布式数据库代理层等组件，是一套分布式架构的完整的解决方案，也是在金融场景里锤炼出来的最佳实践。

## 架构图

核心层：包含了我们的 RPC 的核心组件（例如我们的各种接口、API、公共包）以及一些通用的实现（例如随机等负载均衡算法）。

功能实现层：所有的功能实现层的用户都是平等的，都是基于扩展机制实现的。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/647d10890c5e488683eff760259786c7~tplv-k3u1fbpfcp-zoom-1.image)

## 模块划分

各个模块的实现类都只在自己模块中出现，一般不交叉依赖。需要交叉依赖的全部已经抽象到core或者common模块中。

目前模块划分如下:

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2bfc7ab19d1845a683333f97ed261d01~tplv-k3u1fbpfcp-zoom-1.image)

# Thrift框架

Thrift官方：<http://thrift.apache.org/>

## Thrift介绍

Thrift是一个跨语言的服务部署框架，最初由Facebook于2007年开发，2008年进入Apache开源项目。Thrift通过一个中间语言(IDL, 接口定义语言)来定义RPC的接口和数据类型，然后通过一个编译器生成不同语言的代码（目前支持C++,Java, Python, PHP, Ruby, Erlang, Perl, Haskell, C#, Cocoa, Smalltalk和OCaml）,并由生成的代码负责RPC协议层和传输层的实现。

Thrift实际上是实现了C/S模式，通过代码生成工具将接口定义文件生成服务器端和客户端代码（可以为不同语言），从而实现服务端和客户端跨语言的支持。用户在Thirft描述文件中声明自己的服务，这些服务经过编译后会生成相应语言的代码文件，然后用户实现服务（客户端调用服务，服务器端提服务）便可以了。其中protocol（协议层, 定义数据传输格式，可以为二进制或者XML等）和transport（传输层，定义数据传输方式，可以为TCP/IP传输，内存共享或者文件共享等）被用作运行时库。

## Thrift协议栈

Thrift的协议栈如下图所示：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bead10bb2a244b59ab5c4d380c3b539b~tplv-k3u1fbpfcp-zoom-1.image)

在Client和Server的最顶层都是用户自定义的处理逻辑，也就是说用户只需要编写用户逻辑，就可以完成整套的RPC调用流程。用户逻辑的下一层是Thrift自动生成的代码，这些代码主要用于结构化数据的解析,发送和接收，同时服务器端的自动生成代码中还包含了RPC请求的转发（Client的A调用转发到Server A函数进行处理）。

协议栈的其他模块都是Thrift的运行时模块：

-   底层IO模块，负责实际的数据传输，包括Socket，文件，或者压缩数据流等。
-   TTransport负责以字节流方式发送和接收Message，是底层IO模块在Thrift框架中的实现，每一个底层IO模块都会有一个对应TTransport来负责Thrift的字节流(Byte Stream)数据在该IO模块上的传输。例如TSocket对应Socket传输，TFileTransport对应文件传输。
-   TProtocol主要负责结构化数据组装成Message，或者从Message结构中读出结构化数据。TProtocol将一个有类型的数据转化为字节流以交给TTransport进行传输，或者从TTransport中读取一定长度的字节数据转化为特定类型的数据。如int32会被TBinaryProtocol Encode为一个四字节的字节数据，或者TBinaryProtocol从TTransport中取出四个字节的数据Decode为int32。
-   TServer负责接收Client的请求，并将请求转发到Processor进行处理。TServer主要任务就是高效的接受Client的请求，特别是在高并发请求的情况下快速完成请求。
-   Processor(或者TProcessor)负责对Client的请求做出相应，包括RPC请求转发，调用参数解析和用户逻辑调用，返回值写回等处理步骤。Processor是服务器端从Thrift框架转入用户逻辑的关键流程。Processor同时也负责向Message结构中写入数据或者读出数据。
# Kite介绍

kite框架是一个基于thrift的RPC框架，基于微服务的架构设计，继承了微服务架构具备的各项组件和功能。

我们使用 Go 语言研发了内部的微服务框架 kite，协议上完全兼容 Thrift。以五元组为基础单元，我们在 kite 框架上集成了服务注册和发现，分布式负载均衡，超时和熔断管理，服务降级，Method 级别的指标监控，分布式调用链追踪等功能。目前统一使用 kite 框架开发内部 Go 语言的服务，整体架构支持无限制水平扩展。

公司内使用的框架rpc框架基本都是kite。这里就不过多介绍。 具体可以参考 <https://github.com/singgel/pages/viewpage.action?pageId=156892135>

# gRPC框架

官方中文版：<http://doc.oschina.net/grpc>

官方英文版：<https://grpc.io/docs/>

## gRPC介绍

gRPC是由Google主导开发的RPC框架，使用HTTP/2协议并用ProtoBuf作为序列化工具。其客户端提供Objective-C、Java接口，服务器侧则有Java、Golang、C++等接口，从而为移动端（iOS/Androi）到服务器端通讯提供了一种解决方案。

与许多 RPC 系统类似，gRPC 也是基于以下理念：定义一个服务，指定其能够被远程调用的方法（包含参数和返回类型）。在服务端实现这个接口，并运行一个 gRPC 服务器来处理客户端调用。在客户端拥有一个（存根）能够像服务端一样的方法。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/56c671399bce44b3b94795f600e6485c~tplv-k3u1fbpfcp-zoom-1.image)

## 实现原理

GRPC的Client与Server，均通过Netty Channel作为数据通信，序列化、反序列化则使用Protobuf，每个请求都将被封装成HTTP2的Stream，在整个生命周期中，客户端Channel应该保持长连接，而不是每次调用重新创建Channel、响应结束后关闭Channel（即短连接、交互式的RPC），目的就是达到链接的复用，进而提高交互效率。

# 百度brpc

官方文档：<https://github.com/brpc/brpc/blob/master/README_cn.md>

## brpc介绍

百度内最常使用的工业级RPC框架, 有1,000,000+个实例(不包含client)和上千种服务, 在百度内叫做"baidu-rpc". 目前只开源C++版本。

-   基于protobuf接口的RPC框架，也提供json等其他数据格式的支持
-   囊括baidu内部所有RPC协议，支持多种第三方协议
-   模块化设计，层次清晰，很容易添加自定义协议
-   全面的服务发现、负载均衡、组合访问支持
-   可视化的内置服务和调试工具
-   性能上领跑目前其他所有RPC产品

## brpc框架

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/84b8eb7e5402490190ff9790076e14ce~tplv-k3u1fbpfcp-zoom-1.image)

## brpc 72绝技

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4cff4d2590554a12824a70d730efd3eb~tplv-k3u1fbpfcp-zoom-1.image)

# 腾讯TARS

Tars官网 

<https://github.com/TarsCloud/Tars/blob/master/Introduction.md>

## 1.Tars介绍

Tars是基于名字服务使用Tars协议的高性能RPC开发框架，同时配套一体化的服务治理平台，帮助个人或者企业快速的以微服务的方式构建自己稳定可靠的分布式应用。

Tars是将腾讯内部使用的微服务架构TAF（Total Application Framework）多年的实践成果总结而成的开源项目。Tars这个名字来自星际穿越电影人机器人Tars，电影中Tars有着非常友好的交互方式，任何初次接触它的人都可以轻松的和它进行交流，同时能在外太空、外星等复杂地形上，超预期的高效率的完成托付的所有任务。拥有着类似设计理念的Tars也是一个兼顾易用性、高性能、服务治理的框架，目的是让开发更简单，聚焦业务逻辑，让运营更高效，一切尽在掌握。

## 2. 设计思想

Tars的设计思路是采用微服务的思想对服务进行治理，同时对整个系统的各个模块进行抽象分层，将各个层次之间相互解耦或者松耦合，如下图：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ba8c988008804d3aba1fdc1ba68895b5~tplv-k3u1fbpfcp-zoom-1.image)

最底的协议层，设计思路是将业务网络通信的协议进行统一，以IDL(接口定义语言)的方式，开发支持多平台、可扩展、协议代码自动生成的统一协议。在开发过程中，开发人员只需要关注通讯的协议字段的内容，不需要关注其实现的细节，大大减轻了开发服务时需要考虑的协议是否能跨平台使用、是否可能需要兼容、扩展等问题。

中间的公共库、通讯框架、平台层，设计思路是让业务开发更加聚焦业务逻辑的本身。因此，从使用者的角度出发，封装了大量日常开发过程中经常使用的公共库代码和远程过程调用，让开发使用更简单方便；从框架本身的角度出发，做到高稳定性、高可用性、高性能，这样才能让业务服务运营更加放心；从分布式平台的角度出发，解决服务运营过程中，遇到的容错、负载均衡、容量管理、就近接入、灰度发布等问题，让平台更加强大。

最上面的运营层，设计思路是让运维只需要关注日常的服务部署、发布、配置、监控、调度管理等操作。

## 3.Tars协议

tars协议是一种二进制、可扩展、代码自动生成、支持多平台（c++/java/iphone/android/symbian/kjava/mtk)的协议，其底层设计类似于google的protocol buffer，但是不完全一样，同时其实现完全自主开发，对细节完全可控。

tars协议主要应用在后台服务之间的网络传输协议，以及对象的序列化和反序列化等。

对于开发人员来说，Tars框架提供一套适合传输的、语言无关的通信协议，这就是tars协议。开发人员可以在tars协议文件中定义通信用的数据结构和服务提供的接口方法，为了提高开发效率并且减少错误，Tars框架还提供了工具来把协议转换成各种语言的数据结构，开发人员可以不必关注数据结构、服务基类和代理类的编写，把更多精力投入到业务逻辑的实现上。

# rcpx框架

官方网址<http://rpcx.site/>

## rcpx介绍

一个分布式的Go语言的 RPC 框架，支持Zookepper、etcd、consul多种服务发现方式，多种服务路由方式，类似于Dubbo的Go语言版。

## rcpx框架角色

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1ac4d0dc9f38495eacc0d696f44e8d90~tplv-k3u1fbpfcp-zoom-1.image)

节点角色说明:

**Provider**: 暴露服务的服务提供方。 

**Consumer**: 调用远程服务的服务消费方。

**Registry**: 服务注册与发现的注册中心。 

**Monitor**: 统计服务的调用次数、调用时间、服务机器状态监控的监控中心。 

调用关系说明： 

1. 服务提供者在启动时，向注册中心注册自己提供的服务。 

2. 服务消费者在启动时，向注册中心订阅自己所需的服务。 

3. 注册中心返回服务提供者地址列表给消费者，如果有变更，注册中心将基于长连接推送变更数据给消费者。

4. 服务消费者，从提供者地址列表中，基于软负载均衡算法，选一台提供者进行调用，如果调用失败，再选另一台调用。 

5. 服务消费者和提供者，在内存中累计调用次数和调用时间，定时每分钟发送一次统计数据到监控中心。

其核心功能包含: 

透明化的远程方法调用：就像调用本地方法一样调用远程方法，简单易接入。 

软负载均衡及容错机制：可在内网替代F5等硬件负载均衡器，降低成本，减少单点。 

服务自动注册与发现：不再需要写死服务提供方地址，注册中心基于接口名查询服务提供者的IP地址，并且能够平滑添加或删除服务提供者。

# OCTO-RPC 服务通信框架

官方地址：<https://github.com/Meituan-Dianping/octo-rpc>

## 框架介绍

OCTO 是 octopus(章鱼) 的缩写。是美团公司级基础设施，为公司所有业务提供统一的高性能服务通信框架，使业务具备良好的服务运营能力，轻松实现服务注册、服务自动发现、负载均衡、容错、灰度发布、数据可视化、监控告警等功能，提升服务开放效率、可用性及服务运维效率。

美团内部的Mtransport就是一套统一的服务通信框架，为近万个美团应用提供高效的通信服务，目前调用量上千亿。

美团致力于将Mtransport定位成一组高性能、高可用的企业级RPC通信框架，现将已在公司广泛使用，成熟稳定的Mtransport进行开源，开源后总名称为Octo-rpc，其中第一批包括Dorado（Java）、Whale（C++）两个语言版本，希望与业内同样有通信框架需求的团队同仁，在Octo-rpc基础上一起打造一款企业级优良的RPC通信框架产品。

## 工作原理

对服务开发者, MTransport 屏蔽了底层网络通信细节, 从而更专注于业务自身逻辑实现。支持不同语言版本的代码实现, 保持通信协议的一致性，支持服务注册、服务发现、异步通信、负载均衡等丰富的服务治理功能。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d972d7d90b6a4fe58a6d4c70cd95d925~tplv-k3u1fbpfcp-zoom-1.image)

## 整体架构

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/392a0d9839ba4e99b4b12259a788f858~tplv-k3u1fbpfcp-zoom-1.image)

# 参考资料地址

[服务化实战之 dubbo、dubbox、motan、thrift、grpc等RPC框架比较及选型 ](https://blog.csdn.net/liubenlong007/article/details/54692241)

[分布式服务序列化框架的使用与选型](https://mp.weixin.qq.com/s/J57xkUwQ0onPXwgNTKFD6g)

[java序列化框架（protobuf、thrift、kryo、fst、fastjson、Jackson、gson、hessian）性能对比 ](https://blog.csdn.net/fenglongmiao/article/details/79425218)

[RPC入门总结（一）RPC定义和原理 ](https://blog.csdn.net/kingcat666/article/details/78577079)

[thrift,gRPC,rpcx,motan,dubbox等rpc框架对比 ](http://www.voidcn.com/article/p-mkvzudsr-bpu.html)

[thrift源码研究－transport类体系研究总结 ](https://blog.csdn.net/whycold/article/details/8535932)

[Go RPC 开发指南 ](http://doc.rpcx.site/)

[RPC开源框架Dubbo, Motan, gRPC ](http://www.voidcn.com/article/p-tnbpkvmy-bov.html)

[Thrift RPC实战(一) 初次体验Thrift ](https://www.jianshu.com/p/bfd514fd0d6d)