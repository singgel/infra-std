<!--
 * @Author: your name
 * @Date: 2022-04-14 16:35:35
 * @LastEditTime: 2022-04-21 14:26:32
 * @LastEditors: Please set LastEditors
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 * @FilePath: /infra-std/GIT_flow_norm/IDE_golang_coding_style.md
-->
# **引言**

### 背景

Golang语言官方并没有统一的编码规范，只有effective_go和CodeReviewComments建议。网上关于Golang的编码规范几乎很少，一般团队内部会简单维护一个编码规范，可参考性弱。Golang在公司内部使用广泛，但是每个团队都有自己的编码风格，好些习惯可能基于其他语言延续，更偏向于个人风格。对于刚接触Golang的新人来说，以及后续维护者来说，编码规范不统一是比较糟糕的事情。

### 目标

统一公司Golang编码规范，提高软件源程序的可读性、可靠性和可重用性，提高软件源程序的质量和可维护性，减少软件维护成本，同时尽量提高性能。

### 内容

本规范的内容包括：格式化、包管理、包设计、注释、命名、基本元素设计、函数设计、错误、测试等。

对本规范中所用的术语解释如下：

**原则**：编程时应该坚持的指导思想。

**规则**：编程时必须遵守的约定。

**建议**：编程时必须加以考虑的约定。

**说明**：对此规则或建议的必要的解释。

**正例**：对此规则或建议给出的正确例子。

**反例**：对此规则或建议给出的反面例子。

**示例：** 对此规则或建议给出的正确or错误例子。

# 格式化

### [规则1-1]缩进

-   ***行首统一使用制表符(tab)缩进***
-   ***同一行元素之间，以空格缩进，缩进长度同*** ***tab（8字符长度）** ****；行尾注释也保持同步***

**说明**：pycharm在edition->preferences->code style->go设置；目前Golang官方源码、很多知名开源库使用Tab作为行首缩进符；gofmt默认也适用tab

**建议**：所写代码使用gofmt工具格式化，命令如下

```
find ./ *.go | grep -v vendor | xargs gofmt -w
```

**正例：**

```
type T struct {

        name    string // 对象名

        value   int    // 对象值

}
```

**反例：**

### ```
type T struct {          name string // 对象名          value int // 对象值  } 
```[规则1-2]行长

-   ***每行代码长度不超过120字符，超过120字符折行并插入适当的tab缩进；对函数&类方法适用***

### [规则1-3]分号

-   ***表达式最后无需分号，for、if表达式中除外***

**示例：**

### ```
正例：  if val, ok := GetVal(); ok {  }    for i := 0; i < 10; i++ {  } 
```[规则1-4]控制表达式括号

-   ***对于if、for、switch控制表达式，不使用()***
-   ***对于复杂表达式，整体最外层不使用()；里面单个简单表达式使用()明确优先级***

**正例**

```
if n > 2 {

}



switch n {

case n > 2:

}



if (a > 2) && (c > 3) {

}
```

**反例**

# ```
if (n > 2) {  }    switch (n) {  case (n > 2):  }    if ((a > 2) & (c > 3)) {  }    if a > 2 & c > 3 {  }   
```包管理

### [规则2-1]包管理工具

-   ***统一使用govendor工具管理***

**说明**：（Golang1.11后支持module管理，通过GO111MODULE=off/on来关闭开启mod，这里暂不考虑）

-   go mod推荐

### [规则2-2]vendor目录

-   ***禁止手动修改vendor目录下包中的代码，统一通过govendor update实现***
-   ***禁止手动修改vendor/vendor.json，merge conflict除外***
-   ***govendor添加依赖包，不要包含依赖包测试文件***

**建议**：常用govendor命令如下

# ```
// 安装govendor  go get -u -v github.com/kardianos/govendor  export GO15VENDOREXPERIMENT=1 // 启用govendor    govendor init  // 初始化vendor目录  govendor list  // 列出当前所有包依赖  govendor list +e // 列出当前所有外部包依赖(在gopath路径有)  govendor list +m // 列出当前所有外部包依赖(在gopath路径没有)  govendor add +e // 添加当前所有外部包依赖(在gopath路径有)    // 获取所有本地路径没有的包；并添加本地路径  pkgs=`govendor list +m|cut -d"m" -f2-`;for x in $pkgs; do go get -u "$x"; done 
```设计原则

-   ***满足单一职责原则***
-   ***标识符遵守最小可见性原则***

**说明：** 全局变量明确其尽量不要对外暴露，应该以函数的方式提供（除了main里访问除外）。

### [规则3-2]测试文件

-   ***测试文件放在实现文件的同级目录下或者把所有测试文件放到一个子目录test下***

### **[规则3-3]import包**

-   ***import包时不允许使用点.操作，测试除外***
-   ***import包时不允许使用别名，同时导入2个相同的包名除外***
-   ***import 导入包时统一使用小括号，包名要另起一行***

**说明：** import "C"除外

**正例：**

```
import "C"

import (

        "fmt"

        "reflect"

)
```

**反例：**

```
import "C"

import "fmt"

import "reflect"
```

-   ***import 包时以 $GOPATH 为基准使用绝对路径，不要从当前位置开始使用相对路径***

示例：

-   ```
    import "../net"  //错误示例

    import "github.com/repo/proj/src/net" // 正确示例
    ```

    ***对import的包进行分组管理，用换行符分割，而且标准库作为*** ***分组*** ***的第一组。如果你的包引入了三种类型的包，标准库包，第三方包，程序内部包。那么分组的顺序：标准库包、第三方包、程序内部包。***

示例：

# ```
import (          // 标准库          "fmt"           "os"              // 第三方包          "code.google.com/a"            "github.com/b"                     // 程序内部包          "kmg/a"          "kmg/b"  ) 
```注释

### [规则4-1] 包注释

-   ***每个包都应包含一段包注释，即放置在包子句前的一个块注释。对于包含多个文件的包， 包注释只需出现在其中的任一文件中即可。包注释应在整体上对该包进行介绍，并提供包的相关信息。 它将出现在*** `godoc` ***页面中的最上面，并为紧随其后的内容建立详细的文档。***

示例：

```
// Copyright 2009 The Go Authors. All rights reserved.

// Use of this source code is governed by a BSD-style

// license that can be found in the LICENSE file.



// Package strings implements simple functions to manipulate UTF-8 encoded strings.

//

// For information about UTF-8 strings in Go, see https://blog.golang.org/strings.

package strings
```

or

### ```
/*          regexp 包为正则表达式实现了一个简单的库。          该库接受的正则表达式语法为：          正则表达式:                  串联 { '|' 串联 }          串联:                  { 闭包 }          闭包:                  条目 [ '*' | '+' | '?' ]          条目:                  '^'                  '$'                  '.'                  字符                  '[' [ '^' ] 字符遍历 ']'                  '(' 正则表达式 ')'  */  package regexp 
```[规则4-2]代码注释

-   ***注释与所描述内容进行同样的缩进***
-   ***避免垃圾注释***

**说明：** 对于代码本身能够表达的意思，不必增加额外的注释（函数代码行数足够短或者一看即懂）

示例：

-   ```
    // 无需注释

    func IsEven(x int) bool {

        return (x & 1) == 0

    }
    ```

    ***保证代码和注释的一致性***

**说明：** 修改代码同时修改相应的注释，不再有用的注释要删除

-   ***注释应与其描述的代码相近，对代码的注释应放在其上方或右方（对单条语句的注释）相邻位置，不可放在下面，如放于上方则需与其上面的代码用空行隔开，而且注释内容与与被注释的代码相同缩进***

    -   ***对于struct成员变量&全局变量，注释可以放在上方或者右方***
    -   ***对于struct本身或者函数本身或者struct成员方法，注释放在上方***

示例：

# ```
type Regexp struct {         // read-only after Compile         regexpRO           // cache of machines for running regexp         mu      sync.Mutex         machine []*machine  }    // String returns the source text used to compile the regular expression.  func (re *Regexp) String() string {         return re.expr  } 
```命名

### [规则4-1]整体原则

-   ***使用驼峰命名法***

示例：

-   ```
    var mixedCaps int

    var MixedCaps string
    ```

    ***以词达意***

说明：for循环里索引标识除外

示例：

### ```
var testArray []int  for i, val := range testArray {  }  
```[规则4-2]包命名

-   ***目录名一律使用小写和中划线风格的名称***
-   ***最后层目录和包名一致***
-   ***包名一律使用小写风格，通常为过滤掉中划线的目录名***
-   ***开发文件命名一律使用小写和下划线风格的名称***

示例：

### ```
正例：  目录名：context  对应的包名：context  目录名：port-obj  对应的包名：portobj  文件名：knitter_virtual_machine.go    反例：  目录名：Context  目录名：port_obj  文件名：  knitter-virtual-machine.go  KnitterVirtualMachine.go  knittervirtualmachine.go 
```[规则4-3]常量、变量、类型、函数、接口命名

-   ***统一遵循驼峰命名法***
-   ***常量、变量避免在名称中携带类型信息***
-   ***常量、变量避免在名称中携带作用域的信息，使用首字母大小写决定包外可见性***
-   ***尽量少使用iota***

**示例：**

```
var num int  // 正例

flag bool    // 正例

var gNum int // 反例

var lNum int // 反例

bFlag bool // 反例
```

**建议：** 对于枚举常量，使用完整的前缀修饰

**示例：**

-   ```
    // 数据源类型

    type PltSrcType int



    const (

           // 数据源类型定义

           PltSrcTypeUnknown PltSrcType   = -1

           PltSrcTypeTcc PltSrcType       = 0

           PltSrcTypeEtcd PltSrcType      = 1

           PltSrcTypeSSConf PltSrcType    = 2

           PltSrcTypeRedis PltSrcType     = 3

           PltSrcTypeAabse PltSrcType     = 4

           PltSrcTypeDb PltSrcType        = 5

    )
    ```

    ***函数名名应当是动词或动词短语，如postPayment、deletePage、save***

-   ***结构体命名规则：结构体名应该是名词或名词短语，如Custome、WikiPage、Account、AddressParser，避免使用Manager、Processor、Data、Info、这样的类名，类名不应当是动词。***

-   ***单个函数的接口名以"er"作为后缀，如Reader，Writer。** ****接口的实现则去掉“er”***

**示例：**

-   ```
    type Reader interface {

            Read(p []byte) (n int, err error)

    }

    type WriteFlusher interface {

            Write([]byte) (int, error)

            Flush() error

    }

    type Car interface {

            Start([]byte)

            Stop() error

            Recover()

    }
    ```

    ***receiver 的名称应该简短，一般使用一个或者两个字符作为Receiver的名称。如果方法中没有使用receiver，还可以省略receiver name，这样更清晰的表明方法中没有使用它***

**示例：**

-   ```
    func (f foo) method() {

            ...

    }



    func (foo) method() {

            ...

    }
    ```

    ***团队使用统一的缩略语，并和业界常用的缩略语保持一致***

**说明：** 较短的单词可通过去掉“元音”形成缩写，较长的单词可取单词的头几个字母形成缩写，一些单词有大家公认的缩写，常用单词的缩写必须统一。

**示例：**

-   ```
    temp => tmp

    flag => flg

    statistic => stat

    increment => inc

    message => msg

    buffer => buf

    error => err

    argument => arg

    parameters => params

    initialize => init

    index => idx

    context => ctx

    clear => clr

    pointer => ptr

    previous => prev

    request => req

    response => resp|rsp

    maximum => max

    minimum => min
    ```

    ***对于专有名词的命名，** ****应该全部大写或者全部小写***

# ```
ACL,API,ARPU,ASCII,BO,CPA,CPC,CPM,CPU,CSS,CPP,CPS,CPT,CQRS,CTR,CVR,DNS,DAU,DO,DSP,DTO,EOF,GUID,HTML,HTTP,HTTPS,ID,IO,IP,JSON,KPI,LBS,LHS,MAU,OKR,PC,PV,PO,POJO,QPS,RAM,RHS,RPC,SEM,SEO,SLA,SMTP,SNS,SPAM,SOHO,SQL,SSH,TCP,TLS,TTL,UDP,UGC,UED,UI,UID,UUID,URI,URL,UV,VM,VO,VR,XML,XMPP,XSRF,XSS,    // 正例  userid, userID, urlArray  // 反例  UserId, UrlArray 
```
# 基本元素设计

### [规则5-1]struct规范

-   ***struct申明和初始化格式采用多行：起始申明占一行，每个成员占一行，结束}占一行；** ****如果*** ***struct结构简单或者赋值字段1-2个，初始化可以使用一行。***

**正例：**

```
type User struct {

        Username  string

        Email     string

        ID        int

        BirthDay  time.Time

        Age       int

        Gender    uint8

}



type Worker struct {

        Name String

        Age  int

}
```

**反例：**

```
type User struct

{

        Username  string;Email     string

        Id        int

        BirthDay  time.Time

        Age       int

        Gender    uint8

}
```

**初始化示例：**

```
正例：

// 多字段初始化

u := User{

        Username: "test",

        Email:    "test@gmail.com",

}

// 单行初始化

u := User{Username: "test"}

w := Worker{"test", 19}

反例：

u := User{Username:"test",Id:121212,BirthDay:20190909,Age:12,Gender:0} 
```

-   ***如果 struct 中的数据变量需要进行 json 序列化，则需要以大写字母开头，同时需要 json 重命名。***

**说明：** 结构体中的变量以大写字母开头，可以保证 json.Marshal 的时候数据持久化正确。如果结构体中的变量以小写字母开头，则使得 json.Marshal 的时候忽略该字段，使得该字段的值丢失，从而 json.Unmarshal 的时候将该变量的值置为默认值。由于结构体中的变量以大写字母开头， json串中的字段 key 的字符串形式变成了以大写字母开始，这对于追求以 json 串全小写为美的我们来说，需要进行json重命名。

**建议**：对于序列化的json结构来说，字符串字段慎用[]byte。（[]byte序列化会被base64，会引起跨语言解析失败）

**正例：**

```
type Position struct {

        X int `json:"x"`

        Y int `json:"y"`

        Z int `json:"z"`

}

type Student struct {

        Name string `json:"name"`

        Sex string `json:"sex"`

        Age int `json:"age"`

        Posi Position `json:"position"`

}
```

**反例：**

```
type Position struct {

    X int

    Y int

    Z int

}

type Student struct {

    Name string

    Sex string

    Age int

    Posi Position

}
```

### [规则5-2]if

-   ***若 if语句不会执行到下一条语句时，即其执行体 以break、continue、goto或return结束时，else省略***

**正例：**

```
if err := file.Chmod(0664); err != nil {

        log.Print(err)

        return err

}



f, err := os.Open(name)

if err != nil {

        return err

}

codeUsing(f)
```

**反例：**

-   ```
    if err := file.Chmod(0664); err != nil {

            log.Print(err)

            return err

    } else {

            xxxx

    }



    if f, err := os.Open(name); err != nil{

            return err

    } else {

            codeUsing(f)

    }
    ```

    对于布尔类型的变量，应直接进行真假判断

**示例：**

-   ```
    正例

    if flag  /* 表示flag为真 */

    if !flag  /* 表示flag为假 */

    反例

    if flag == true

    if flag == false
    ```

    if 语句的嵌套层数不要太多，不大于3，超过优化代码逻辑

### [规则5-3]for

-   for语句的嵌套层数不要太多，不大于3，超过优化代码逻辑
-   使用for循环时，优先使用range 关键字而不是显式下标递增控制，除非需要显示修改某下标元素内容

**示例：**

### ```
正例  for i := 0; i < len(array); i++ {          if i & 1 == 0 {              array[i] += 1          }  }  for i, v := range array {          fmt.Printf("element %v of array is %v\n", i, v)  }    反例  for i := 0; i < len(array); i++ {          fmt.Printf("element %v of array is %v\n", i, array[i])  } 
```[规则5-4]表达式

-   逻辑表达式已经具有 true 或 false 语义，应尽量简洁

**示例：**

-   ```
    正例

    return i == 3



    反例

    if i == 3 {

            return true

    } else {

            return false

    }
    ```

    单目运算符之间不用空格，双目运算符之间用空格隔开；下列运算符之间不需要空格

    -   关系运算符：!
    -   位运算符： ^, >>, <<,
    -   其他：取地址运算符&， 指针运算符*

**示例：**

# ```
正例  x<<8 + y<<16  a & b  (*a).Field    反例  a+b  x << 8 + y << 16  a&b 
```函数设计

### [规则6-1]**函数命名**

-   要短小精悍和名副其实，避免误导。一般以它" 做什么" 来命名，而不是以它" 怎么做" 来命名

### [规则6-2]函数结构

-   函数应该做一件事，做好这件事，只做这一件事
-   ****函数要短小，包括空行和{}，这里建议不超过80行，多了拆分多个函数
-   函数的缩进层次不应该超过3层

### [规则6-3]函数参数

-   函数参数个数应该限制，入参控制在5个内

    -   建议：出参控制在2个内

-   对于简单结构，不要传递指针；对于大结构数据的struct可以考虑使用指针

-   传入参数是map，slice，chan不要传递指针，因为map，slice，chan是引用类型，不需要传递指针的指针

-   参数列表中若干个相邻的参数类型相同，在参数列表中省略前面变量的类型声明

-   当 channel 作为函数参数时，根据最小权限原则，使用单向 channel

**示例：**

```
func Parse(ch <-chan int)

func After(d Duration) <-chan Time 
```

**建议：** 形参和返回值在定义时带上名称，使代码更清晰

**示例：**

# ```
正例  func nextInt(b []byte, pos int) (value, nextPos int)  func ReadFull(r Reader, buf []byte) (n int, err error)    反例  func nextInt([]byte, int) (int, int)  func ReadFull(Reader, []byte) (int, error) 
```错误

### [规则7-1]使用规则

-   正确的使用error返回值，禁止将错误值返回（例如用-1表示EOF）和修改通过地址传入的实参
-   对于api中含有err返回值，禁止使用_忽略错误返回值

**示例：**

### ```
正例  data, err := json.Marshal(a)  if err != nil {          xxx  }    反例  data, _ := json.Marshal(a) 
```[规则7-2]错误设计

-   包内错误值统一分组定义，而不是零散的分布在各个角落

**正例：**

-   ```
    // file error objectvar （

            ErrEof = errors.New("EOF")

            ErrClosedPipe = errors.New("io: read/write on closed pipe")

            ErrShortBuffer = errors.New("short buffer")

            ErrShortWrite = errors.New("short write")

    ）

    // port error objectvar (

            ErrAddPortToOvsBriFailed = errors.New("add port to ovs bri failed")

            ErrPortNotEnteredPromiscuousMod = errors.New("port not entered promiscuous mod")

        ...

    )
    ```

    失败的原因只有一个时，不使用error

-   当函数的error返回值始终是nil时，不使用error作为返回值

**正例：**

```
func (self *AgentContext) IsValidHostType(hostType string) bool {

        return hostType == "virtual_machine" || hostType == "bare_metal"

}
```

**反例：**

-   ```
    func (self *AgentContext) CheckHostType(hostType string) error {

            switch hostType {

            case "virtual_machine":

                return nil

            case "bare_metal":

                return nil

            }

            return ErrInvalidHostType

    }
    ```

    ****error/bool应放在返回值类型列表的最后

**正例：**

-   ```
    resp, err := http.Get(url)

    if err != nil {

        return nil, err

    }



    value, ok := cache.Lookup(key) 

    if !ok {

        // ...cache[key] does not exist… 

    }
    ```

    每一层捕获错误，如无必要，无需逐层传递

-   错误处理巧用defer

**正例：**

```
func deferDemo() error {

        err := createResource1()

        if err != nil {

                return ErrCreateResource1Failed

        }

        defer func() {

                if err != nil {

                        destroyResource1()

                }

        }()

        err = createResource2()

        if err != nil {

                return ErrCreateResource2Failed

        }

        defer func() {

                if err != nil {

                        destroyResource2()

                }

        }()



        err = createResource3()

        if err != nil {

                return ErrCreateResource3Failed

        }

        defer func() {

            if err != nil {

                    destroyResource3()

            }

        }()



        err = createResource4()

        if err != nil {

                return ErrCreateResourc4Failed

        }

        return nil

}
```

**反例：**

-   ```
    func deferDemo() error {

            err := createResource1()

            if err != nil {

                    return ErrCreateResource1Failed

            }

            err = createResource2()

            if err != nil {

                    destroyResource1()

                    return ErrCreateResource2Failed

            }



            err = createResource3()

            if err != nil {

                    destroyResource1()

                    destroyResource2()

                    return ErrCreateResource3Failed

            }



            err = createResource4()

            if err != nil {

                destroyResource1()

                destroyResource2()

                destroyResource3()

                return ErrCreateResource4Failed

            }

            return nil

    }
    ```

    错误消息应以小写字母开头，不应以.结尾。为保持一致性，应对日志消息应用相同的逻辑。

示例：

### ```
正例  logger.Print("something went wrong")  ErrReadFailed := errors.New("could not read file")  反例  logger.Print("Something went wrong.")  ReadFailError := errors.New("Could not read file") 
```[规则7-3]panic&recover

-   尽量不要使用panic，除非你知道你在做什么
-   对于每个协程调用栈，routine1->routine2->routine3，使用defer加入recover，除非你能确保每个goroutine能够正常终止

**示例：**

# ```
func server(workChan <-chan *Work) {          for work := range workChan {                  go safelyDo(work)          }  }    func safelyDo(work *Work) {          defer func() {                  if err := recover(); err != nil {                          log.Println("work failed:", err)                  }          }()          do(work)  } 
```测试

### [规则8-1]测试设计

-   不要为了测试而对产品代码进行侵入性修改

**说明：** 禁止为了测试而在产品代码中增加条件分支或函数变量。

-   应当为每个线上生产代码补上单元测试，除非生产代码是很简洁通用的代码
-   测试应该是黑盒的。

**说明：** 避免根据代码编写测试。


# 参考：

https://github.com/golang/go/wiki/CodeReviewComments

https://golang.org/doc/effective_go.html

https://go-zh.org/doc/effective_go.html

https://go-zh.org/ref/spec

http://google.github.io/styleguide/

https://www.jianshu.com/p/4540bb8fc9b5

https://github.com/bahlo/go-styleguide

https://github.com/golang/go/tree/master/src