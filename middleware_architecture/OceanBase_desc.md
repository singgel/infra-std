<!--
 * @Author: your name
 * @Date: 2022-04-18 16:54:51
 * @LastEditTime: 2022-04-18 16:55:27
 * @LastEditors: your name
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 * @FilePath: /infra-std/middleware_architecture/OceanBase_desc.md
-->
### 基于内存

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29ecc69ef6984e4998f2d830f8dbca34~tplv-k3u1fbpfcp-zoom-1.image)

### 容灾

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b0a788bf85cc49a2bf0ce75c197caa3e~tplv-k3u1fbpfcp-zoom-1.image)

OceanBase支持数据跨地域（Region）部署，不同Region通常距离较远，从而满足地域级容灾需求。事实上，目前蚂蚁金服内部的核心业务都是跨地域部署，保证地域级故障服务不停，数据不丢。

一个Region可以包含一个或者多个Zone，Zone是一个逻辑概念，是对物理机进行管理的容器，一般是同一机房的一组机器的组合。同一个分区的数据副本分布在多个Zone里，其中分区的主副本所在的Zone称为Primary Zone。可以为分区指定一个Zone的列表，当分区需要切主的时候，容灾策略会按照这个列表的顺序决定新主的偏好位置。如果不设定primary zone，系统会根据负载均衡的策略，在多个全功能副本里自动选择一个作为leader。

只读Zone是一种特殊的Zone，在这个Zone里，只部署只读副本。通常当多数派副本故障的时候，OceanBase会停止服务，但在这种情况下，只读Zone能继续提供“弱一致性”读（“读Zone”，“读库”）。这也是OceanBase提供读写分离的一种方案。

### 高可用

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9bc845c281c048259d2398c4985cf67b~tplv-k3u1fbpfcp-zoom-1.image)

表中的数据存在不同的region下zone下的分区中

为了数据安全和提供高可用的数据服务，每个分区数据在物理上存储多份，每一份叫做分区的一个副本。每个副本，包括存储在磁盘上的静态数据（SSTable）、存储在内存的增量数据（MemTable）、以及记录事务的日志三类主要的数据。

### ACID实现

#### 原子性(Atomicity)

在OceanBase，同一个事务操作的多个分区可能位于不同的ObServer，底层通过两阶段提交协议处理分布式事务。分为如下几种情况：

-   单分区事务。和传统的关系数据库一样，属于单机事务，不需要走两阶段提交协议。
-   单机多分区事务。需要走两阶段提交协议，且针对单机做了专门的优化。
-   多机多分区事务。需要走完整的两阶段提交协议。
-   标准的两阶段协议分为Prepare和Commit/Abort阶段两个阶段。对于多机多分区事务，需要等到Commit/Abort执行完成后才能应答客户端事务的最终结果；对于单机多分区事务，只需要等到Prepare执行完成后即可应答客户端事务的最终结果，从而降低单机多分区事务的延时。
-   OceanBase采用多版本并发技术（MVCC）实现并发控制，读事务和写事务之间互不影响。如果读请求只涉及一个分区或者单台ObServer的多个分区，那么，只需要读取该ObServer上某个时间点的快照即可；如果读请求涉及到多台ObServer的多个分区，那么，需要执行分布式快照读。

#### 一致性(Consistency) & 持久性(Durability)

OceanBase的每个分区都维护了多个副本，一般为三个，且部署到多个不同的数据中心（Zone）。整个系统中有成千上万个分区，这些分区的多个副本之间通过Paxos协议进行日志同步。每个分区和它的副本构成一个独立的Paxos复制组（Paxos Replication Group），其中一个副本为主（Leader），其它副本为备（Follower）。每台ObServer服务的一部分分区为Leader，一部分分区为Follower。当ObServer出现故障时，Follower分区不受影响，Leader分区的写服务短时间内会受到影响，直到通过Paxos协议将该分区的某个Follower选为新的Leader。

OceanBase复制协议分为两个部分：Paxos分布式选举以及日志同步。Paxos分布式选举确保每个分区总是能够选出唯一的Leader，由Leader将日志同步到Follower。只有日志同步到多数派并且写盘成功，才认为事务执行成功。假设总共有三个副本（N = 3），那么，需要确保Leader写盘成功以及其中某个Follower同步完成且写盘成功。如果某个Follower出现故障，Leader和剩余的一个Follower还能够构成多数派，系统继续提供服务。如果Leader出现故障，那么，Leader最后执行的少量事务可能没有同步到多数派，这些事务的状态不确定，称为未决事务，需要等到某个Follower接替为新的Leader后才能最终确定。Follower接替为Leader后的第一步操作就是明确前一任Leader产生的未决事务的状态，这个过程称为重新确认（Reconfirm）。等到Reconfirm过程全部完成后，新的Leader才开始正式提供服务，系统恢复正常。

当分区发生复制或者迁移时，该分区对应的Paxos复制组发生了成员变更，需要执行成员变更操作，成员变更操作也是一个投票。

#### 隔离性

全局时间戳

OceanBase基于数据多版本实现了一个多版本并发控制，事务提交时取本地的时间戳做为事务的版本号。同一台服务器上的多次修改总是能够保证取到一个递增的版本号，但是对于分布在不同服务器上的数据，由于服务器之间时钟有误差，无法保证集群内提交的事务版本号总是递增的。为了解决事务版本号的问题，OceanBase 内部为每个租户启动一个全局时间戳服务，事务提交时通过本租户的时间戳服务获取事务版本号，保证全局的事务顺序。

全局时间戳服务本身也是多副本的，当全局时间戳服务出现异常时，自动切换到其他副本，避免全局时间戳出现异常影响事务的提交。

租户可以通过以下2种方式来启用全局时间戳服务：

1.  创建租户时启用全局时间戳服务

CREATE TENANT tenant1 RESOURCE_POOL_LIST = ('my_pool') set ob_timestamp_service='GTS';

1.  通过系统变量启用全局时间戳服务

alter system set ob_timestamp_service='GTS'

### 分布式事务

在OceanBase，同一个事务操作的多个分区可能位于不同的ObServer，底层通过两阶段提交协议处理分布式事务。分为如下几种情况：

-   单分区事务。和传统的关系数据库一样，属于单机事务，不需要走两阶段提交协议。
-   单机多分区事务。需要走两阶段提交协议，且针对单机做了专门的优化。
-   多机多分区事务。需要走完整的两阶段提交协议。
-   标准的两阶段协议分为Prepare和Commit/Abort阶段两个阶段。对于多机多分区事务，需要等到Commit/Abort执行完成后才能应答客户端事务的最终结果；对于单机多分区事务，只需要等到Prepare执行完成后即可应答客户端事务的最终结果，从而降低单机多分区事务的延时。
-   OceanBase采用多版本并发技术（MVCC）实现并发控制，读事务和写事务之间互不影响。如果读请求只涉及一个分区或者单台ObServer的多个分区，那么，只需要读取该ObServer上某个时间点的快照即可；如果读请求涉及到多台ObServer的多个分区，那么，需要执行分布式快照读。

#### 2PC

##### 准备阶段

1.  协调者节点向所有参与者节点询问是否可以执行提交操作，并开始等待各参与者节点的响应。
1.  参与者节点执行询问发起为止的所有事务操作，并将Undo信息和Redo信息写入日志
1.  各参与者节点响应协调者节点发起的询问。如果参与者节点的事务操作实际执行成功，则它返回一个”同意”消息；如果参与者节点的事务操作实际执行失败，则它返回一个”中止”消息。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/36d20bbf21b74a0ca93068b38ff4d07f~tplv-k3u1fbpfcp-zoom-1.image)

##### 提交阶段

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0aa6b1df3bff4f5b93dcb57576924f02~tplv-k3u1fbpfcp-zoom-1.image)

1.  协调者节点向所有参与者节点发出”正式提交”的请求
1.  参与者节点正式完成操作，并释放在整个事务期间内占用的资源
1.  参与者节点向协调者节点发送”完成”消息
1.  协调者节点受到所有参与者节点反馈的”完成”消息后，完成事务

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e87da764132b4dba9eb701c22c4d2e64~tplv-k3u1fbpfcp-zoom-1.image)

1.  协调者节点向所有参与者节点发出”回滚操作”的请求
1.  参与者节点利用之前写入的Undo信息执行回滚，并释放在整个事务期间内占用的资源
1.  参与者节点向协调者节点发送”回滚完成”消息
1.  协调者节点受到所有参与者节点反馈的”回滚完成”消息后，取消事务（取消本次游戏活动）