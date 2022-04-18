<!--
 * @Author: your name
 * @Date: 2022-04-18 16:22:17
 * @LastEditTime: 2022-04-18 16:23:31
 * @LastEditors: your name
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 * @FilePath: /infra-std/middleware_architecture/mysql_data_replicate.md
-->
## 主从同步

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/130e45751afc4522be81ff504e4115f2~tplv-k3u1fbpfcp-zoom-1.image)

1.  `Master` 服务器将数据的改变记录二进制`Binlog`日志，当`Master`上的数据发生改变时，则将其改变写入二进制日志中；
1.  `Slave`服务器会在一定时间间隔内对`Master`二进制日志进行探测其是否发生改变，如果发生改变，则开始一个`I/OThread`请求`Master`二进制事件
1.  同时主节点为每个`I/O`线程启动一个`Dump`线程，用于向其发送二进制事件，并保存至从节点本地的中继日志中，从节点将启动SQL线程从中继日志中读取二进制日志，在本地重放，使得其数据和主节点的保持一致，最后`I/OThread`和`SQLThread`将进入睡眠状态，等待下一次被唤醒。

### 异步

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7e8c83ed810046d3bdbbb6bd1d8c8924~tplv-k3u1fbpfcp-zoom-1.image)

### 半同步

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95757acdf66b418dbb6c62252771407b~tplv-k3u1fbpfcp-zoom-1.image)

```
上图中当slave通过I/O thread写入relaylog后会有一个sql_thread读取relay log中的sql然后执行
```

### ```
在备库上通过change master命令,设置主库A的IP、端口、用户名、密码,以及要从哪个位置开始请求binlog,这个位置包含文件名和日志偏移量。  在备库上执行start slave命令,这时候备库会启动两个线程,就是图中的io_thread和sqlthread。其中io-thread负责与主库建立连接。  主库校验完用户名、密码后,开始按照备库传过来的位置,从本地读取binlog,发给备库  备库拿到binlog后,写到本地文件,称为中转日志(relay log)  sql-thread读取中转日志,解析出日志里的命令,并执行。  上图中当slave通过I/O thread写入relaylog后会有一个sql_thread读取relay log中的sql然后执行 
```主从延迟

1.  #### 一次DELETE过多数据

1.  #### 大事务

    1.  大事务这种情况很好理解。因为主库上必须等事务执行完成才会写入binlog,再传给备库。
    1.  所以,如果一个主库上的语句执行10分钟,那这个事务很可能就会导致从库延迟10分钟。

1.  #### 大表的DDL

### 数据一致性

1.  #### 强制走主库

    1.  对于必须要拿到最新结果的请求,强制将其发到主库上。比如,在一个交易平台上,卖家发布商品以后,马上要返回主页面,看商品是否发布成功。那么,这个请求需要拿到最新的结果,就必须走主库。
    1.  对于可以读到旧数据的请求,才将其发到从库上。在这个交易平台上,买家来逛商铺页面,就算晚几秒看到最新发布的商品,也是可以接受的。那么,这类请求就可以走从库。

1.  #### sleep方案

    1.  等一会再读

1.  #### 判断延迟方案

    1.  查询读库的延迟时间

1.  ##### 从库不读主库

    1.  如果从库不存在再读下主库，这种方案无法兼容数据删除&修改的场景

1.  ##### 增加缓存一致性