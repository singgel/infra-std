## 2020阿里
### 如何正确地实现重试(Retry)
```
固定循环次数方式: 不带 backoff 的重试，对于下游来说会在失败发生时进一步遇到更多的请求压力，继而进一步恶化。
带固定 delay 的方式: 
虽然这次带了固定间隔的 backoff，但是每次重试的间隔固定，此时对于下游资源的冲击将会变成间歇性的脉冲；
特别是当集群都遇到类似的问题时，步调一致的脉冲，将会最终对资源造成很大的冲击，并陷入失败的循环中。
带随机 delay 的方式: 
如果依赖的底层服务持续地失败，改方法依然会进行固定次数的尝试，并不能起到很好的保护作用。
对结果是否符合预期，是否需要进行重试依赖于异常。
无法针对异常进行精细化的控制，如只针部分异常进行重试。
可进行细粒度控制的重试:
推荐使用 resilience4j-retr y 或则spring-retry 等库来进行组合

和断路器结合
虽然可以比较好的控制重试策略，但是对于下游资源持续性的失败，依然没有很好的解决。当持续的失败时，对下游也会造成持续性的压力。
常见的有 Hystrix 或 resilience4
```
### 阿里技术专家详解 DDD 系列
#### DDD Domain Primitive
```
Domain Primitive 是一个在特定领域里，拥有精准定义的、可自我验证的、拥有行为的 Value Object
DP 的第一个原则：将隐性的概念显性化  
eg: PhoneNumber 类的一个计算属性 getAreaCode

DP 的第二、三个原则：将隐性的上下文显性化、封装多对象行为
eg: 通过将默认货币这个隐性的上下文概念显性化，并且和金额合并为 Money ，我们可以避免很多当前看不出来，但未来可能会暴雷的 bug
eg: ExchangeRate 汇率对象，通过封装金额计算逻辑以及各种校验逻辑，让原始代码变得极其简单

让隐性的概念显性化
让隐性的上下文显性化
封装多对象行为

常见的 DP 的使用场景包括:
有格式限制的 String：比如 Name，PhoneNumber，OrderNumber，ZipCode，Address 等。
有限制的 Integer：比如 OrderId（>0），Percentage（0-100%），Quantity（>=0）等。
可枚举的 int ：比如 Status（一般不用 Enum 因为反序列化问题）。
Double 或 BigDecimal：一般用到的 Double 或 BigDecimal 都是有业务含义的，比如 Temperature、Money、Amount、ExchangeRate、Rating 等。
复杂的数据结构：比如 Map<String, List<Integer>> 等，尽量能把 Map 的所有操作包装掉，仅暴露必要行为。

所有抽离出来的方法要做到无状态, DP 本身不能带状态，所以一切需要改变状态的代码都不属于 DP 的范畴。
```
#### DDD 应用架构
```
可维护性 = 当依赖变化时，有多少代码需要随之改变
eg：
    数据结构的不稳定性
    依赖库的升级
    第三方服务依赖的不确定性
    第三方服务 API 的接口变化
    中间件更换
可扩展性 = 做新需求或改逻辑时，需要新增/修改多少代码
eg：
    数据来源被固定、数据格式不兼容
    业务逻辑无法复用
    逻辑和数据存储的相互依赖
可测试性 = 运行每个测试用例所花费的时间 * 每个需求所需要增加的测试用例数量
eg：
    设施搭建困难
    运行耗时长
    耦合度高

单一性原则（Single Responsibility Principle）：
依赖反转原则（Dependency Inversion Principle）：
开放封闭原则（Open Closed Principle）：

*重构方案*
抽象数据存储层
Data Object 数据类：，从数据库来的都应该先直接映射到 DO 上，但是代码里应该完全避免直接操作 DO。
Entity 实体类：Domain Primitive 代替，可以避免大量的校验代码等。
Repository 对应的是 Entity 对象读取储存的抽象，在接口层面做统一，不关注底层实现。通过 Builder/Factory 对象实现 AccountDO 到 Account 之间的转化。

抽象第三方服务
Anti-Corruption Layer（防腐层或 ACL）
很多时候我们的系统会去依赖其他的系统，而被依赖的系统可能包含不合理的数据结构、API、协议或技术实现，如果对外部系统强依赖，会导致我们的系统被”腐蚀“。
ACL 不仅仅只是多了一层调用：通过在系统间加入一个防腐层，能够有效的隔离外部依赖和内部逻辑，无论外部如何变更，内部代码可以尽可能的保持不变。
适配器：
缓存：
兜底：
易于测试：
功能开关：

抽象中间件（简单就是KafkaTemplate别直接用）
用 Domain Primitive 封装跟实体无关的无状态计算逻辑
用 Entity 封装单对象的有状态的行为，包括业务校验
用 Domain Service 封装多对象逻辑

*DDD 的六边形架构*
又被称之为 Ports and Adapters（端口和适配器架构）
UI 层、DB 层、和各种中间件层实际上是没有本质上区别的，都只是数据的输入和输出，而不是在传统架构中的最上层和最下层。
```
#### DDD Repository 模式
```
Anemic Domain Model（贫血领域模型）
而 2006 年的 JPA 标准，通过@Entity 等注解，以及 Hibernate 等 ORM 框架的实现，
让很多 Java 开发对 Entity 的理解停留在了数据映射层面，忽略了 Entity 实体的本身行为
eg:
  1. 有大量的 XxxDO 对象
  2. 服务和 Controller 里有大量的业务逻辑
  3. 大量的 Utils 工具类等。
Repository 的价值
  能够隔离我们的软件（业务逻辑）和固件/硬件（DAO、DB），
  让我们的软件变得更加健壮，而这个就是 Repository 的核心价值。
手写 Assembler/Converter 是一件耗时且容易出 bug 的事情
  MapStruct

```
#### DDD 领域层设计规范
```
OOP （Object-Oriented Programming）面对对象程序设计实现
  一个比较简单的实现是通过类的继承关系
  对象继承导致代码强依赖父类逻辑，违反开闭原则 Open-Closed Principle（OCP）最核心的原因就是一个现有逻辑的变更可能会影响一些原有的代码
目前领域事件的缺陷和展望
    和消息队列中间件不同的是，领域事件通常是立即执行的、在同一个进程内、可能是同步或异步。
    但会侵入实体本身，同时也需要比较啰嗦的显性在调用方dispatch 事件，也不是一个好的解决方案。
```
