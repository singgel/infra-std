# 简介（Introduction)

BAM IDL 规范是一系列与thrift和protobuf结合的标准，包括服务、接口以及请求request、response参数定义规范和错误码定义规范。使用BAM和这套规范，我们可以进行一系列研发活动，比如自动解析你的IDL并生成接口文档，通过脚手架自动进行代码生成，使用测试和mock来验证你的接口等

BAM IDL standards are serials of standards combined with thrift and protobuf, which contain service, endpoint, request and response parameters definition standards. Using these standards and BAM， we can create API doc automatically by parsing your IDL, generate code by the scaffold, help you validate your endpoint by testing or mocking. Using the standards and enjoy yourself.

# 说明

（1）本规范中定义的IDL注解如api.get, api.header 等，只支持小写，不支持大写或者大小写混用如api.GET, api.Header

# protobuf IDL规范(protobuf IDL standards)

## 文件整体规范(IDL file standards)

我们使用psm作为服务的namespace，每个psm包含一个service， 在service里可以定义接口信息、请求request, response 参数等，我们使用注解来定义接口详情，如接口method，path, cookie , header body 参数等， 注解说明如下

We use psm as namespace of service, each psm IDL should contain only one service, which defines all endpoints including request and response parameters of this service. We use annotations to define the detail parameters of the endpoint, such as method, path, header, cookie, body parameters and so on, the annotations are the following

## HTTP 注解(HTTP annotations)

### 接口注解(Annotations for endpoint)

| **注解** **名称** ******(annotation name)** | **类型** ******(type)** | **注解说明(comment)**                                                                                                                                                                                                                    | **举例** ******(example)**                                                                      |
| --------------------------------------- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| api.get                                 | string                | GET request，the value is http path, the path syntax is aligned with gin [httprouter](https://github.com/julienschmidt/httprouter)- get请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter))      | api.get="/life/client/favorite/collect"                                                       |
| api.post                                | string                | POST request，the value is http path, the path syntax is aligned with gin [httprouter](https://github.com/julienschmidt/httprouter)(post请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter))     | api.post="/life/client/favorite/collect"                                                      |
| api.put                                 | string                | PUT request，the value is http path, the path syntax is aligned with gin [httprouter](https://github.com/julienschmidt/httprouter) (put请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter))      | api.put="/life/client/favorite/collect"                                                       |
| api.delete                              | string                | DELETE request，the value is http path, the path syntax is aligned with gin [httprouter](https://github.com/julienschmidt/httprouter)(delete请求，值为http path，uri的语法与gin一致(参考 [httprouter](https://github.com/julienschmidt/httprouter)) | api.delete="/life/client/favorite/collect"                                                    |
| api.serializer                          | string                | Request serialize method for the client(客户端请求体序列化方式)                                                                                                                                                                                 | form, json, thrift, pb                                                                        |
| api.param                               | string                | If the client request contains common parameter(客户端请求是否需要带上公共参数)                                                                                                                                                                     | true or false                                                                                 |
| api.baseurl                             | string                | The baseurl ttent used for chiocing route(ttnet选路时使用的baseurl)                                                                                                                                                                        | lib.snssdk.com                                                                                |
| api.gen_path                            | string                | The path used for client generating code - 客户端生成代码使用的path（get、post、put、delete定义的path是tlb配置使用的path）                                                                                                                                   | api.post='/v:version/modify'，version变量在更新idl时可以固化，比如说固化为3，那么api.gen_path='/v3/modify'         |
| api.api_version                         | string                | The path used for client generating code, which can replace :version in path - 客户端生成代码是替换path中的:version变量,优先级低于api.gen_path                                                                                                          | api.post='/v:version/modify'，api.version='7'，then the path in generated code is '/v7/modify'。 |
| api.tag                                 | string                | Rpc tag for client, support muti , spliting by , - 客户端rpc增加标签，支持多个，逗号分隔（暂时只支持iOS）                                                                                                                                                    | api.tag="API,DATA"                                                                            |
| api.api_level                           | string                | Api level ([api level standard](https://github.com/singgel/docs/doccnRyYsNPkNAuzvRy7rJ))- 接口分级[接口分级标准](https://github.com/singgel/docs/doccnRyYsNPkNAuzvRy7rJ)                                                                     | api.api_level = "2"                                                                           |
| api.category                            | string                | 接口分类，根据该分类自动生成到doc文档的目录里                                                                                                                                                                                                             |                                                                                               |

**demo**

```
// service comment

service SampleService {

  // SampleRpc注释 leading comment

  rpc SampleRpc(SampleRequest) returns (SampleResponse) {

    option (api.post) = '/life/client/sample/pbrpc';

    option (api.serializer) = 'json';  //序列化方法

  }

  

  //SampleRpc2 comment： leading comment

  rpc SampleRpc2(SampleRequest) returns (SampleResponse) {

    option (api.get) = '/life/client/v:version/sample/pbrpc2';

    option (api.api_version) = "7"; //可以使用api_version注解指定:version变量在代码生成时的值

    option (api.gen_path) = '/life/client/v100/sample/pbrpc2'; //也可以使用gen_path注解整体指定path在代码生成时的值，优先级高于api_version

    option (api.tag) = 'API,DATA'; //可以用tag标记一下这个rpc，客户端可以拿到rpc的tag

  }               

}
```

### 请求Message字段注解(Annotation for request field)

| **annotation(** **注解** **)** | **type(** **类型** **)** | **comment(** **说明** **)**                                                                                            |
| ---------------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------- |
| api.query                    | string                 | the field is query parameter, default parameter type if the method is GET（该字段为请求query参数, 如果是GET方式请求，默认不填写就是query参数）  |
| api.path                     | string                 | the field is path parameter in url - 对应http请求的url path参数                                                             |
| api.header                   | string                 | the field is header parameter in request - 该字段为请求header参数                                                            |
| api.cookie                   | string                 | the field is cookie parameter in request - 该字段为请求cookie参数                                                            |
| api.body                     | string                 | the field is body parameter, default parameter type if the method is POST（该字段为请求body参数, 如果是POST方式请求，默认不填写就是body参数）   |
| api.raw_body                 | string                 | Body parameter different from encrypt body - http原始body，少数接口body加密了，可以拿到原始的body                                      |
| api.vd                       | string                 | Param verify method - 参数校验，使用了[库](https://github.com/bytedance/go-tagexpr/tree/master/validator)，检验表达式语法参见包内readme文件 |
| go.tag                       | string                 | Used for generating go struct tag, for example go.tag='json:"demo, omitempty"'(用于生成go struct 代码中的tag）                |
| api.none                     | string                 | If the field should be ignore while generating code or serializering                                                 |

**注意事项(Notice)**

对于http请求来说，通常参数类型与请求method有关，如果你的idl里没有显式指定参数类型，我们会根据method来设置默认参数类型, 如果是GET请求，我们会默认把参数识别为query参数，如果是POST方法，我们会默认识别为body参数

1.  The parameters someway have relationship with request method for HTTP request, we consider them as default parameter type if you don't specify them explicitly，for example.

    1.  we consider the request parameters as query parameters by default while the method is GET
    1.  we consider the request parameters as body parameters by default while the method is POST

**Demo**

```
//GET request

message HTTPParameterLocationRequest {

  int64 uid = 1 [ (api.path) = 'uid' ];                 //path parameter

  int64 name = 1 [ (api.query) = 'name' ];               //query parameter

  string token = 2 [ (api.header) = 'X-Custom-Token' ];  //header parameter

  bool switch_case = 3 [ (api.cookie) = 'switch_case' ]; //cookie parameter

}



//POST request

message LocationRequest {

  int64 uid = 1 [ (api.body) = 'uid' ];                 //body parameter

  string token = 2 [ (api.header) = 'X-Custom-Token' ];  //header parameter

  bool switch_case = 3 [ (api.cookie) = 'switch_case' ]; //cookie parameter

  bool test_case = 4 [ (api.none) = 'test_case' ];   //the parameter will be removed in api DOC and response 

}
```

### **回包Message字段注解(Annotation for response field)**

| **注解名称 (annotation name)** | **类型 (type)** | **注解说明(comment)**                                         | **举例 (example)**  |
| -------------------------- | ------------- | --------------------------------------------------------- | ----------------- |
| api.header                 | string        | The field is header parameter in response(该字段为回包header参数） | api.header="demo" |
| api.body                   | string        | The field is body parameter in response(该字段为回包body参数）     | api.body="demo"   |
| api.none                   | string        | If the field should be ignore                             |                   |

**demo**

```
message HTTPParameterLocationResponse {

  int64 uid = 1 [ (api.body) = 'uid' ]; // uid

  string token = 2 [ (api.header) = 'X-Custom-Token' ];

  bool switch_case = 3 [ (api.body) = 'switch_case' ];

}
```

### Enum注解 (Annotation for Enum )

| **注解名称 (annotation name)** | **类型 (type)** | **注解说明(comment)**                                                                                                                   | **举例 (example)**                                            |
| -------------------------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| api.deprecated_enum        | string        | This enumVal has been deprecated if api.deprecated_enum="true"                                                                      | api.deprecated_enum="true"                                  |
| api.enum_base_ref          | string        | 通过用于注解说明该enum定义来自于公共包定义, 通常用于tiktok接口裁剪（Used for specifying defination in common package, Usually used for Tiktok api minimination) | （api.base_message_ref="com.ss.ugc.common.tiktok.UrlStruct") |

**Demo**

```
enum FollowerStatus {

   （api.enum_base_ref="com.ss.ugc.common.tiktok::CommentStruct")

    FollowerNotFollowStatus = 0; 

    FollowerFollowStatus = 1 [ (api.deprecated_enum) = 'true' ]; 

}
```

### 错误码注解 (Annotation for error code)

我们使用枚举value的注解来定义error, error 通过用来作为接口的response返回， 包括http_code和http_message

We use enum value annotation to define error which is used for endpoint response, including http_code and http message

| **注解名称 (annotation name)** | **类型 (type)** | **注解说明(comment)**      | **举例 (example)**               |
| -------------------------- | ------------- | ---------------------- | ------------------------------ |
| api.http_code              | string        | 生成error类型中对应的http_code | api.http_code="200"            |
| api.http_message           | string        | 生成error类型中对应的提示信息      | api.http_message="param error" |

N**otice(注意）：**

1.  api.http_code 可以不写，http code 默认使用200(api.http_code may be undefined, 200 was used by default for http_code)
1.  api.http_message 可以不写，默认使用枚举的name作为error message( api.http_message may be undefined, enum name was used for error message by default )
1.  api.http_code, api.http_message 至少写一个，否则错误码无法与普通枚举类型区分(either api.http_code or api.http_message must be defined, or error can't be verifyed)
1.  由于thrift 只支持string类型注解，api.http_code 类型是string，我们对thrift和pb保持一致（while only string type is supported for thrift annotations, api.http_code type is string, we keep in step with thrift ）

```
//example 

enum BapiError {

    Success = 0 [ (api.http_code)="200", (api.http_message)="success" ];  // 正常返回

 ParamError = 1 [ (api.http_code)="400" ];      //use default http_message ParamError

 NoRetry = 2 [ (api.http_message)="no retry" ]; //use default http_code 200

    InternalError = 3 ;                            //common enum, not error

}
```

### Message 注解 （Annotation for message）

| **注解名称 (annotation name)** | **类型 (type)** | **注解说明(comment)**                                                                                                                                   | **举例 (example)**                                          |
| -------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| api.message_base_ref       | string        | 通过用于注解说明该message定义来自于公共包定义, 通常用于tiktok接口裁剪（Used for specifying this message defination in common package, Usually used for Tiktok api minimination) | api.base_message_ref="com.ss.ugc.common.tiktok.UrlStruct" |

**举例（Demo）**

```
message UrlStruct {

    （api.base_message_ref="com.ss.ugc.common.tiktok.UrlStruct")

    optional string uri = 1; 

    repeated string url_list = 2; 

    optional int32 width = 3;

}
```

## RPC 注解(RPC annotations)
# 用法（Usage）

1.  ## 首先引入pb注解文件(refer pb extention file for annotations first)

在使用BAM IDL 注解之前，需要通过import 或者copy 如下PB 注解扩展文件，文件内容如下

Before using BAM PB IDL annotations , the PB extension file for annotations must be imported by IDL file in your project, you can refer it by importing or copying the following file to your project

api.proto

```
syntax = "proto2";



package api;



import "google/protobuf/descriptor.proto";



//本文件是简化版的byteapi protobuf idl注解



extend google.protobuf.FieldOptions {

  optional string raw_body = 50101;

  optional string query = 50102;

  optional string header = 50103;

  optional string cookie = 50104;

  optional string body = 50105;

  optional string path = 50106;

  optional string vd = 50107;

  optional string none = 50108;

}



extend google.protobuf.MethodOptions {

  optional string get = 50201;

  optional string post = 50202;

  optional string put = 50203;

  optional string delete = 50204;

  optional string patch = 50205;

  // optional string options = 50206;

  // optional string head = 50207;

  // optional string any = 50208;

  // optional string re_get = 50211;

  // optional string re_post = 50212;

  // optional string re_put = 50213;

  // optional string re_delete = 50214;

  // optional string re_patch = 50215;

  // optional string re_options = 50216;

  // optional string re_head = 50217;

  // optional string re_any = 50218;

  optional string gen_path = 50301; //客户端代码生成时用户指定的path,优先级高于api_version

  optional string api_version = 50302; //客户端代码生成时，指定path中的:version变量值

  optional string tag = 50303;  // rpc标签，可以是多个，逗号分隔

  optional string name = 50304; // rpc的名字

  optional string api_level = 50305;  //接口等级

  optional string serializer = 50306; //序列化方式, json

  optional string param = 50307;      //客户端请求是否带上公共参数

  optional string baseurl = 50308;    // ttnet选路时使用的baseurl

  optional string version = 50309; //同api_version客户端代码生成时，指定path中的:version变量值

  optional string category = 50310; // 接口类别

}



extend google.protobuf.EnumValueOptions {

  optional string http_code = 50401;

  optional string http_message = 50402;

  optional string deprecated_enum = 50403;

}



extend google.protobuf.EnumOptions {

  optional string enum_base_ref = 50501; // 裁剪的公共Enum源定义

}



extend google.protobuf.MessageOptions {

  optional string message_base_ref = 50601; // 裁剪的公共Message源定义

}



extend google.protobuf.ServiceOptions {

  optional string psm = 50701; // service对应的PSM信息

}
```

go.proto

```
syntax = "proto2";



package go;



import "google/protobuf/descriptor.proto";



//本文件是简化版的byteapi protobuf idl注解



extend google.protobuf.FieldOptions {

  optional string tag = 50501;

}
```

2.  ## 在 IDL 文件里使用注解(Use annotations in IDL file)

### Demo for request & respose

syntax = "proto3";

package mobile_agw.sample;

import "api.proto";

option go_package = "pb_idl";

option java_package = "mobile_agw.sample";

// Sample Enum

// Line two

enum SampleEnum {

EnumZero = 0; // 尾注释

EnumTwo = 2;

// 头注释

EnumFive = 5;

}

// Sample Request

message SampleRequest {

int32 I32Field = 3;

int64 i64_field = 4;

string stringField = 5;

bool BoolField = 6;

double double_field = 7;

// 多行注释

// Line two

bytes binaryField = 8;

map<string, int64> MapField = 9;

repeated string list_field = 10;

SampleEnum enumField = 11;

float FloatField = 12; // 尾接注释

uint32 uint32_field = 13;

uint64 uint64Field = 14;

sint32 Sint32Field = 15;

sint64 sint64_field = 16;

fixed32 fixed32Field = 17;

fixed64 Fixed64Field = 18;

sfixed32 sfixed32_field = 19;

sfixed64 sfixed64Field = 20;

}

message SampleResponse {

int32 I32Field = 3;

int64 i64_field = 4;

string StringField = 5;

bool BoolField = 6;

double double_field = 7;

bytes binaryField = 8;

map<string, int64> MapField = 9;

repeated string list_field = 10;

}

message HTTPParameterLocationRequest {

int64 uid = 1 [ (api.query) = 'uid' ];

string token = 2 [ (api.header) = 'X-Custom-Token' ];

bool switch_case = 3 [ (api.body) = 'switch_case' ];

}

message HTTPParameterLocationResponse {

int64 uid = 1 [ (api.body) = 'uid' ]; // uid

// token

string token = 2 [ (api.header) = 'X-Custom-Token' ];

bool switch_case = 3 [ (api.body) = 'switch_case' ];

// switch case

}

message HTTPGetQueryParameterRequest {

int64 uid = 1;

string type = 2;

}

message HTTPGetQueryParameterResponse {

int64 uid = 1;

string type = 2;

}

// service注释

service SampleService {

// SampleRpc注释 leading comment

rpc SampleRpc(SampleRequest) returns (SampleResponse) {

option (api.post) = '/life/client/sample/pbrpc';

} // SampleRpc注释 tailing comment

////SampleRpc2注释 leading comment

rpc SampleRpc2(SampleRequest) returns (SampleResponse) {

option (api.post) = '/life/client/v:version/sample/pbrpc2';

option (api.api_version) =

"7"; //可以使用api_version注解指定:version变量在代码生成时的值

option (api.gen_path) =

'/life/client/v100/sample/pbrpc2'; //也可以使用gen_path注解整体指定path在代码生成时的值，优先级高于api_version

option (api.tag) =

'API,DATA'; //可以用tag标记一下这个rpc，客户端可以拿到rpc的tag

} // SampleRpc2注释 tailing comment

rpc SampleHTTPParameterLocation(HTTPParameterLocationRequest)

returns (HTTPParameterLocationResponse) {

option (api.post) = '/life/client/sample/pbpl';

}

rpc SampleHTTPGetQueryParameter(HTTPGetQueryParameterRequest)

returns (HTTPGetQueryParameterResponse) {

option (api.get) = '/life/client/sample/pbget';

}

}

### 错误码注解举例 (Demo for error code)

`enum StatusCode {`

` Success = 0 [ (api.http_code)=200 ];  ``// 正常返回`

**Error = 1 [ (api.http_code)=400 ];

**NoRetry = 2[ (api.http_code)=500];

}

//code generage is the following 上述生成代码后错误类型对象值为

{

HttpCode: 200,

Code: 0,

Message: "Success",

},

{

HttpCode: 400,

Code: 1,

Message: "Error",

},

{

HttpCode: 500,

Code: 2,

Message: "NoRetry",

},
# 注意事项(Notice )

Pb IDL文件请勿在注解中写入转义符 \ ，pb解析不支持,例如：(go.tag = 'json:\"omitempty\"')会报错，(go.tag = 'json:"omitempty"')可正常解析

Please don't use escape character \ in PB IDL, which is not supported by protobuf. For example (go.tag = 'json:"omitempty") is correct, while (go.tag = 'json:\"omitempty\") is unsupported