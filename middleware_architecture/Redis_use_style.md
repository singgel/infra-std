# 零、Redis不是什么

-   Redis 不是Big Data，数据都在内存中，无法以T为单位
-   Redis 不支持Ad-Hoc Query，提供的只是数据结构的API，没有SQL一样的查询能力
-   Redis 的水平扩展能力总是有限的，即使我们使用了很不错的集群模式，在必要时，仍然需要选择其他更合适的kv

# 一、键值设计

## 1. key名设计

-   ### (1)【建议】: 可读性和可管理性

以业务名(或数据库名)为前缀(防止key冲突)，用冒号分隔，比如业务名:表名:id

很多client都默认支持按照冒号做groupby，这也是redis实现分片的默认策略，对负载友好

-   ### ```
    ugc:video:1 
    ```(2)【建议】：简洁性

保证语义的前提下，控制key的长度，当key较多时，内存占用也不容忽视，例如：

-   ### ```
    user:{uid}:friends:messages:{mid}  简化为  u:{uid}:fr:m:{mid}。 
    ```(3)【强制】：不要包含特殊字符

理论上只应该包含，字母、数字、下划线与括号

反例：包含空格、换行、单双引号以及其他转义字符

## 2. value设计

-   ### (1)【强制】：拒绝bigkey(防止网卡流量、慢查询)

string类型控制在10KB以内，hash、list、set、zset元素个数不要超过5000。

（10K开始，出现明显的网络性能拐点）

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ace44c9cb5864170af4e72ccb1609760~tplv-k3u1fbpfcp-zoom-1.image)

反例：一个包含200万个元素的list。

~~*非字符串的bigkey，不要使用del删除，使用*~~~~*hscan、sscan、zscan*~~~~*方式渐进式删除，同时要注意防止bigkey过期时间自动删除问题(例如一个200万的zset设置1小时过期，会触发del操作，造成阻塞，而且该操作不会不出现在慢查询中(latency可查))*~~

目前公司redis不支持 xscan 系列的命令，替代方式是：

-   zset使用zremrangebyrank分批删除
-   list使用ltirm
-   hash&set使用脚本扫出来具体的key，通过hdel和srem删除

<!---->

-   ### (2)【推荐】：选择适合的数据类型。

例如：实体类型(要合理控制和使用数据结构内存编码优化配置,例如ziplist，但也要注意节省内存和性能之间的平衡)

反例：

```
set user:1:name tomset user:1:age 19set user:1:favor football
```

正例:

## ```
hmset user:1 name tom age 19 favor football 
```3.【推荐】控制key的生命周期，redis不是垃圾桶。

建议使用expire设置过期时间(条件允许可以打散过期时间，防止集中过期)，不过期的数据重点关注idletime。

# 二、命令使用

## 1.【推荐】 O(N)命令关注N的数量

例如hgetall、lrange、smembers、zrange、sinter等并非不能使用，但是需要明确N的值。有遍历的需求可以使用hscan、sscan、zscan代替。

我们以List类型为例，LINDEX、LREM等命令的时间复杂度就是O(n)。也就是说，随着List中元素数量越来越多，这些命令的性能越来越差。而Redis又是单线程的，如果出现一个慢命令，会导致在这个命令之后执行的命令耗时也会增长，这是使用Redis的大忌。

（事实上这也是JDK8为什么要对HashMap进行链条冲突优化：当entry数量不少于64时，如果冲突链表长度达到8，就会将其转成红黑树。因为链表长度越长，性能会越来越差。）

## 2.【推荐】禁用命令

禁止线上使用keys、flushall、flushdb等，通过redis的rename机制禁掉命令，或者使用scan的方式渐进式处理。目前公司redis已默认禁用。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5e950f856cd74d21aa4bc557a626bdf6~tplv-k3u1fbpfcp-zoom-1.image)

## 3.【推荐】合理使用select

redis的多数据库较弱，使用数字进行区分，很多客户端支持较差，同时多业务用多数据库实际还是单线程处理，会有干扰。

## 4.【推荐】使用批量操作提高效率

多数常规情况下，pipeline比mget的效率天然要好

-   主要原因：对代理层负载友好。

    -   mget在proxy层会做拆包解包，pipeline不需要 直接转发

但要注意控制一次批量操作的**元素个数**(例如500以内，实际也和元素字节数有关)。

注意两者不同：

## ```
1. 原生(mget/mset)是原子操作，pipeline是非原子操作。  2. pipeline可以打包不同的命令，原生做不到  3. pipeline需要客户端和服务端同时支持。 
```5.【建议】Redis事务功能较弱，不建议过多使用

Redis的事务功能较弱(不支持回滚)，而且集群版本(自研和官方)要求一次事务操作的key必须在一个slot上(可以使用hashtag功能解决)

## 6.【建议】Redis集群版本在使用Lua上有特殊要求：

-   所有key都应该由 KEYS 数组来传递，redis.call/pcall 里面调用的redis命令，key的位置，必须是KEYS array, 否则直接返回error，"-ERR bad lua script for redis cluster, all the keys that the script uses should be passed using the KEYS array"
-   所有key，必须在1个slot上，否则直接返回error, "-ERR eval/evalsha command keys must in same slot"
-   Script一旦执行则不容易中断，中断了也会有不可知后果，因此最好在开发环境充分测试了再上线

## 7.【建议】必要情况下使用monitor命令时，要注意不要长时间使用。

monitor可以显示Server收到的所有指令，主要用于debug，比较影响性能，遇到问题时酌情使用

# 三、客户端使用

## 1.【推荐】不混用实例

避免多个应用使用一个Redis实例

正例：不相干的业务拆分，公共数据做服务化。

## 2.【推荐】使用连接池

使用带有连接池的数据库，可以有效控制连接，同时提高效率

## 3.【建议】高并发熔断

高并发下建议客户端添加熔断功能（cloud上配置）

## 4. 建议】淘汰策略选择

根据自身业务类型，选好maxmemory-policy(最大内存淘汰策略)，设置好过期时间。

默认策略是volatile-lru，即超过最大内存后，在过期键中使用lru算法进行key的剔除，保证不过期数据不被删除，但是可能会出现OOM问题。

##### 其他策略如下：

-   allkeys-lru：根据LRU算法删除键，不管数据有没有设置超时属性，直到腾出足够空间为止。
-   allkeys-random：随机删除所有键，直到腾出足够空间为止。
-   volatile-random:随机删除过期键，直到腾出足够空间为止。
-   volatile-ttl：根据键值对象的ttl属性，删除最近将要过期数据。如果没有，回退到noeviction策略。
-   noeviction：不会剔除任何数据，拒绝所有写入操作并返回客户端错误信息"(error) OOM command not allowed when used memory"，此时Redis只响应读操作。