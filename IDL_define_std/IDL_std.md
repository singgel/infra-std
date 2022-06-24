# 背景

当前HTTP&RPC API缺乏管理，RPC服务端内部统一使用thrift+kite，但IDL比较散落；HTTP接口存在无文档、wiki/doc定义，thrift/pb定义等多种方式。

在HTTP API规范上，公司内有多个团队进行过此类尝试，遇到过以下问题：

1.  API定义与代码脱节，导致无法持续维护
2.  各团队IDL编写风格不一致

RPC API存在以下问题：

1.  IDL文件散落，不知道有哪些服务
1.  不清楚每个服务提供什么能力
1.  不知道每个API如何使用，需要额外沟通

我们希望后续将HTTP&RPC API统一到IDL文件上进行描述，并与研发流程打通，利用IDL进行代码生成、测试等，确保IDL与代码的一致性

1.  文档功能

    1.  Service功能描述，能够统一索引
    1.  API功能描述
    1.  请求/响应参数描述

1.  脚手架功能

    1.  HTTP服务，参数从哪里解析（querystring/header/cookie/body。。）
    1.  请求的序列化方式（RPC暂时都是thrift，http服务是form/json/pb/thrift。。）

-   其他的一些辅助能力，如参数约束描述/apigateway通用服务收敛

# IDL版本管理

1.  所有IDL在一个分支，线性开发
1.  小版本IDL允许不兼容，IDL发布时与前一个发布版本兼容检查
1.  客户端编译时检查api对应版本是否发布，确保服务端客户端IDL一致

# IDL类型

1.  服务端RPC描述，采用thrift IDL风格

1.  HTTP服务描述，由于当前thrift/pb都在使用，考虑同时支持

    1.  pb同时支持proto2&proto3

# IDL引用规范

1.  同仓库可以使用相对路径引用
1.  引用外部仓库需要需要使用完整路径（repo_namespace + filepath，其中repo_namespace 只支持两段式，例如 idl/i18n）进行引用

# IDL规则描述

## 文档描述能力

关注方：客户端、服务端RD

作用范围：RPC、HTTP

文档统一使用docstring语法，应简明清晰描述功能

//同样适用于thrift&pb

/** struct docstring */

struct EchoRequest {

/** param docstring */

1: string Message

}

/** service docstring */

service EchoService {

/** method doc string */

EchoResponse Echo(1: EchoRequest)

}

## 脚手架能力

作用范围：HTTP

脚手架相关的信息使用annotation语法进行描述

//thrift

struct Item{

1: optional i64 id （api.query="id")

}

//pb

message Item {

optional int64 id = 1 [(api.query)="id"];

}

pb的annotation具体见[接口管理Protobuf IDL定义规范（2.0）](https://github.com/singgel/space/doc/doccnXvLAWvnQwR8SbcHs6GIW5f#)

### HTTP序列化、反序列化相关

功能：指导脚手架模块如何将http协议与model进行对应

关注方：服务端RD、服务端脚手架、移动网关脚手架、apigateway

约束

1.  接口定义字段需要与请求字段匹配，业务方一般无需指定参数来源位置，按照以下方式获取。需要将字段放入cookie/header的场景，可以通过annotation指定。

    1.  GET请求参数来自querystring
    1.  POST请求参数来自body

1.  如果http请求是采用GET方式的，那么request定义中出现的api.body注解无效，只有api.query，api.path， api.cookie，api.header有效。

1.  如果http请求是采用POST方式且序列化方式是form的，那么request的字段不能有复杂结构，否则该字段无效。

1.  注解为api.query和api.header的字段复杂类型，只支持基本类型（string，i64…)和基础类型的list，list只支持逗号分隔的模式

struct BizRequest {

1: optional i64 v_int64(api.query = 'v_int64', api.vd = "$>0&&$<200")// 对应http query中的v_int64, 且值范围为(0,200)，其中api.query可以不填

2: optional string text(api.body = 'text')// annotation可以不填

3: optional i32 token(api.header = 'token')//对应http header中的token，annotation必须填写

}

| **注解**       | **说明**                                                                                      |
| ------------ | ------------------------------------------------------------------------------------------- |
| api.query    | api.query 对应http请求的url query参数                                                              |
| api.path     | api.path 对应http请求的url path参数                                                                |
| api.header   | api.header 对应http请求的header参数                                                                |
| api.cookie   | api.cookie 对应http的cookie参数                                                                  |
| api.body     | api.body 对应http的body一级key，只出现在请求一级Field                                                     |
| api.raw_body | api.raw_body http原始body，少数接口body加密了，可以拿到原始的body                                             |
| api.none     | 忽略此字段                                                                                       |
| api.js_conv  | 兼容js，int64输出为string                                                                         |
| api.vd       | 参数校验，使用了库https://github.com/bytedance/go-tagexpr/tree/master/validator，检验表达式语法参见包内readme文件 |

### 公共参数

关注方：服务端用户RD、服务端脚手架、apigateway

app级公参由各app自行定义


### HTTP接口映射

关注方：客户端RD、服务端RD，服务端脚手架、移动网关脚手架、apigateway

service BizService{

//例子1： get请求

BizResponse BizMethod1(1: biz.BizRequest req)(api.get = '/life/client/:action/:biz', api.serializer='json')

}

| **注解**         | **类型** | **说明**                                                                                          | **举例**                                                                                 |
| -------------- | ------ | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| api.get        | string | get请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter))    | /life/client/favorite/collect                                                          |
| api.post       | string | post请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter))   | /life/client/favorite/collect                                                          |
| api.put        | string | put请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter))    |                                                                                        |
| api.delete     | string | delete请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter)) |                                                                                        |
| api.serializer | string | 请求体序列化方式，由服务端定义                                                                                 | 如form, json, thrift, pb等                                                               |
| api.gen_path   | string | 客户端生成代码使用的path（get、post、put、delete定义的path是tlb配置使用的path）                                         | 如api.post='/v:version/modify'，version变量在更新idl时可以固化，比如说固化为3，那么api.gen_path='/v3/modify' |
| api.version    | string | 客户端生成代码是替换path中的:version变量,优先级低于api.gen_path                                                    | 如api.post='/v:version/modify'，api.version='7'，则生成代码中的path为'/v7/modify'。                |
| api.tag        | string | 客户端rpc增加标签，支持多个，逗号分隔（暂时只支持iOS）                                                                  | 例:api.tag="API,DATA"                                                                   |
| api.api_level  | string | 接口等级（字符串）                                                                                       | 例:api.api_level="0"(只能为"0", "1", "2")                                                  |
| api.category   | string | 接口类别，在文档展示界面，平台将为此接口创建名为对应值的文件夹并归纳                                                              | 例:api.category="业务接口类别"                                                                |

### 移动网关能力

关注方：移动网关脚手架

| **注解**      | **类型** | **说明**                                          | **举例**              |
| ----------- | ------ | ----------------------------------------------- | ------------------- |
| api.param   | string | 客户端请求是否需要带上公共参数                                 | true 或 false，默认true |
| api.baseurl | string | ttnet选路时使用的baseurl，由当前开发模式debug/release，appid决定 | 如ib.snssdk.com      |


## 其他能力

部分定制化能力在注释中体现

### 文档页标题

关注方：对平台文档页有定制化需求的研发

```
service BizService{

    // @title: 你好

    rpc ping(PingRequest) returns (MsgResponse) {

        option (api.get) = "/ping";

    }

}
```

接口文档页展示将会根据title内容设置标题

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2755b245a0f24acdb31faf58452316b9~tplv-k3u1fbpfcp-zoom-1.image)

## 扩展注解

实际执行时可能会遇到各种业务场景，我们引入扩展注解允许脚手架能快速解决特定问题。扩展注解有强烈的实验性质，不保证稳定性以及各脚手架实现的一致性，请业务方谨慎使用。

优秀的RPC协议：  
- 明确的消息边界
- 连接多路复用
- 请求路由