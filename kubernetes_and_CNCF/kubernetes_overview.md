**Kubernetes** 源于希腊语，意为 “舵手” 或 “飞行员”。Google 在 2014 年开源了 Kubernetes 项目。Kubernetes 建立在 [Borg](https://research.google/pubs/pub43438/) 的基础上，结合了社区中最好的想法和实践。

Borg解决3大问题

1.  隐藏资源管理和错误处理的细节，让业务同学专注于开发应用
1.  高运维可靠性和可用性
1.  在海量机器上部署应用

## 架构图

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bce7bb2304b54dc085b30db1676f1c8d~tplv-k3u1fbpfcp-zoom-1.image)

## **名词**

-   ### [Node](https://kubernetes.io/docs/concepts/architecture/nodes/)

Pod运行所在的工作主机，包含容器运行时(docker)，kubelet 和 kube proxy。

-   Kubelet

    -   通过 API Server 接收到所需要 Pod 运行的状态，去完成Node内对Pod的管理。

-   Kube proxy

    -   监听 API server 中 service 和 endpoint 的变化情况，并通过 iptables 等来为服务配置负载均衡（仅支持 TCP 和 UDP）。

-   #### Pause Pod

作为Pod的根容器，它的存活状态代表容器组的状态，业务容器共享根容器的Volumn。

-   #### [Pod](https://kubernetes.io/zh/docs/concepts/workloads/pods/pod-overview/)

部署、水平扩展和制作副本的最小单元。一个Pod只能在一个Node上，Pod内的所有容器共享存 储和网络。

-   ##### [Container](https://kubernetes.io/docs/concepts/containers/overview/) 容器

同Docker容器相同含义，应用程序一次打包，多处部署。

-   ### Master / Control Plane 控制面

    -   #### [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) 调度器

        -   Scheduler 会实时监测 Kubernetes 集群中未分发和已分发的所有运行的 Pod。
        -   Scheduler 会实时监测 Node 节点信息，由于会频繁查找 Node 节点，Scheduler 同时会缓存一份最新的信息在本地。
        -   Scheduler 在分发 Pod 到指定的 Node 节点后，会把 Pod 相关的信息 Binding 写回 API Server，以方便其它组件使用。

    -   #### [API Server](https://kubernetes.io/zh/docs/concepts/architecture/master-node-communication/)

        -   提供HTTP Rest 接口的服务进程，是集群控制的入口进程。

    -   #### Controller 控制器

        -   [Replication Controller](https://kubernetes.io/zh/docs/concepts/workloads/controllers/replicationcontroller/) / [ReplicaSet](https://kubernetes.io/zh/docs/concepts/workloads/controllers/replicaset/)

            -   Input: Pod期待副本数N，Label 选择器，Pod创建模板。
            -   Perform: 定期检查并调整当前存活的Pod数为N。
            -   可实现TCE/水平扩缩容

        -   [Deployment](https://kubernetes.io/zh/docs/concepts/workloads/controllers/deployment/)

            -   底层会操作ReplicaSet完成升级、回滚。
            -   可实现TCE/创建服务、服务升级、服务回滚。

        -   [Job](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/)

            -   一次性任务，可部署到多个Pod上。

        -   [Cron Job](https://kubernetes.io/zh/docs/concepts/workloads/controllers/cron-jobs/)

            -   定时任务，周期执行Job。

        -   [DaemonSet](https://kubernetes.io/zh/docs/concepts/workloads/controllers/daemonset/)

            -   指定标签的Node上各部署一个Pod的副本，如监控、日志收集等Agent。

        -   [Horizontal Pod AutoScaler](https://kubernetes.io/zh/docs/tasks/run-application/horizontal-pod-autoscale/)

            -   根据CPU或自定义指标动态Pod扩缩容。
            -   可实现TCE/自动扩容

-   ### [Namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

    -   Kubernetes支持在相同物理集群上创建多个虚拟集群，这些虚拟集群称为Namespace。

-   ### [Label](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/labels/) 标签

    -   键值对，用来和对象绑定，使用标签来区分同一Namespace内的资源。

-   ### [Service](https://kubernetes.io/zh/docs/concepts/services-networking/service/#%E5%AE%9A%E4%B9%89-service)

    -   指定标签的Pod作为服务后端，获得一个虚拟的Cluster IP和端口，并创建同名Endpoints对象。

    -   #### [服务发现](https://kubernetes.io/zh/docs/concepts/services-networking/service/#%E6%9C%8D%E5%8A%A1%E5%8F%91%E7%8E%B0)

        -   [环境变量](https://kubernetes.io/zh/docs/concepts/services-networking/service/#环境变量)：后启动的Pod，环境变量会包含之前创建的服务的cluster ip:port。
        -   [DNS](https://kubernetes.io/zh/docs/concepts/services-networking/dns-pod-service/)：不受Pod启动先后的影响，随时可以获取到新老服务的cluster ip:port。

-   ### [Volumes](https://kubernetes.io/zh/docs/concepts/storage/volumes/)

    -   用来声明在 Pod 中的容器可以访问文件目录。
    -   生命周期和Pod相同，Container重启数据仍保留。