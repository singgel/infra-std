<!--
 * @Author: your name
 * @Date: 2022-04-18 17:04:20
 * @LastEditTime: 2022-04-18 17:09:37
 * @LastEditors: Please set LastEditors
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 * @FilePath: /infra-std/BAT_TMDJ_webChat_abstract/2018_article_impression.md
-->
## 2018
[资料书籍](https://github.com/singgel/Study-Floder/tree/master/meituan-backend)  

### [SLA稳定性理解](https://tech.meituan.com/2018/04/19/trade-high-availability-in-action.html)

### netty堆外内存泄漏（netty-socketio）  
```
1. 一次 Connect 和 Disconnect 为一次连接的建立与关闭  
2. 在 Disconnect事件前后申请的内存并没有释放(DIRECT_MEMORY_COUNTER堆外统计字段)  
3. 断点打在client.send() 这行， 然后关闭客户端连接，之后直接进入到这个方法，有个逻辑 encoder.allocateBuffer申请堆外内存  
4. handleWebsocket ：调用 encoder 分配了一段内存，调用完之后，我们的控制台立马就彪了 256B（怀疑肯定是这里申请的内存没有释放）  
5. encoder.encodePacket() 方法，把 packet 里面一个字段的值转换为一个 char（这里报NPE）  
6. 跟踪到NPE之前的代码，看看为啥没有赋值进来，给附上值 *解决*  
```
### 不可不说的Java“锁”事  
```
1. 乐观锁 VS 悲观锁(synchronized关键字和Lock的实现类都是悲观锁)  
2. 自旋锁 VS 适应性自旋锁(自旋锁的实现原理同样也是CAS，AtomicInteger中调用unsafe进行自增操作的源码中的do-while循环就是一个自旋操作)  
3. 无锁 VS 偏向锁 VS 轻量级锁 VS 重量级锁(Mark Word：默认存储对象的HashCode，分代年龄和锁标志位信息)  
4. 公平锁 VS 非公平锁(AQS AbstractQueuedSynchronizer,hasQueuedPredecessors()）  
5. 可重入锁 VS 非可重入锁(ReentrantLock和synchronized都是可重入锁，NonReentrantLock)  
6. 独享锁 VS 共享锁(JDK中的synchronized和JUC中Lock的实现类就是互斥锁。ReentrantReadWriteLock有两把锁：ReadLock和WriteLock，StampedLock 提供了一种乐观读锁的实现)  
```
