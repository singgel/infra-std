# 说明

（1）本规范定义了通过Thrift IDL描述HTTP接口的方式。规范上继承[Kite Thrift IDL规范](https://github.com/singgel/wiki/wikcnnT9PKsTyMWkh4tdTCozUMd)。

（2）本规范中定义的IDL注解如api.get, api.header 等，只支持小写，不支持大写或者大小写混用如api.GET, api.Header

# Thrift IDL

## 文件规范

一个psm对应一个thrift 主文件（包含service的文件），主文件里的method都是针对当前psm的对应接口的，主文件可以引用其它IDL文件定义

**最佳实践**：

每个Method原则上对应一个Request和Response定义

原则上不建议Request复用，可以复用Response

## Request

### 约束

1.  最上层的接口每个字段需要使用注解关联到http的某类参数的指定key。如果无注解，get关联query，post关联body，key为对应字段名
1.  如果http请求是采用GET方式的，那么request定义中出现的api.body注解无效，只有api.query, api.path, api.cookie有效。
1.  如果http请求是采用POST方式且序列化方式是form的，那么request的字段不能有复杂结构，否则该字段无效。
1.  注解为api.query和api.header的字段只支持基本类型（string，i64…)和基础类型的list，list只支持逗号分隔的模式
1.  注解为api.path只支持基本类型（string，i64…)

### 举例

```
struct Item{

    1: optional i64 id(go.tag = "json:"id"") //对于嵌套结构体，如果要设置序列化key,使用gotag 如 `json:"id"`

    2: optional string text

}

### **注解说明**

| **注解**     | **说明**                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| api.query    | api.query 对应http请求的url query参数                                                                                                                                                                                                                                                                                                                                                                        |
| api.path     | api.path 对应http请求的url path参数                                                                                                                                                                                                                                                                                                                                                                          |
| api.header   | api.header 对应http请求的header参数                                                                                                                                                                                                                                                                                                                                                                          |
| api.cookie   | api.cookie 对应http的cookie参数                                                                                                                                                                                                                                                                                                                                                                              |
| api.body     | api.body 对应http的body参数                                                                                                                                                                                                                                                                                                                                                                                  |
| api.raw_body | api.raw_body http原始body，少数接口body加密了，可以拿到原始的body                                                                                                                                                                                                                                                                                                                                            |
| api.vd       | 参数校验，使用了https://github.com/bytedance/go-tagexpr/tree/master/validator库，检验表达式语法参见包内readme文件                                                                                                                                                                                                                                                                                            |
| go.tag       | 用于后端go 对于字段名称和类型进行重定义比如：i64 ID(go.tag = "json:\"id, string\"") BAM go model 脚手架会生成 ID int64 (`json:id, string'), 目前 go.tag value支持 字段名称，类型，omitempty 三种，其它写法不支持注意与注解api.js_conv 同时使用的的兼容情况， api.js_conv 也会使生成json tag包含string，目前BAM go model 脚手架已经兼容支持二者同时指定string tag，如果同时使用但是类型不一致，会造成线上风险 |

                  |                                              |

### TTNet公共参数

TTNet通用参数thrift定义


所有的请求可选择携带TTNet公共参数，具体参数说明可参考[TTNET公参梳理]

无法复制加载中的内容

### 业务公参

部分业务会在HTTP请求的query string中增加业务自己的公共参数，如L项目会在query string中的api_version字段。业务公参中的字段只能使用api.query和api.header注解。

业务公参例子：

```
struct BizCommonParam {

    1: optional i64 api_version (api.query = 'api_version')

}
```

## Response

### 约束

header不支持除逗号相隔并且value为基本类型的list以外的复杂类型

直接按照业务自己定义的reponse。默认json序列化到body，key为字段名，注解可为空

###

api.query举例

```
 // 最终将把BizResponse json序列化之后作为给客户端的返包

struct RspItem{

 1: optional i64 item_id // 默认被以字段名作key序列化， 等价于 使用gotag `json:"item_id"`

 2: optioanl string text

    3: optional i64 tag_id (api.js_conv='true')

 }

struct BizResponse {

 1: optional string T                             (api.header= 'T')

 // 该字段将填入给客户端返回的header中

 2: optional map<i64, RspItem> rsp_items           (api.body='rsp_items')

 //一级key = 'rsp_items'

 3: optional i32 v_enum                       (api.none = '')//忽略当前参数

 4: optional list<RspItem> rsp_item_list            (api.body = 'rsp_item_list')

  5: optional i32 http_code                         (api.http_code = '')

 // 业务自己指定了HttpCode,  如果没有指定, baseResp.StatuCode=0 -> HttpCode=200,  其他 HttpCode=500 

 6: optional list<i64> item_count (api.header = 'item_count') //当设置header时以逗号相隔的列表

  255: optional base.BaseResp BaseResp,

 }
```

### **注解说明**

| 注解          | 说明                                                                                                                                                  |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| api.header    | api.header 设置http 回复中的header                                                                                                                    |
| api.http_code | api.http_code 设置http 回复中的status code，200/500等                                                                                                 |
| api.body      | api.body 设置http 回复中的body                                                                                                                        |
| api.none      | 忽略                                                                                                                                                  |
| api.js_conv   | 兼容js int64问题，将int64表示为string，使用该注解后 BAM go model 脚手架会对字段添加json string tag， 而BAM 的typescript 脚手架会对前端生成string 类型 |

## Method

### **约束**

如果是GET请求，api.serializer定义的序列化方式是无效的。

每个URI对应IDL的一个method，通过注解关联，注解不可为空

### 举例

```
service BizService{

//例子1： get请求

//api.category可以指定BAM 接口文档里边的分类目录

BizResponse BizMethod1(1: biz.BizRequest req)(api.get = '/life/client/:action/:biz', api.baseurl = 'ib.snssdk.com', api.param = 'true',

api.category = `demo`

)

//例子2:   post请求，form序列化

BizResponse BizMethod2(1: biz.BizRequest req)(api.post = '/life/client/:action/:biz', api.baseurl = 'ib.snssdk.com', api.param = 'true', api.serializer = 'form')

//例子3:   post请求，json序列化

BizResponse BizMethod3(1: biz.BizRequest req)(api.post = '/life/client/:action/:biz', api.baseurl = 'ib.snssdk.com', api.param = 'true', api.serializer = 'json')

}
```

### **注解说明**

| **注解**       | **类型** | **说明**                                                                                                      | **举例**                                                                                                     |
| -------------- | -------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| api.get        | string   | get请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter))    | /life/client/favorite/collect                                                                                |
| api.post       | string   | post请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter))   | /life/client/favorite/collect                                                                                |
| api.put        | string   | put请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter))    |                                                                                                              |
| api.delete     | string   | delete请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter)) |                                                                                                              |
| api.patch      | string   | patch 请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter)) |                                                                                                              |
| api.serializer | string   | 客户端请求体序列化方式                                                                                        | 如form, json, thrift, pb等                                                                                   |
| api.param      | string   | 客户端请求是否需要带上公共参数                                                                                | true 或 false                                                                                                |
| api.baseurl    | string   | ttnet选路时使用的baseurl                                                                                      | 如ib.snssdk.com                                                                                              |
| api.gen_path   | string   | 客户端生成代码使用的path（get、post、put、delete定义的path是tlb配置使用的path）                               | 如api.post='/v:version/modify'，version变量在更新idl时可以固化，比如说固化为3，那么api.gen_path='/v3/modify' |
| api.version    | string   | 客户端生成代码是替换path中的:version变量,优先级低于api.gen_path                                               | 如api.post='/v:version/modify'，api.version='7'，则生成代码中的path为'/v7/modify'。                          |
| api.tag        | string   | 客户端rpc增加标签，支持多个，逗号分隔（暂时只支持iOS）                                                        | 例:api.tag="API,DATA"                                                                                        |
| api.category   | string   | 接口分类，根据该分类自动生成到doc文档的目录里                                                                 | 只能写一个，不支持多个目录                                                                                   |

## 多service定义（**RPC** **服务专用**）

多service的使用方式与kitex中多service的使用方式类似[多Service 的使用](https://github.com/singgel/wiki/wikcnelOXKu5htX9y3iU3f3VEOe)

> 目前BAM平台支持多service的场景只有idl导入生成doc文档

### **约束（restrict）**

通常情况下我们建议在同一 service 定义该服务相关接口和参数信息，如果业务需要在多个 service 中进行描述，我们支持按照如下方式使用

Usually we suggest defining all the corresponding methods in the same service definition for our service, if Muti-Service definitions are required. The following usages are supported

（1）如果需要跨文件引用service，可以在新的idl文件中extends需要的service

If we need to refer to services in other IDL files, we can refer them needed by the 'extends' method

（2）可以在 IDL 主文件中定义多个service, 我们将会把这些 service combine 为一个整体 service 作为该服务的service

The IDL main file contains more than one service . We will combine them into one which is used as the definition of our service

**注意 （Notice）：**

多service实际上是将所有 service 中的 method 进行聚合，所以在涉及到的所有service中，method 的命名不能冲突。

Since muti-service methods include all methods in each service file, the method name must be unique.

### 举例（example）

#### **跨文件 service 引用**

如果service 分布在不同的 IDL 文件，可以尝试使用extends方法实现service 跨文件引用

If more than one IDL file defines a service, we can use refer to service needed by the 'extends' method in a new file and treat the file as main IDL file

```
// idl/a.thrift

service Service0 {

    Response Method0(1: Request req)

}



// idl/b.thrift

service Service1 {

    Response Method1(1: Request req)

}



// idl/c.thrift

service Service2 {

    Response Method2(1: Request req)

}
```

在一个新的idl文件中extends需要的service，将这个idl文件作为主idl使用

We can use refer to service needed by the 'extends' method in a new file

```
// idl/main.thrift

include "a.thrift"

include "b.thrift"

include "c.thrift"



service ServiceA extends a.Service0{

}



service ServiceB extends b.Service1{

}



service ServiceC extends c.Service2{

}
```

#### **多 service 聚合**

**IDL** 主文件中有多个service, 我们最终会整合为一个大的servcie, 里边包含所有方法

If the IDL main file contains more than one service, we will combine them into one called CombineService, which contains all methods

```
service Service0 {

    Response Method0(1: Request req)

}



service Service1 {

    Response Method1(1: Request req)

}



service Service2 {

    Response Method2(1: Request req)

}
```

多个service会被聚合为一个（muti-service will be combine into one)

```
service CombineService {

    Response Method0(1: Request req)

    Response Method1(1: Request req)

    Response Method2(1: Request req)

}
```