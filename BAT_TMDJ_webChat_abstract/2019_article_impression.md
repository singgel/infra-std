## 2019
[资料书籍](https://github.com/singgel/Study-Floder/tree/master/meituan-backend)  

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