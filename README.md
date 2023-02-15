<!--
 * @Author: your name
 * @Date: 2022-04-13 11:30:35
 * @LastEditTime: 2023-02-15 02:53:20
 * @LastEditors: 阿拉斯加大闸蟹 hekuangsheng@163.com
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE 
 * @FilePath: /infra-std/README.md
-->
# 基础架构
本仓库更多是关于团队层面的视角，把控技术演进（为什么要做这件事）和流程规范（做事的边界和风险），不涉及单项深度，单项[查看github下的其他仓库](https://github.com/singgel?tab=repositories)  

### 法务合规
[常见开源协议和使用范围](./DEV_license_risk/license_desc.md)  

### 编码规范
[Google编码规范涵盖所有语言](https://google.github.io/styleguide/)  
[C语言编码规范](./code_style_define/C_coding_style.md)  
[C++语言编码规范](./code_style_define/C%2B%2B_coding_style.md)  
[go语言编码规范](./code_style_define/golang_coding_style.md)  
[java语言编码规范](https://edu.aliyun.com/certification/cldt02?spm=a2c6h.12873639.article-detail.6.357737bfB6n6Nl)  

### IDE的一些开发工具
[zsh+omz的安装和配置](./IDE_DEV_tool/zsh_omz_install.md)  
[zshrc个人习惯的推荐配置](./IDE_DEV_tool/zshrc_conf.md)  
[linux下常用排查磁盘网络性能问题](./IDE_DEV_tool/linux_OPS_command.md)  

### git流程规范
[git使用说明](./GIT_flow_norm/GIT_useage.md)  
[git code review怎么做](./GIT_flow_norm/GIT_code_review.md)  
[上线流程和checklist](./GIT_flow_norm/RD_deploy_checklist.md)  

### IDL描述文件规范和管理
[IDL文档管理规范标准](./IDL_define_std/IDL_std.md)  
[protobuf IDL文档管理规范标准](./IDL_define_std/IDL_protobuf_std.md)  
[thrift IDL文档管理规范标准](./IDL_define_std/IDL_thrift_std.md)  

### 中间件原理与使用规范
[MySQL的主从数据同步](./middleware_architecture/mysql_data_replicate.md)  
[OceanBase的基础使用与讲解](./middleware_architecture/OceanBase_desc.md)  
[Redis开发人员使用规范](./middleware_architecture/Redis_use_style.md)  

### RPC通信框架设计和规范
[互联网常见的几种RPC框架讲解比对](./RPC_infra_desc/RPC_infra_compare.md)  
[RPC最基础版纯Java源码实现](https://github.com/singgel/RPC-SkillTree)  
[gRPC框架JAVA版本](https://github.com/singgel/grpc-infra)  

### 服务治理
[服务治理要做哪些事情](./SOA_governance/SOA_governance_view.md)  
[阿里-微服务治理技术白皮书](./SOA_governance/微服务治理技术白皮书.pdf)  

### service mesh/服务网格
[服务网格的发展历史](./service_mesh/service_mesh_history.md)  
[为什么使用服务网格](./service_mesh/service_mesh_why.md)  

### Kubernetes&云原生
[Kubernetes概览和简单介绍](./Kubernetes_and_CNCF/Kubernetes_overview.md)  
[基于Jenkins的k8s CICD部署](https://github.com/singgel/sharelibrary)  
[k8s经验与错误排查](https://github.com/singgel/Kubernetes-operation-case)  

### serverless&函数计算
[什么是serverless，要做哪些事](./server_less/serviceless_desc.md)  
[理解serverless](./server_less/server_less_got.md)  

### openstack&云计算  
[VPC虚拟网络](./OpenStack_IaaS/VPC_desc.md)  

### 网络架构
[CDN网络架构](./NET_architecture/CDN_net_desc.md)  
[DNS和HTTP—DNS](./NET_architecture/DNS_HTTPDNS_desc.md)  
[应用网络时延UE](./NET_architecture/NET_UE_latency.md)  

### 多活容灾架构
[网关改造](https://blog.csdn.net/singgel/article/details/122701839)  
[流量调度](https://wbuntu.com/deploy-a-doh-service/)  
[服务单元化]()  

---
# 尚未归类

### 一个相同方向上的前辈
[李亮亮的技术文章摘抄](https://learn.lianglianglee.com/)  

### 源码剖析  
#### 编译语言
[如何阅读源码](./opensource_code_reading_after/how_to_join_opensource.md)  
[Java源码阅读](./opensource_code_reading_after/java_source_impression.md)  
[Java知识体系](https://github.com/singgel/java)  
[GoLang源码阅读](./opensource_code_reading_after/golang_source_impression.md)  
[Go知识体系](https://github.com/singgel/golang)  
#### 中间件源码debug
[Redis源码阅读与调试](./opensource_code_reading_after/redis_code_debug_impression.md)  
[k8s源码阅读与调试](./opensource_code_reading_after/k8s_code_debug_impression.md)  

### BAT_TMDJ技术类文章资料读后笔记
[2018年各大厂技术合集](./BAT_TMDJ_webChat_abstract/2018_article_impression.md)  
[2019年各大厂技术合集](./BAT_TMDJ_webChat_abstract/2019_article_impression.md)  
[2020年各大厂技术合集](./BAT_TMDJ_webChat_abstract/2020_article_impression.md)  
[2021年各大厂技术合集](./BAT_TMDJ_webChat_abstract/2021_article_impression.md)  
[2022年各大厂技术合集](./BAT_TMDJ_webChat_abstract/2022_article_impression.md)  

### 多活案例
[作业帮多云架构设计与实践](https://mp.weixin.qq.com/s/5grTPT-ICkJy7He2fGOkWw)  