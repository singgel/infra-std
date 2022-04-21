<!--
 * @Author: your name
 * @Date: 2022-04-13 11:19:14
 * @LastEditTime: 2022-04-21 14:27:11
 * @LastEditors: your name
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 * @FilePath: /infra-std/server_less/serviceless_desc.md
-->
## 概念

Serverless，正如其字面意义，是一种“无服务器架构”。它并不指代某种技术，或某种实现。这个概念比较贴近于RESTful之于HTTP API设计，微服务之于后端架构，类似于一种“设计思路”。

Serverless并不意味着没有服务器（当然，没有服务器是不可能的），只不过对于业务开发者来说，不必再关注服务器，解放心智，去关心业务本身的实现。演进的来讲：

-   物理机时代：你可能需要关注物理机本身的网络状况、配置资源、运行环境、操作系统……
-   虚拟机时代：情况并没有好转，你甚至额外需要考虑配置虚拟网络、虚拟机的资源配置……
-   容器时代：稍微轻松了一些，一套配置“走遍天下”，但你仍然需要知道一些具体的资源配置……

Wait，至此为止，除了开发业务之外，每个“时代”都对业务开发者的“非业务相关”能力具有一定的要求。这使得即使在分工明确的团队中，在拥有全自动运维平台的情况下（比如SCM和TCE），仍然一定的必要去了解这些知识。我们知道，Service Mesh已经使中间件彻底从业务应用中被剥除，那么是否有一种方案也能完全隔离这些呢？Serverless应运而生。

Serverless到目前为止，还没有严格而统一的定义，但大部分Serverless解决方案均由FaaS和BaaS两部分组成，BaaS(Backend as a Service)指不再编写、管理服务端组件（如数据库、消息队列等），转而使用云上资源，这使得我们不必在自己搭建、管理基础组件。FaaS(Function as a Service)则指我们不再部署一个“进程”（比如一个ELF、或者Jar/War），而是直接部署单个函数的代码。

举个例子，假设有一个类似platform-api服务：

1.  代码结构：编写接入代码->将代码通过框架组织起来
1.  部署上线：编译->编排容器->切换流量
1.  用户访问：容器->服务进程->函数

对于我们而言，我们实质上只关心接入代码部分，框架代码和部署上线的过程我们实际并不关心~~（只要能work就可以）~~。

Serverless中FaaS的部分就是基于我们以上的观点，既然我们实质上只关心接入代码，那么其余部分便应当全部由Serverless组件代管，而我们只编写这部分代码。

Serverless时代，容器、虚拟机并不会消失，会长期存在。但作为一个上层应用开发者，“服务跑在哪里？”、“进程挂了怎么办？”，“消息队列、数据库情况如何？”这样的问题我们将不必再关心，你只需要关心自己的代码是否合乎需求~~（有没有BUG）~~。

## 设计

Serverless架构下开发业务显然是一件舒适的事情，对于一个应用来说，基础组件（例如：数据库）可以从BaaS中获得，接口则使用FaaS开发。大部分的FaaS SDK均具备了一定的接入BaaS能力，即使SDK没有提供这些功能，使用语言本身来接入这些基础组件也并非难事。

Serverless架构下弹性伸缩、负载均衡、监控报警、熔断降级等一系列功能均无需业务开发介入，只需要进行配置即可。

因为并不参与到服务进程的编排过程中，所以FaaS函数都是无状态的。你编写的函数要么是“纯函数”（这似乎不太可能），要么则需要使用数据库或缓存系统来存储中间状态，这会带来一定的性能开销。对于性能高度敏感的应用还不适用这种模式，同时，如果你的应用对硬件有硬性要求（比如GPU要求），那么选择FaaS也不是一个很好的选择。

说完这些，我们介绍一个典型的Serverless架构下的应用模型，这里以一个网页应用为例：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0da57795ffab42a7b10c9899d0cd1a9f~tplv-k3u1fbpfcp-zoom-1.image)

当然，Serverless提供的基础组件若更多，自然也有不同的结构。此处只当抛砖引玉。

## 现有解决方案

### AWS Lambda

AWS Lambda是Serverless领域的先行者，是一套比较成熟的解决方案。目前每月可免费使用37小时（函数不在执行期间不计时），100万次请求，配合永久免费25G的Amazon DynamoDB，对于小用户而言基本免费。

AWS Lambda可以简单地与S3（对象存储）、DynamoDB （关系存储）、Kinesis （流式处理引擎）、 SNS（消息推送）进行联动。支持弹性伸缩、高可用等。开发语言支持Go、Node.js、Java、Ruby、Python 3以及C#（.NET Core）

Ref:[ AWS Lambda官方介绍](https://aws.amazon.com/cn/lambda/)




## 参考资料

1.  [BaaS、FaaS、Serverless都是什么馅儿？](http://www.broadview.com.cn/article/792)
1.  [Serverless vs 容器：Serverless终将胜出！](https://zhuanlan.zhihu.com/p/31086566)
1.  [Serverless 架构应用开发指南](https://github.com/phodal/serverless)
1.  [精读《Serverless 给前端带来了什么》](https://zhuanlan.zhihu.com/p/58877583)
1.  [Serverless 是进步的还是退步的？](https://zhuanlan.zhihu.com/p/62666803)