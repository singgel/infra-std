# meituan-backend-pdf_abstract
## [JVM源码](http://hg.openjdk.java.net/jdk8u)

## 2018
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

## 2019
### Java Unsafe 
```
1. 提升程序 I/O 操作的性能。通常在 I/O 通信过程中，会存在堆内内存到堆外内存的数据拷贝操作，对于需要频繁进行内存间数据拷贝且生命周期较短的暂存数据，都建议存储到堆外内存。  
2. 创 建 DirectByteBuffer 的时候， 通过Unsafe.allocateMemory 分配内存、Unsafe.setMemory 进行内存初始化，而后构建 Cleaner 对象用于跟踪 DirectByteBuffer 对象的垃圾回收，以实现当 DirectByteBuffer 被垃圾回收时，分配的堆外内存一起被释放。（Cleaner 继承自 Java 四大引用类型之一的虚引用 PhantomReference（众所周知，无法通过虚引用获取与之关联的对象实例，且当对象仅被虚引用引用时，在任何发生 GC 的时候，其均可被回收），）  
3. 这部分，包括线程挂起、恢复、锁机制等方法。  
4. allocateInstance 在 java.lang.invoke、Objenesis（提供绕过类构造器的对象生成方式）、Gson（反序列化时用到）中都有相应的应用。  
5. 在 Java 8 中引入，用于定义内存屏障（也称内存栅栏，内存栅障，屏障指令等，是一类同步屏障指令，是 CPU 或编译器在对内存随机访问的操作中的一个同步点，使得此点之前的所有读写操作都执行后才可  
```
### Java动态追踪技术 
```
1. java.lang.instrument.Instrumentation替换已经存在的 class 文件，运行时直接替换类很不安全。比如新的 class 文件引用了一个不存在的类，或者把某个类的一个 field 给删除了等等  
2. 因为有 BTrace 的存在，我们不必自己写一套ASM这样的工具了，BTrace 最终借 Instruments 实现 class 的替换  
```
### 字节码增强技术探索
```
1. 如果每次查看反编译后的字节码都使用 javap 命令的话，好非常繁琐。这里推荐一个 Idea 插件：jclasslib。  
2. 利用 Javassist 实现字节码增强时，可以无须关注字节码刻板的结构，其优点就在于编程简单。  
3. Attach API 的作用是提供 JVM 进程间通信的能力，比如说我们为了让另外一个 JVM 进程把线上服务的线程 Dump 出来，会运行 jstack 或 jmap 的进程，并传递 pid 的参数，告诉它要对哪个进程进行线程 Dump，这就是 Attach API 做的事情  
4. 热部署：不部署服务而对线上服务做修改，可以做打点、增加日志等操作，Mock：测试时候对某些服务做 Mock，性能诊断工具
```
### JVM Profiler技术原理和源码探索
```
1. Instrumentation 方式对几乎所有方法添加了额外的 AOP 逻辑，这会导致对线上服务造成巨额的性能影响，但其优势是：绝对精准的方法调用次数、调用时间统计。  
2. Sampling 方式基于无侵入的额外线程对所有线程的调用栈快照进行固定频率抽样，相对前者来说它的性能开销很低。（典型开源实现有 Async-Profiler 和 Honest-Profiler）  
3. FlameGraph 项目的核心只是一个 Perl 脚本  
```
### Java动态调试技术原理
```
1. Java-debug-tool 的同类产品主要是 greys，其他类似的工具大部分都是基于greys 进行的二次开发，所以直接选择 greys 来和 Java-debug-tool 进行对比。  
```
### 从ReentrantLOck的实现看AQS
```
1. 某个线程获取锁失败的后续流程是什么呢？存在某种排队等候机制，线程继续等待，仍然保留获取锁的可能，获取锁流程仍在继续。  
2. 如果处于排队等候机制中的线程一直无法获取锁，需要一直等待么？：线程所在节点的状态会变成取消状态，取消状态的节点会从队列中释放  
```
### springboot堆外内存排查
```
1. Native Code 所引起，而 Java 层面的工具不便于排查此类问题，只能使用系统层面的工具gperftools去定位问题  
2. 使用命令“strace -f -e”brk,mmap,munmap”-p pid”追踪向 OS 申请内存请求  
3. 想着看看内存中的情况使用命令 gdp -pid pid 进入 GDB 之后，然后使用命令 dump memory mem.bin startAddress endAddressdump 内存
其中 startAddress 和 endAddress 可以从 /proc/pid/smaps 中查找。然后使用 strings mem.bin 查看 dump 的内容  
```

## 2020
### 线程池实现原理
```
1. RUNNING、SHUTDOWN、STOP、TIDYING、TERMINATED  
2. 不用线程池的框架：Disruptor、Actor、协程  
3. 动态化线程池设计：简化线程池配置、参数可动态修改、增加线程池监控
```
### 美团亿万级KV存储
```
1. Squirrel 官方提供的方案，任何一个节点从宕机到被标记为 FAIL 摘除，一般需要经过 30 秒。更新 ZooKeeper，通知客户端、添加新node  
2. 持久化机制，写请求会先写到 DB 里，然后写到内存Backlog，这跟官方是一样的。同时它会把请求发给异步线程，异步线程负责把变更刷到硬盘的 Backlog 里。当硬盘 Backlog 过多时，我们会主动在业务低峰期做一次RDB ，然后把 RDB 之前生成的 Backlog 删除  
3. 如果有热点，监控服务会把热点 Key 所在 Slot 上报到我们的迁移服务。迁移服务这时会把热点主从节点加入到这个集群中，然后把热点 Slot 迁移到这个热点主从上。因为热点主从上只有热点 Slot 的请求，所以热点 Key 的处理能力得到了大幅提升  
4. Cellar 跟阿里开源的 Tair 主要有两个架构上的不同。第一个是 OB，第二个是 ZooKeeper  
5. Cellar 快慢列队，Cellar 智能迁移，Cellar 强一致  
6. 如果这个 Key 是一个热点，那么它会在做集群内复制的同时，还会把这个数据复制有热点区域的节点，同时，存储节点在返回结果给客户端时，会告诉客户端，这个 Key 是热点，这时客户端内会缓存这个热点 Key。  
```
### Java常见的9种CMS GC问题分析和解决
```
1. 分代收集器：ParNew：一款多线程的收集器，采用复制算法，主要工作在 Young 区；CMS：以获取最短回收停顿时间为目标，采用“标记 - 清除”算法
2. 分区收集器：G1：一种服务器端的垃圾收集器，应用在多处理器和大容量内存环境中；ZGC：JDK11 中推出的一款低延迟垃圾回收器，适用于大内存低延迟服务的内存管理和回收；
3. 读懂 GC Cause: System.gc()：手动触发 GC 操作；CMS：CMS GC 在执行过程中的一些动作；Promotion Failure：Old 区没有足够的空间分配给 Young 区；Concurrent Mode Failure：CMS GC 运行期间Old 区预留的空间不足；GCLocker Initiated GC：如果线程执行在 JNI 临界区时，刚好需要进行GC
4. MetaSpace 区 OOM: 经常会出问题的几个点有 Orika的 classMap、JSON 的 ASMSerializer、Groovy 动态加载类  
5. 过早晋升：分配速率接近于晋升速率，对象晋升年龄较小。原因：Young/Eden 区过小，分配速率过大  
6. CMS Old GC 频繁：判 断 当前 Old 区使用率是否大于阈值，则触发 CMS GC，默认为 92%。  
7. 内存泄漏：Dump Diff 和 Leak Suspects 比较直观就
```
### 堆外内存泄漏排查
```
-XX:NativeMemoryTracking=detail JVM 参数后重启项目
jcmd 272662 VM.native_memory detail
如果 total 中的 committed 和 top 中的 RES 相差不大，则应为主动申请的堆外内存
未释放造成的，如果相差较大，则基本可以确定是 JNI 调用造成的

原因一：主动申请未释放: NIO 和 Netty 都会取 -XX:MaxDirectMemorySize 配置的值，来限制申请的堆外内存的大小
原因二：通过 JNI 调用的 Native Code 申请的内存未释放: 通过 Google perftools + Btrace 等工具，帮助我们分析
首先可以使用 NMT + jcmd 分析泄漏的堆外内存是哪里申请，确定原因后，使用不同的手段，进行原因定位。

JNI 引发的 GC 问题: 添加 -XX+PrintJNIGCStalls 参数，可以打印出发生 JNI 调用时的线程，
禁用偏向锁：偏向锁在只有一个线程使用到该锁的时候效率很高，但是在竞争激烈情况会升级成轻量级锁，此时就需要先消除偏向锁，这个过程是STW 的。
```
### ZGC（The Z Garbage Collector）是 JDK 11 中推出的一款低延迟垃圾回收器
```
CMS 新生代的 Young GC、G1 和 ZGC 都基于标记 - 复制算法
标记阶段停顿分析
初始标记阶段：初始标记阶段是指从 GC Roots 出发标记全部直接子节点的过程，该阶段是 STW 的 (就遍历一层，快)
并发标记阶段：并发标记阶段是指从 GC Roots 开始对堆中对象进行可达性分析，找出存活对象 （可达性分析，并发，慢）
再标记阶段：重新标记那些在并发标记阶段发生变化的对象。该阶段是 STW 的 （？？？）

清理阶段停顿分析
清理阶段清点出有存活对象的分区和没有存活对象的分区，该阶段不会清理垃圾对象，也不会执行存活对象的复制。该阶段是 STW 的
复制阶段停顿分析
的转移阶段需要分配新内存和复制对象的成员变量。转移阶段是STW 的，其中内存分配通常耗时非常短，但对象成员变量的复制耗时有可能较长 （这个就跟redis大key似的）
为什么转移阶段不能和标记阶段一样并发执行呢？
主要是 G1 未能解决转移过程中准确定位对象地址的问题。
G1 的 Young GC 和 CMS 的 Young GC，其标记 - 复制全过程 STW

ZGC 在标记、转移和重定位阶段几乎都是并发的，这是 ZGC 实现停顿时间小于 10ms 目标的最关键原因
ZGC 通过着色指针和读屏障技术，解决了转移过程中准确访问对象的问题，实现了并发转移。
ZGC 有多种 GC 触发机制
阻塞内存分配请求触发：当垃圾来不及回收，垃圾将堆占满时，会导致部分线程阻塞。
基于分配速率的自适应算法：最主要的 GC 触发方式
基于固定时间间隔：通过 ZCollectionInterval 控制，适合应对突增流量场景。
主动触发规则：类似于固定间隔规则，但时间间隔不固定，是 ZGC 自行算出来的时机
预热规则：服务刚启动时出现，一般不需要关注
外部触发：代码中显式调用 System.gc() 触发
元数据分配触发：元数据区不足时导致，一般不需要关注

升级JDK11
a. 一 些 类 被 删 除： 比 如“sun.misc.BASE64Encoder”， 找 到 替 换 类 java.util.Base64 即可。
b. 组件依赖版本不兼容 JDK 11 问题：找到对应依赖组件，搜索最新版本，一般都支持 JDK 11。
```
### mybatis构建实现
```
SqlSession：作为 MyBatis 工作的主要顶层 API，表示和数据库交互的会话，完成必要数据库增删改查功能
Executor：MyBatis 执行器，这是 MyBatis 调度的核心，负责 SQL 语句的生成和查询缓存的维护
BoundSql：表示动态生成的 SQL 语句以及相应的参数信息
StatementHandler： 封 装 了 JDBC Statement 操 作， 负 责 对 JDBCstatement 的操作，如设置参数、将 Statement 结果集转换成 List 集合等等
ParameterHandler：负责对用户传递的参数转换成 JDBC Statement 所需要的参数
TypeHandler：负责 Java 数据类型和 JDBC 数据类型之间的映射和转换
```
