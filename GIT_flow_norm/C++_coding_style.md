ByteDance C++ Style Guide

# 0、前言

Thus, programs must be written for people to read, and only incidentally for machines to execute.

艺术是什么？

艺术和工程仿佛在光谱的两端，

但艺术无处不在，

不带dirty work的工程，就是一种艺术。

-- 《Word排版艺术》

说明1：每个条款会标明是【规范】或【建议】。规范请大家遵照，建议的条款给大家较大的自由度。

说明2：老代码或者第三方代码，请保持原有的代码风格或规范。

说明3：本文档是基于下面两份文档略加整理，有些条款增强为规范，有些条款改为建议，有些条款内容作了修改。感谢下述文档作者。

参考资料1：[Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)

参考资料2：[Google C++ 风格指南（中文版）](http://zh-google-styleguide.readthedocs.io/en/latest/google-cpp-styleguide/contents/)

参考资料3: [The Art of Readable Code](https://www.oreilly.com/library/view/the-art-of/9781449318482/)

# 1、格式

## 1.1 行宽度

**【建议】**

考虑到尊重项目历史，我们有两种主流的行宽度。默认情况下，建议行宽度不超过80个字符。根据项目历史代码，可以放宽到120个字符。

（原google编码规范是80个字符，这里放宽到120字符。再多就不好了。）

（120字符的原因是，我们公司的DELL显示器，13pt Monaco字体下行宽大概是240字符左右。这个没考虑MacBook Pro。）

**【优点】**

提升代码的可读性，并且与已有代码风格保持一致。

**【缺点】**

如果无法在不伤害易读性的条件下进行断行，那么注释行可以超过 120 个字符，这样可以方便复制粘贴。

例如，带有命令示例或 URL 的行可以超过 120 个字符。

## 1.2 缩进

**【规范】**

使用空格缩进。每次2个空格。当行宽度放宽到120个字符时，每次缩进使用4个空格。

在同一个项目中，行宽度和缩进需要保持一致。

（即：2空格缩进配合80列使用，4空格缩进配合120列使用）

折行使用2倍缩进。（参数一行放不下时进行折行缩进）

不要在代码中使用tab。你应该设置编辑器将制表符转为空格。

## 1.3 函数声明与定义

**【规范】**

返回类型和函数名在同一行。参数也尽量放在同一行，如果放不下就对形参分行，分行方式与函数调用一致。分行方式如下说明。

**【说明】**

函数看上去长这样：

```
ReturnType ClassName ::function_name(Type par_name1, Type par_name2) {

    do_something();

    ...

}
```

如果同一行文本太多，放不下所有参数，折行缩进：

```
ReturnType ClassName ::really_long_function_name(Type par_name1,

        Type par_name2, Type par_name3) {

    do_something();

    ...

}
```

甚至连第一个参数都放不下：

```
ReturnType LongClassName ::really_really_really_long_function_name(

        Type par_name1,  // 8 space indent

        Type par_name2,

        Type par_name3) {

    do_something();  // 4 space indent

    ...

}
```

注意以下几点:

-   使用好的参数名
-   只有在参数未被使用时，才能省略参数名，否则都带上参数名
-   如果返回类型和函数名在一行放不下，分行
-   如果返回类型与函数声明或定义分行了，不要缩进
-   左圆括号总是和函数名在同一行
-   函数名和左圆括号间永远没有空格
-   圆括号与参数间没有空格
-   左大括号总在最后一个参数同一行的末尾处，不另起新行
-   右大括号总是单独位于函数最后一行
-   右圆括号和左大括号间总是有一个空格
-   所有形参应尽可能对齐
-   如果参数有折行，折行后的参数保持2倍缩进

## 1.4 Lambda 表达式

**【规范】**

Lambda 表达式对形参和函数体的格式化和其他函数一致；捕获列表同理，表项用逗号隔开。

显式列出捕获列表，禁止使用默认捕获。

## 1.5 函数调用

**【规范】**

要么一行写完函数调用，要么折行，参数按2倍缩进。

如果没有其它顾虑的话，尽可能精简行数，比如把多个参数适当地放在同一行里。

**【说明】**

函数调用遵循如下形式：

```
bool retval = do_something(argument1, argument2, argument3);
```

如果同一行放不下，可断为多行，折行后按2倍缩进：

```
bool retval = do_something(averyveryveryverylongargument1,

        argument2, argument3);
```

参数也可以全部放在次行, 缩进8格：

```
if (...) {

    ...

    ...

    if (...) {

        do_something(

                argument1, argument2,  // 2倍缩进

                argument3, argument4);

    }

}
```

把多个参数放在同一行还是把每个参数都独立成行，各有优缺点。多个参数放同一行可以减少代码调用需要的行数。每个参数独立成行更易读并且方便编辑参数。两种方式都可以使用。规则是分行时要对齐。

（个人倾向每个参数独立成行，因为多个参数放同一行曾经引起过bug。）

## 1.6 列表初始化格式

**【规范】**

您平时怎么格式化函数调用，就怎么格式化列表初始化。

代码示例详见条款 8.17 列表初始化。

## 1.7 条件语句

**【规范】**

关键字 if 和 else 另起一行。

圆括号和条件之间没有空格。

if 和左圆括号之间有空格。

右圆括号和左大括号之间有空格。

单行语句也必须使用大括号。就说是，大括号必不可少。[不加括号的一个bug见这里。](https://coolshell.cn/articles/11112.html)

if 语句是很复杂的，想写好，请参见这里 [怎么写 if 语句](https://wiki.bytedance.net/pages/viewpage.action?pageId=52889466)。

```
// 大括号不可少

if (condition) {

    foo;

} else {

    bar;

}
```

## 1.8 switch 语句和空循环

**【规范】**

switch 语句的 case 块必须使用大括号。

允许多个并列的 case 共用同一个 case 块，每个 case 标记独占一行，最后一个 case 标记带上左括号。

switch 语句必须包含 default 匹配。如果 default 应该永远执行不到，可以简单的加条 assert 。

空循环体应该使用 {} 或者 continue，以明确表示意图。

```
switch (var) {

    case 0: {

        ...

        break;

    }

    case 1: {

        ...

        break;

    }

    default: {

        assert(false);

    }

}



// 空循环体

while (condition) {

    // 反复循环直到条件失效

}



while (condition) {

    continue;  // 可 - continue 表明没有逻辑

}
```

## 1.9 指针和引用表达式

**【规范】**

句点或箭头前后不要有空格。

指针/地址操作符 (*，&) 之后不能有空格。

在声明指针变量或参数时，* &靠近类名（靠左）。

```
x = *p;

p = &x;

x = r.y;

x = r->y;



// 靠近类名

char* c;

const string& str;
```

**【说明】**

选择 * & 靠近类名，因为 clang-format 只支持靠左，不支持靠右...

## 1.10 布尔表达式

**【规范】**

如果一个布尔表达式超过标准行宽，断行时运算符放在行首。（如果附近代码有其他写法，那么折行方式要统一）

```
if (this_one_thing > this_other_thing

    && a_third_thing == a_fourth_thing

    && yet_another

    && last_one) {

    ...

}
```

## 1.11 函数返回值

**【规范】**

不要在 return 表达式里加上非必须的圆括号。

```
return result; // 返回值很简单, 没有圆括号



// 可以用圆括号把复杂表达式圈起来, 改善可读性

return (some_long_condition && another_condition);
```

## 1.12 变量及数组初始化

**【规范】**

用 =，( )，{ } 均可。

## 1.13 预处理指令

**【规范】**

预处理指令不要缩进，从行首开始。

即使预处理指令位于缩进代码块中，指令也应从行首开始。

```
// 好 - 指令从行首开始

    if (lopsided_score) {

#if DISASTER_PENDING      // 正确 - 从行首开始

        drop_everything();

# if NOTIFY               // 非必要 - # 后跟空格

        notify_client();

# endif

#endif

        back_to_normal();

    }
```

## 1.14 类格式

**【规范】**

访问控制块的声明依次是public、protected、private。（此条为建议，下述为规范）

访问控制关键字public、protected、private不带缩进。

所有基类名称应在120列限制规则下尽量与子类名称放在同一行。

除第一个关键词（一般是public），其他关键词之前要空一行。

如果有一组typedef，请集中放置。

关键词之后不要空行。

## 1.15 构造函数初始化列表

**【建议】**

构造函数初始化列表放在同一行或按折行缩进（2倍缩进）并排多行。

（构造函数初始化列表格式如何处理，尝试过多种方式，都不太好处理。这里作为建议条款。重要的是保持风格一致性。）

```
// 如果所有变量能放在同一行:

MyClass::MyClass(int var) : var_(var) {

    do_something();

}



// 如果不能放在同一行,

// 必须置于冒号后, 并缩进

MyClass::MyClass(int var)

        : some_var_(var), some_other_var_(var + 1) {

    do_something();

}



// 如果初始化列表需要置于多行, 将每一个成员放在单独的一行

// 并逐行对齐

MyClass::MyClass(int var)

        : some_var_(var),             // 8 space indent

          some_other_var_(var + 1) {  // lined up

    do_something();

}



// 右大括号 } 在一定条件下可以和左大括号 { 放在同一行

MyClass::MyClass(int var) : some_var_(var) {}
```

## 1.16 命名空间

**【规范】**

命名空间不增加额外的缩进层次。

声明嵌套命名空间时，每个命名空间都独立成行。

命名空间对应的大括号后必须用注释写明是哪个命名空间。

```
namespace {



void foo() {  // 正确。命名空间内没有额外的缩进

    ...

}



}  // namespace



namespace foo {

namespace bar { // 正确。命名空间独立成行

    ...

}  // namespace bar

}  // namespace foo
```

## 1.17 空格

**【规范】**

永远不要在行尾添加没必要的空格。

```
void f(bool b) {  // 左大括号前总是有空格

  ...

int i = 0;  // 分号前不加空格

// 列表初始化中大括号内的空格是可选的

// 如果加了空格, 那么两边都要加上

int x[] = { 0 };

int x[] = {0};



// 继承与初始化列表中的冒号前后恒有空格.

class Foo : public Bar {

public:

    // 对于单行函数的实现, 在大括号内加上空格

    // 然后是函数实现

    Foo(int b) : Bar(), baz_(b) {}  // 大括号里面是空的话, 不加空格

    void reset() { baz_ = 0; }  // 用空格把大括号与实现分开

    ...
```

```
if (b) {          // if 条件语句和循环语句关键字后均有空格

} else {          // else 前后有空格

}

while (test) {}   // 圆括号内部不紧邻空格

switch (i) {

for (int i = 0; i < 5; ++i) {

switch (i) {

    case 1:         // switch case 的冒号前无空格

    ...
```

```
// 赋值运算符前后总是有空格

x = 0;



// 其它二元操作符也前后恒有空格, 不过对于表达式的子式可以不加空格

// 圆括号内部没有紧邻空格

v = w * x + y / z;

v = w*x + y/z;

v = w * (x + z);



// 在参数和一元操作符之间不加空格

x = -5;

++x;

if (x && !y)
```

## 1.18 空行

**【规范】**

函数声明之间空一行。（不要不空行，也不要空多行。）

函数实现之间空一行。

函数体首尾不要留空行。

相对独立的程序块之间空一行。

过于密集的代码块和过于疏松的代码块同样难看。

## 1.19 循环体和条件语句嵌套

循环体（for while...) ，不推荐超过三层嵌套

条件语句控制体（ if else...）， 不推荐超过三层嵌套

Fast Break，避免冗长的分支逻辑代码块 [嵌套的箭头](https://coolshell.cn/articles/17757.html)

# 2、注释

注释虽然写起来很痛苦，但对保证代码可读性至关重要。下面的规则描述了如何注释以及在哪儿注释。

当然更要记住，注释固然很重要，但最好的代码应当本身就是文档。

有意义的类型名和变量名，要远胜过要用注释解释的含糊不清的名字。

还有，养成写注释的习惯后，其实写注释也会成为写代码的很自然一部分。

**【建议】**

基础库尽量用英文注释。业务代码可以根据业务需求，以讲清楚、看得懂为优先。国际化代码尽量用英文注释。

## 2.1 注释风格

**【规范】**

使用 // 或者 /* */ 都可以，统一就好。

~~（个人建议）~~使用 // 更佳，这种使用代码 diff 工具时会让你一目了然。

注释语句放在代码上面（而不是行尾）。

## 2.2 文件注释

**【建议】**

~~在每一个文件开头加入~~~~版权声明~~~~。~~

文件注释描述了该文件的内容。如果一个文件只声明、实现或测试了一个对象，并且这个对象已经在它的声明处进行了详细的注释，那么就没必要再加上文件注释。除此之外的其他文件都需要文件注释。

一个一到两行的文件注释就足够了，对于每个概念的详细文档应当放在各个概念中，而不是文件注释中。

## 2.3 类注释

**【建议】**

每个类的定义都要附带一份注释，描述类的功能和用法，除非它的功能相当明显。

特别注意多线程相关，要注释说明多线程环境下相关的规则和常量使用。

如果你想用一小段代码演示这个类的基本用法或通常用法，放在类注释里也非常合适。

```
// 管理定向用数据，单例，负责TargetingIndexData的创建与销毁

// 有锁，线程安全

class TargetingIndexMgr {

public:

    TargetingIndexMgr();

    ~TargetingIndexMgr();
```

## 2.4 函数注释

**【建议】**

函数声明处的注释描述函数功能，函数定义处的注释描述函数实现。

**【函数声明】**

基本上每个函数声明处前都应当加上注释，描述函数的功能和用途。

只有在函数的功能简单而明显时才能省略这些注释（例如，简单的取值和设值函数）。

注释使用叙述式（"Opens the file"）而非指令式（"Open the file"）。

注释只是为了描述函数，而不是命令函数做什么。通常，注释不会描述函数如何工作。那是函数定义部分的事情。

函数声明处注释的内容：

-   函数的输入输出
-   对类成员函数而言：函数调用期间对象是否需要保持引用参数，是否会释放这些参数
-   函数是否分配了必须由调用者释放的空间
-   参数是否可以为空指针
-   是否存在函数使用上的性能隐患
-   如果函数是可重入的，其同步前提是什么

注释构造/析构函数时，切记读代码的人知道构造/析构函数的功能，所以 “销毁这一对象” 这样的注释是没有意义的。你应当注明的是注明构造函数对参数做了什么（例如，是否取得指针所有权）以及析构函数清理了什么。

如果都是些无关紧要的内容，直接省掉注释。析构函数前没有注释是很正常的。

```
// 按理说这里应该清理new出来的data，不过单例都析构了，内存不用管他，系统会处理

// 偷懒的作法，扔给操作系统

TargetingIndexMgr::~TargetingIndexMgr() {}
```

**【函数定义】**

如果函数的实现过程中用到了很巧妙的方式，那么在函数定义处应当加上解释性的注释。

例如，你所使用的编程技巧，实现的大致步骤，或解释如此实现的理由。

举个例子，你可以说明为什么函数的前半部分要加锁而后半部分不需要。

## 2.5 变量注释

**【建议】**

通常变量名本身足以很好说明变量用途。

某些情况下，也需要额外的注释说明。

每个类数据成员都应该用注释说明用途，如果有非变量的参数（例如特殊值、数据成员之间的关系、生命周期等）不能够用类型与变量名明确表达，则应当加上注释。

然而，如果变量类型与变量名已经足以描述一个变量，那么就不再需要加上注释。

特别地，如果变量可以接受 NULL 或 -1 等警戒值，须加以说明。

所有全局变量都要注释说明含义及用途，以及作为全局变量的原因。

## 2.6 实现注释

**【建议】**

对于代码中巧妙的，晦涩的，有趣的，重要的地方加以注释。

（个人建议）很多业务需求，加上需求wiki链接作为注释。

（个人建议）有些优化代码，加上注释解释下，一般这种代码都比较晦涩。

不要把注释写成代码翻译。

## 2.7 注释的标点和拼写

**【建议】**

注意标点、拼写和语法。

写的好的注释比差的要易读的多。

## 2.8 TODO 注释

**【规范】**

对那些临时的、短期的解决方案，或已经够好但仍不完美的代码使用 TODO 注释。

**【说明】**

TODO 注释要使用全大写的字符串 TODO，在随后的圆括号里写上你的邮箱前缀，然后冒号，空格，然后是与这一 TODO 相关的 issue。

主要目的是让添加注释的人（也是可以请求提供更多细节的人）可根据规范的 TODO 格式进行查找。

如果加 TODO 是为了在 “将来某一天做某事”，可以附上一个非常明确的时间 “Fix by November 2005”)，或者一个明确的事项 ("Remove this code when all clients can handle XML responses.")。

```
// TODO(duzhenlin): 通过FlowControlMsgMgr获取到最新的全量流控消息，然后构建流控倒排索引

// TODO(chenweiwei.tt): match特征倒排待实现
```

## 2.9 **弃用注释**

**【建议】**

通过弃用注释（DEPRECATED comments）以标记某接口已弃用。

**【说明】**

您可以在接口声明前写上包含全大写的 DEPRECATED 的注释，以标记某接口为弃用状态。

在 DEPRECATED 一词后, 在括号中留下您的邮箱前缀。

弃用注释应当包涵简短而清晰的指引，以帮助其他人修复其调用点。

在 C++ 中，你可以将一个弃用函数改造成一个内联函数，这一函数将调用新的接口。

仅仅标记接口为 DEPRECATED 并不会让大家不约而同地弃用，您还得亲自主动修正调用点（call sites）。

修正好的代码应该不会再涉及弃用接口点了，着实使用新接口。 如果您不知从何下手，可以找标记弃用注释的当事人一起商量。

（个人建议，删除废弃代码和写新代码一样重要。）

# 3、命名

最重要的一致性规则是命名管理。

命名的风格能让我们在不需要去查找类型声明的条件下快速地了解某个名字代表的含义：类型、变量、函数、常量、宏，等等。

甚至，我们大脑中的模式匹配引擎非常依赖这些命名规则。

命名规则具有一定随意性，但相比按个人喜好命名，一致性更重要，所以无论你认为它们是否重要，规则总归是规则。

## 3.1 通用命名规则

**【规范】**

函数命名、变量命名、文件命名要有描述性，少用缩写。

**【说明】**

尽可能使用描述性的命名，别心疼空间，毕竟相比之下让代码易于读者理解更重要。

不要用只有项目开发者能理解的缩写，也不要通过砍掉几个字母来缩写单词。

注意，一些特定的广为人知的缩写是允许的，例如用 i 表示迭代变量和用 T 表示模板参数。

## 3.2 文件命名

**【规范】**

文件名全部小写，可以包含下划线。

头文件后缀使用 .h（而不是 .hpp）。

实现文件后缀使用 .cpp（而不是 .cc）。

## 3.3 类型命名

**【规范】**

类型名称的每个单词首字母均大写，不包含下划线。

**【说明】**

所有类型命名，包括类、结构体、类型定义 (typedef)、枚举（不含枚举成员）、类型模板参数，均使用此规范。

```
// 类和结构体

class UrlTable { ...

class UrlTableTester { ...

struct UrlTableProperties { ...



// 类型定义

typedef hash_map<UrlTableProperties *, string> PropertiesMap;



// using 别名

using PropertiesMap = hash_map<UrlTableProperties *, string>;



// 枚举

enum UrlTableErrors { ...
```

## 3.4 变量命名

**【规范】**

变量（包括函数参数）和数据成员名一律小写，单词之间用下划线连接。

类的成员变量使用下划线结尾（使用下划线结尾而不是开头。通过此方式与普通变量区分开）。

结构体的成员变量可以不使用下划线结尾。

全局变量，建议使用 “g” 开头，大小写混合，示例参见下一条款 常量命名。

```
string table_name;  // 好 - 用下划线.

string tablename;   // 好 - 全小写.

string tableName;   // 不好 - 混合大小写



class TableInfo {

    ...

private:

    string table_name_;  // 好

    string tablename_;   // 好

    static Pool<TableInfo>* pool_;  // 好

};
```

## 3.5 常量命名

**【规范】**

声明为 constexpr 或 const 的变量，或在程序运行期间其值始终保持不变的，命名时以 “k” 开头，大小写混合。

全局变量，建议使用 “g” 开头，大小写混合。

```
extern const char kBuildType[] = "release";

extern const char kBuildTime[] = "Fri Mar 30 23:46:08 2018";

extern const char kBuilderName[] = "chenweiwei.tt";

extern const char kHostName[] = "n8-160-228";

extern const char kCompiler[] = "GCC 4.9.2-10)";
```

## 3.6 函数命名

**【规范】**

函数采用全小写单词加下划线分割的命名方式。

（google规范采用的是驼峰法，但是我们这里采用Linux的风格，以与现存c++代码风格保持一致。）

## 3.7 命名空间

**【规范】**

命名空间以小写字母命名。（单词之间可使用下划线分割）

最高级命名空间的名字取决于本模块名称。

要注意避免嵌套命名空间的名字之间和常见的顶级命名空间的名字之间发生冲突。

**【说明】**

顶级命名空间的名称应当是项目名或者是该命名空间中的代码所属的团队的名字。

命名空间中的代码，应当存放于和命名空间的名字匹配的文件夹或其子文件夹中。

要避免嵌套的命名空间与常见的顶级命名空间发生名称冲突。由于名称查找规则的存在，命名空间之间的冲突完全有可能导致编译失败。

尤其是不要创建嵌套的 std 命名空间。

建议使用更独特的项目标识符 (websearch::index、websearch::index_util 这种) 而非常见的极易发生冲突的名称 (比如 websearch::util)。

## 3.8 枚举命名

**【规范】**

枚举的命名应当和常量或宏一致：kEnumName （优先）或是 ENUM_NAME（需要与老代码保持一致时）。

```
enum UrlTableErrors {

    kOK = 0,

    kErrorOutOfMemory,

    kErrorMalformedInput,

};



enum AlternateUrlTableErrors {

    OK = 0,

    OUT_OF_MEMORY = 1,

    MALFORMED_INPUT = 2,

};
```

## 3.9 宏命名

**【规范】**

使用全大写加下划线的命名方式。

```
#define MKTASK(id, deadline) ((((int64_t)id) << 56) | ((int64_t)deadline))

#define ID(x) int(((x) >> 56))

#define DEADLINE(x) ((int64_t)((x) & ((((int64_t)1) << 56) - 1)))
```

除非有必要，否则不使用宏；使用宏时，宏命名应该加上有显著唯一性的模块名作为前缀。

# 4、头文件

通常每一个 .cpp 文件都有一个对应的 .h 文件。

也有一些常见例外，如单元测试代码和只包含 main() 函数的 .cpp 文件。

正确使用头文件可令代码在可读性、文件大小和性能上大为改观。

## 4.1 self-contained 头文件

**【规范】**

头文件要能够做到 self-contained。

也就是说，一个头文件要有 #define 保护，统统包含它所需要的其它头文件，也不要求定义任何特别 symbols。

头文件文件名后缀为 .h。

## 4.2 #define保护

**【建议】**

使用 #pragma once 来防止头文件被多重包含。

pragma once vs include guards 的讨论，参见[这里](https://stackoverflow.com/questions/1143936/pragma-once-vs-include-guards)。

```
#pragma once
```

## 4.3 前置声明

**【建议】**

尽可能避免使用前置声明，使用 #include 包含需要的头文件即可。

在一些基础库中，为了优化项目编译时间，可以小范围、适当的使用前置声明。

**【说明】**

前置声明（forward declaration）是类、函数和模板的纯粹声明，没伴随着其定义。

**【优点】**

-   前置声明能够节省编译时间，多余的 #include 会迫使编译器展开更多的文件，处理更多的输入。
-   前置声明能够节省不必要的重新编译的时间。 #include 使代码因为头文件中无关的改动而被重新编译多次。

**【缺点】**

-   前置声明隐藏了依赖关系，头文件改动时，用户的代码会跳过必要的重新编译过程。
-   前置声明可能会被库的后续更改所破坏。前置声明函数或模板有时会妨碍头文件开发者变动其 API，例如扩大形参类型，加个自带默认参数的模板形参等等。
-   前置声明来自命名空间 std:: 的 symbol 时，其行为未定义。
-   很难判断什么时候该用前置声明，什么时候该用 #include 。极端情况下，用前置声明代替 includes 甚至都会暗暗地改变代码的含义。

## 4.4 内联函数

**【建议】**

只有当函数只有 10 行甚至更少时才将其定义为内联函数。

**【说明】**

只要内联的函数体较小，内联该函数可以令目标代码更加高效。对于存取函数以及其它函数体比较短，性能关键的函数，鼓励使用内联。

另一方面，滥用内联将导致程序可能变得更慢。内联可能使目标代码量或增或减，这取决于内联函数的大小。内联非常短小的存取函数通常会减少代码大小，但内联一个相当大的函数将戏剧性的增加代码大小。现代处理器由于更好的利用了指令缓存，小巧的代码往往执行更快。

内联函数更多细节，详见 Effective C++ 条款 30。

## 4.5 #include

**【建议】**

项目内头文件应按照项目源代码目录树结构排列，避免使用 UNIX 特殊的快捷目录 . （当前目录）或 .. （上级目录）。

使用标准的头文件包含顺序可增强可读性，避免隐藏依赖：相关头文件、C 库、C++ 库、其他库的 .h、本项目内的 .h，中间用空行分割。建议的头文件包含顺序如下：

1.  当前codebase相关的include
1.  空行后系统相关的include
1.  每个部分之间的include，根据字母表顺序进行排序

~~按字母顺序分别对每种类型的头文件进行二次排序是不错的主意（go import 采用此方式）。~~

您所依赖的符号 (symbols) 被哪些头文件所定义，您就应该包含（include）哪些头文件，前置声明 (forward declarations) 情况除外。

比如您要用到 bar.h 中的某个符号，哪怕您所包含的 foo.h 已经包含了 bar.h，也照样得包含 bar.h，除非 foo.h 有明确说明它会自动向您提供 bar.h 中的 symbol。

不过，凡是 cpp 文件所对应的「相关头文件」已经包含的，就不用再重复包含进其 cpp 文件里面了，就像 foo.cpp 只包含 foo.h 就够了，不用再管后者所包含的其它内容。

举例来说，bytedance-awesome-project/src/foo/internal/fooserver.cpp 的包含次序如下：

```
#include "foo/public/fooserver.h" // cpp文件对应的相关头文件，优先位置



#include <sys/types.h>  // C 库头文件

#include <unistd.h>



#include <hash_map> // C++ 库头文件

#include <vector>



#include "base/basictypes.h"  //  本项目的其他头文件

#include "base/commandlineflags.h"

#include "foo/public/bar.h"
```

# 5、作用域

## 5.1 命名空间

命名空间将全局作用域细分为独立的，具名的作用域，可有效防止全局作用域的命名冲突。

**【规范】**

鼓励在 .cpp 文件内使用匿名命名空间或 static 声明。

使用具名的命名空间时，其名称可基于项目名。

禁止使用 [using-directive](http://en.cppreference.com/w/cpp/language/namespace#Using-directives)。

禁止使用内联命名空间（[inline namespace](http://en.cppreference.com/w/cpp/language/namespace#Inline_namespaces)）。

**【说明】**

实际上类已经提供了（可嵌套的）命名轴线，命名空间在这基础上又封装了一层。

举例来说，两个不同项目的全局作用域都有一个类 Foo，这样在编译或运行时造成冲突。如果每个项目将代码置于不同命名空间中，project1::Foo 和 project2::Foo 作为不同符号自然不会冲突。

内联命名空间很容易令人迷惑，因为其内部的成员不再受其声明所在命名空间的限制（导出到外层了）。内联命名空间只在大型版本控制里有用（用于保持跨版本的 ABI 兼容）。

**【使用策略】**

-   遵守 命名空间命名 中的规则。
-   在命名空间的最后注释出命名空间的名字。
-   用命名空间把**文件包含、gflags 的声明/定义以及类的前置声明以外**的整个源文件封装起来，以区别于其它命名空间。
-   不要在命名空间 std 内声明任何东西（应该没人会这么干吧）。
-   禁止使用 using directive 引入整个命名空间的所有标识符号。
-   注意 using-directive 和 using-declaration 的区别，后者可以合理使用。
-   禁止使用内联命名空间（应该没人会这么干吧）。

```
// .h 文件

namespace mynamespace {



// 所有声明都置于命名空间中

// 注意不要使用缩进

class MyClass {

public:

    ...

    void foo();

};



} // namespace mynamespace
```

```
// .cpp 文件

namespace mynamespace {



// 函数定义都置于命名空间中

void MyClass::foo() {

    ...

}



} // namespace mynamespace
```

## 5.2 匿名命名空间和静态变量

**【建议】**

推荐、鼓励在 .cpp 中对于不需要在其他地方引用的标识符使用内部链接性声明，但是不要在 .h 中使用。

匿名命名空间的声明和具名的格式相同，在最后注释上 namespace 。

**【说明】**

所有置于匿名命名空间的声明都具有内部链接性（C++ 风格），函数和变量可以经由声明为 static 拥有内部链接性（C 风格），这意味着你在这个文件中声明的这些标识符都不能在另一个文件中被访问。即使两个文件声明了完全一样名字的标识符，它们所指向的实体实际上是完全不同的。

```
namespace {

...

}  // namespace
```

## 5.3 非成员函数、静态成员函数和全局函数

**【建议】**

使用静态成员函数或命名空间内的非成员函数，尽量不要用裸的全局函数。

将一系列函数直接置于命名空间中，不要用类的静态方法模拟出命名空间的效果。

类的静态方法应当和类的实例或静态数据紧密相关。

**【说明】**

某些情况下，非成员函数和静态成员函数是非常有用的，将非成员函数放在命名空间内可避免污染全局作用域。

在另一些情况下，将非成员函数和静态成员函数作为新类的成员或许更有意义，特别是当它们需要访问外部资源或具有重要的依赖关系时。

如果是单纯为了封装若干不共享任何静态数据的函数，不要使用类，使用命名空间。

```
namespace adtargeting {

namespace rit_util { // 优先使用命名空间



bool is_feed(rit_t rit);

bool is_textlink(rit_t rit);



}  // namespace rit_util

}  // namespace adtargeting
```

```
namespace adtargeting {



class RitUtil { // 不要使用类

public:

    static bool is_feed(rit_t rit);

    static bool is_textlink(rit_t rit);

};



}  // namespace adtargeting
```

## 5.4 局部变量

**【规范】**

将函数变量尽可能置于最小作用域内，并在变量声明时进行初始化。

**【说明】**

C++ 允许在函数的任何位置声明变量（只要是先声明后使用）。我们提倡在尽可能小的作用域中声明变量，离第一次使用越近越好。

这使得代码浏览者更容易定位变量声明的位置，了解变量的类型和初始值。特别是，应使用初始化的方式替代声明再赋值。

```
int i;

i = f(); // 不好，初始化和声明分离



int j = g(); // 好
```

属于 if、while 和 for 语句的变量应当在这些语句中正常地声明，这样子这些变量的作用域就被限制在这些语句中了。

注意，如果变量是一个对象，每次进入作用域都要调用其构造函数，每次退出作用域都要调用其析构函数，在循环体内使用需注意性能问题。

## 5.5 静态和全局变量

**【规范】**

禁止定义静态储存周期非 POD 变量。（除非有明确的场景和理由。）

禁止使用含有副作用的函数初始化POD全局变量，因为多编译单元中的静态变量执行时的构造和析构顺序是不明确的，这将导致代码的不可移植，并可能存在潜在的bug。

**【说明】**

禁止使用类的 静态储存周期 变量。由于构造和析构函数调用顺序的不确定性，它们会导致难以发现的 bug 。

不过 constexpr 变量除外，毕竟它们又不涉及动态初始化或析构。

静态生存周期的对象，包括全局变量，静态变量，静态类成员变量和函数静态变量，都必须是原生数据类型 (POD : Plain Old Data)，即 int、char 和 float，以及 POD 类型的指针、数组和结构体。

静态变量的构造函数、析构函数和初始化的顺序在 C++ 中是只有部分明确的，甚至随着构建变化而变化，导致难以发现的 bug。所以除了禁用类类型的全局变量，我们也不允许用函数返回值来初始化 POD 变量，除非该函数（比如 getenv() 或 getpid() ）不涉及任何全局变量。函数作用域里的静态变量除外，毕竟它的初始化顺序是有明确定义的，而且只会在指令执行到它的声明那里才会发生。

同一个编译单元内是明确的，静态初始化优先于动态初始化，初始化顺序按照声明顺序进行，销毁则逆序。不同的编译单元之间初始化和销毁顺序属于未明确行为 (unspecified behaviour)。

同理，全局和静态变量在程序中断时会被析构，无论所谓中断是从 main() 返回还是对 exit() 的调用。析构顺序正好与构造函数调用的顺序相反。但既然构造顺序未定义，那么析构顺序当然也就不定了。比如，在程序结束时某静态变量已经被析构了，但代码还在跑——比如其它线程——并试图访问它且失败；再比如，一个静态 string 变量也许会在一个引用了前者的其它变量析构之前被析构掉。

综上所述，我们只允许 POD 类型的静态变量，即完全禁用 vector (使用 C 数组替代) 和 string (使用 const char [] )。

如果您确实需要一个 class 类型的静态或全局变量，可以考虑在 main() 函数或 pthread_once() 内初始化一个指针且永不回收。注意只能用 raw 指针，别用智能指针，毕竟后者的析构函数涉及到上文指出的不定顺序问题。

# 6、函数

## 6.1 参数顺序

**【建议】**

函数的参数顺序为输入参数在先，输出参数在后。

**【说明】**

C++ 中的函数参数或者是函数的输入，或者是函数的输出，或兼而有之（一般叫 input/output 参数）。输入参数通常是值参或 const 引用，输出参数或输入/输出参数则一般为非 const 引用。

在排列参数顺序时，将所有的输入参数置于输出参数之前。特别要注意，在加入新参数时不要因为它们是新参数就置于参数列表最后，而是仍然要按照前述的规则，即将新的输入参数也置于输出参数之前。

这并非一个硬性规定。输入/输出参数（通常是类或结构体）让这个问题变得复杂。

并且，有时候为了和其他函数保持一致，你可能不得不有所变通。

（例如，C++ 组件 api下面的 handler，就是输出参数在前，输入参数在后。）

特别强调一点，Google规范建议使用非 const 指针作为输出参数，这里我们建议优先使用非 const 引用作为输出参数。如果一个输出参数是可以省略的，那么可以使用指针，当指针为空时不输出该参数。

## 6.2 函数要简短

**【规范】**

编写简短、凝练的函数。

**【说明】**

长函数有时是合理的，因此我们并不硬性限制函数的长度。

但是如果函数超过 40 行，可以思索一下能不能在不影响程序结构的前提下对其进行分割。

即使一个长函数起初工作的非常好，一旦有人对其修改，有可能出现新的问题，甚至导致难以发现的 bug。

使函数尽量简短，以便于他人阅读和修改代码。

在处理代码时，你可能会发现复杂的长函数。不要害怕重构：如果证实这些代码使用起来很困难，或者你只需要使用其中的一小段代码，你可以考虑将其分割为更加简短并易于管理的若干函数。

## 6.3 引用参数

**【规范】**

按引用传递的输入参数必须是 const 引用。

输出参数使用非 const 引用，除非必须使用指针（比如参数可能为 NULL 指针）。

更多参数问题，详见下面条款 10.4 传参和返回值。

```
// 输入参数，使用 const 引用方式

bool build(const AudienceContext& audience_context, const ::adcommon::AbtestParams& abtest_params);
```

## 6.4 函数重载

**【建议】**

若要使用函数重载，则必须能让读者一看调用点就胸有成竹，而不用花心思猜测调用的重载函数到底是哪一种。

这一规则也适用于构造函数。

**【说明】**

通过重载参数不同的同名函数，可以令代码更加直观。

但是如果函数单靠不同的参数类型而重载，读者就得十分熟悉 C++ 五花八门的匹配规则，这会让人迷茫。

如果打算重载一个函数，可以试试改在函数名里加上参数信息。

例如，用 append_string() 和 append_int() 等，而不是一口气重载多个 append()。

一种常见的重载示例如下。

```
class MyClass {

public:

    void analyze(const string& text);

    void analyze(const char* text, size_t textlen);

};
```

## 6.5 缺省参数

**【建议】**

只允许在非虚函数中使用缺省参数，且必须保证缺省参数的值始终一致。

缺省参数与函数重载遵循同样的规则。一般情况下建议使用函数重载。

缺省参数会干扰函数指针，导致函数签名与调用点的签名不一致。而函数重载不会导致这样的问题。

## 6.6 函数返回类型后置

**【规范】**

只有在常规写法（返回类型前置）不便于书写或不便于阅读时使用返回类型后置语法。

**【说明】**

后置返回类型是显式地指定 Lambda 表达式 的返回值的唯一方式。某些情况下，编译器可以自动推导出 Lambda 表达式的返回类型，但并不是在所有的情况下都能实现。即使编译器能够自动推导，显式地指定返回类型也能让读者更明了。

有时在已经出现了的函数参数列表之后指定返回类型，能够让书写更简单，也更易读，尤其是在返回类型依赖于模板参数时。

```
template <class T, class U> auto add(T t, U u) -> decltype(t + u);  // 返回类型后置

template <class T, class U> decltype(declval<T&>() + declval<U&>()) add(T t, U u);  // 书写、阅读繁琐
```

在大部分情况下，返回类型置于函数名前。只有在必需的时候 (如 Lambda 表达式) 或者使用后置语法能够简化书写并且提高易读性的时候才使用新的返回类型后置语法。但是后一种情况一般来说是很少见的，大部分时候都出现在相当复杂的模板代码中，而多数情况下不鼓励写这样复杂的模板代码。（基础组件或基础数据结构里面可能出现这种代码，正常业务逻辑基本不会也不应该出现这种代码。）

# 7、类

类是 C++ 中代码的基本单元，也是 C++ 的精髓之一。本节列举了在写一个类时的主要注意事项。

更详细的内容，请参考 [Effective C++](https://item.jd.com/10393318.html)、[More Effective C++](https://item.jd.com/10484020.html)、[Effective Modern C++](https://item.jd.com/11789230.html)。

## 7.1 构造函数

**【规范】**

不要在构造函数中调用虚函数。

构造函数中可以进行各种初始化操作，但不要在无法报出错误时进行可能失败的初始化。

对于默认实现的构造函数（同理，赋值操作符和/或析构函数），鼓励使用 = default; 语法。

对于需要禁止的构造函数（同理，赋值操作符和/或析构函数），鼓励使用 = delete; 语法。

**【说明】**

构造函数中不要调用虚函数，详见 Effective C++ 条款 09。

## 7.2 隐式类型转换

**【规范】**

不要定义隐式类型转换。对于转换运算符和单参数构造函数, 使用 explicit 关键字。

**【说明】**

隐式类型转换允许一个某种类型（称作 *源类型）* 的对象被用于需要另一种类型（称作 *目的类型）* 的位置。

例如，将一个 int 类型的参数传递给需要 double 类型的函数。

除了语言所定义的隐式类型转换，用户还可以通过在类定义中添加合适的成员定义自己需要的转换。

explict 关键字可以用于构造函数或（在 C++11 引入）类型转换运算符，以保证只有当目的类型在调用点被显式写明时才能进行类型转换。

## 7.3 可拷贝类型和可移动类型

**【建议】**

如果你的类型需要，就让它们支持拷贝、移动。否则，就把隐式产生的拷贝和移动函数禁用。

**【说明】**

可拷贝类型允许对象在初始化时得到来自相同类型的另一对象的值，或在赋值时被赋予相同类型的另一对象的值，同时不改变源对象的值。对于用户定义的类型，拷贝操作一般通过拷贝构造函数与拷贝赋值操作符定义。

可移动类型允许对象在初始化时得到来自相同类型的临时对象的值，或在赋值时被赋予相同类型的临时对象的值（因此所有可拷贝对象也是可移动的）。

拷贝、移动构造函数在某些情况下会被编译器隐式调用。例如，通过传值的方式传递对象。

可移动及可拷贝类型的对象可以通过传值的方式进行传递或者返回，这使得 API 更简单、更安全也更通用。

与传指针和引用不同，这样的传递不会造成所有权、生命周期、可变性等方面的混乱，也就没必要在协议中予以明确。

这样的对象可以和需要传值操作的通用 API 一起使用，例如大多数容器。

如果让类型可拷贝，一定要同时给出拷贝构造函数和赋值操作的定义，反之亦然。

如果让类型可拷贝，同时移动操作的效率高于拷贝操作，那么就把移动的两个操作（移动构造函数和赋值操作）也给出定义。

如果类型不可拷贝，但是移动操作的正确性对用户显然可见，那么把这个类型设置为只可移动并定义移动的两个操作。

如果你的类不需要拷贝、移动操作，请显式地通过在 public 域中使用 = delete 或其他手段禁用。

```
 // MyClass is neither copyable nor movable.

MyClass(const MyClass & ) = delete;

MyClass & operator=(const MyClass & ) = delete;
```

## 7.4 结构体还是类

**【规范】**

仅当只有数据成员时可以使用 struct，其他情况一概使用 class。

## 7.5 继承与多重继承

**【规范】**

继承是面向对象设计的很大一部分内容，也有专门的书深入分析继承的方方面面。这里直接简要写出一些条款供参考。

-   确定你的 public 继承塑模出 is-a 关系，详见 Effective C++ 条款 32
-   避免遮掩继承而来的名称，详见 Effective C++ 条款 33
-   区分接口继承和实现继承，详见 Effective C++ 条款 34
-   考虑 virtual 函数以外的其他选择，详见 Effective C++ 条款 35
-   绝不重新定义继承而来的 non-virtual 函数，详见 Effective C++ 条款 36
-   绝不重新定义继承而来的缺省参数值，详见 Effective C++ 条款 37
-   通过复合塑模出 has-a，详见 Effective C++ 条款 38
-   明智而审慎地使用 private 继承，详见 Effective C++ 条款 39
-   明智而审慎的使用多重继承，详见 Effective C++ 条款 40

## 7.6 运算符重载

**【规范】**

除少数特殊场景外，请不要重载运算符。

不要创建用户定义字面量。

只有在意义明显，不会出现奇怪的行为并且与对应的内建运算符的行为一致时才定义重载运算符。

**【说明】**

C++ 允许通过 operator 关键字重载运算符，还允许使用 operator"" 定义新的字面运算符，并且可以定义类型转换函数，如 operator bool()。

重载运算符可以让代码更简洁易懂，也使得用户定义的类型和内建类型拥有相似的行为。重载运算符对于某些运算来说是符合符合语言习惯的名称，遵循这些语言约定可以让用户定义的类型更易读，也能更好地和需要这些重载运算符的函数库进行交互操作。

但是，运算符重载也存在很多问题：

-   要提供正确、一致、不出现异常行为的操作符运算需要花费不少精力。如果达不到这些要求的话，会导致令人迷惑且难调试的 Bug。
-   过度使用运算符会带来难以理解的代码，尤其是在重载的操作符的语义与通常的约定不符合时。
-   函数重载有多少弊端，运算符重载就至少有多少。
-   运算符重载会混淆视听，让你误以为一些耗时的操作和操作内建类型一样轻巧。
-   对重载运算符的调用点的查找需要的可就不仅仅是像 grep 那样的程序了，这时需要能够理解 C++ 语法的搜索工具。
-   如果重载运算符的参数写错, 此时得到的可能是一个完全不同的重载而非编译错误. 例如，foo < bar 执行的是一个行为，而 &foo < & bar 执行的就是完全不同的另一个行为了。
-   重载某些运算符本身就是有害的。例如，重载一元运算符 & 会导致同样的代码有完全不同的含义。
-   运算符从通常定义在类的外部，所以对于同一运算，可能出现不同的文件引入了不同的定义的风险。如果两种定义都链接到同一二进制文件，就会导致未定义的行为，有可能表现为难以发现的运行时错误。
-   用户定义字面量所创建的语义形式对于某些有经验的 C++ 程序员来说都是很陌生的。

## 7.7 存取控制

**【规范】**

将所有数据成员声明为 private。

static const 类型成员可以酌情处理。

特殊用途的类，比如 Google Test 中的测试固件类中的数据成员为 protected。

## 7.8 声明顺序

**【规范】**

将相似的声明放一起。

将 public 部分放在最前。

**【说明】**

类定义一般是以 public 开始，后跟 protected，最后是 private。

在各个部分中，将类似的声明放在一起。

不要将大段的函数定义内联在类定义中。通常，只有那些普通的，或性能关键且短小的函数可以内联在类定义中。

# 8、其他 C++ 特性

## 8.1 C++11

**【规范】**

我们使用 [C++11](https://en.wikipedia.org/wiki/C++11) 开发。

**【说明】**

目前，blade 默认配置了-std=c++14，但截止本文撰写时，我们使用的编译器版本是4.9.2，对C++14的支持并不完善。如非必要，应尽量避免使用C++14的特性。一些基础库，如 folly 使用了C++14，相关代码可参照使用。

## 8.2 右值引用

**【建议】**

只在定义移动构造函数与移动赋值操作时使用右值引用类型。

只在典型的“完美转发”场景使用 std::forward。

**【说明】**

右值引用是一种只能绑定到临时对象的引用的一种，其语法与传统的引用语法相似。

例如，void f(string&& s); 声明了一个参数是一个字符串的右值引用的函数。

右值引用有很多优点。

用于定义移动构造函数（使用类的右值引用进行构造的函数）使得移动一个值而非拷贝之成为可能。

例如，如果 v1 是一个 vector<string>，则 auto v2(std::move(v1)) 将很可能不再进行大量的数据复制而只是简单地进行指针操作, 在某些情况下这将带来大幅度的性能提升.

右值引用使得编写通用的函数封装来转发其参数到另外一个函数成为可能，无论其参数是否是临时对象都能正常工作。

右值引用能实现可移动但不可拷贝的类型，这一特性对那些在拷贝方面没有实际需求, 但有时又需要将它们作为函数参数传递或塞入容器的类型很有用。

但是右值引用是一个相对比较新的特性（由 C++11 引入），尚未被广泛理解。

类似引用折叠、移动构造函数的自动推导这样的规则都是很复杂的。

关于完美转发，参考[这里](https://www.justsoftwaresolutions.co.uk/cplusplus/rvalue_references_and_perfect_forwarding.html)。一般只有在写基础库时才会使用。

## 8.3 变长数组

**【规范】**

我们不使用变长数组和 alloca( )。

变长数组和 alloca( ) 不是标准C++ 的组成部分。alloca 可能存在的问题[参见这里](https://stackoverflow.com/questions/1018853/why-is-the-use-of-alloca-not-considered-good-practice)。

## 8.4 友元

**【规范】**

我们可以合理的使用友元类和友元函数。

**【说明】**

通常友元应该定义在同一文件内，避免代码读者跑到其它文件查找使用该私有成员的类。

经常用到友元的一个地方是将 FooBuilder 声明为 Foo 的友元, 以便 FooBuilder 正确构造 Foo 的内部状态，而无需将该状态暴露出来。

某些情况下，将一个单元测试类声明成待测类的友元会很方便。

友元扩大了（但没有打破）类的封装边界。某些情况下，相对于将类成员声明为 public，使用友元是更好的选择，尤其是如果你只允许另一个类访问该类的私有成员时。当然，大多数类都只应该通过其提供的公有成员进行互操作。

## 8.5 异常

**【建议】**

如果你很懂异常，可以使用异常。

否则，除了兼容第三方库或现存代码（比如 thrift 或 json 解析等），请勿使用异常。

（个人推崇 Fail Early Fail Fast。）

在我们的实现中，频繁抛出异常会影响性能（部分是由于libunwind库）。频繁的定义是大于常数倍 qps。

**【说明】**

C++ 是否要使用异常，是一个有很多争议的话题。Google C++ 编程规范里面明确写出，我们不使用异常。

C++ 异常，可参考 Effective C++ 条款 08、条款 25、条款 29 等。

## 8.6 运行时类型

**【建议】**

不要使用 RTTI。

**【说明】**

RTTI 允许程序员在运行时识别 C++ 类对象的类型。它通过使用 typeid 或者 dynamic_cast 完成。

RTTI 在某些场景下有其优点。

RTTI 的标准替代（下面将描述）需要对有问题的类层级进行修改或重构。有时这样的修改并不是我们所想要的，甚至是不可取的，尤其是在一个已经广泛使用的或者成熟的代码中。

RTTI 在某些单元测试中非常有用。比如进行工厂类测试时，用来验证一个新建对象是否为期望的动态类型。RTTI 对于管理对象和派生对象的关系也很有用。

但是 RTTI 也有很多缺点。

在运行时判断类型通常意味着设计问题。如果你需要在运行期间确定一个对象的类型，这通常说明你需要考虑重新设计你的类。

随意地使用 RTTI 会使代码难以维护。它使得基于类型的判断或者 switch 语句散布在代码各处。如果以后要进行修改，就必须检查它们。

**【结论】**

RTTI 有合理的用途但是容易被滥用，因此在使用时请务必注意。

在单元测试中可以使用 RTTI，但是在其他代码中请尽量避免。尤其是在新代码中，使用 RTTI 前务必三思。

如果你的代码需要根据不同的对象类型执行不同的行为的话，请考虑用以下的两种替代方案之一查询类型：

-   虚函数可以根据子类类型的不同而执行不同代码，这是把工作交给了对象本身去处理。
-   如果这一工作需要在对象之外完成，可以考虑使用双重分发的方案，例如使用访问者设计模式。这就能够在对象之外进行类型判断。

如果程序能够保证给定的基类实例实际上都是某个派生类的实例，那么就可以自由使用 dynamic_cast。在这种情况下，使用 dynamic_cast 也是一种替代方案。

基于类型的判断是一个很强的暗示，它说明你的代码已经偏离正轨了。不要像下面这样：

```
if (typeid( * data) == typeid(D1)) {

    ...

} else if (typeid( * data) == typeid(D2)) {

    ...

} else if (typeid( * data) == typeid(D3)) {

     ...

}
```

一旦在类层级中加入新的子类，像这样的代码往往会崩溃。而且，一旦某个子类的属性改变了，你很难找到并修改所有受影响的代码块。

不要去手工实现一个类似 RTTI 的方案。反对 RTTI 的理由同样适用于这些方案，比如带类型标签的类继承体系。

而且，这些方案会掩盖你的真实意图。

## 8.7 类型转换

**【规范】**

使用 C++ 的类型转换，不要使用 C 风格的类型转换。

**【说明】**

C++ 提供了四种类型转换操作符，static_cast、const_cast、reinterpret_cast、dynamic_cast。

C++ 类型转换，详见 Effective C++ 条款 27。

## 8.8 流

**【建议】**

只在记录日志时使用流（这条建议来自 Google 编程规范）。

使用流或者不使用流，都是有利有弊的。没有最好，只有合适。所以本条款为建议。

## 8.9 前置自增和自减

**【规范】**

对于迭代器和其他模板对象使用前缀形式 ++i 的自增自减运算符。

**【说明】**

~~不考虑返回值的话, 前置自增（ ++i ）通常要比后置自增（ i++ ）更高效，因为后置自增自减需要对表达式的值进行一次拷贝~~。（此条可能已过时。）

如果 i 是迭代器或其他非数值类型，拷贝的代价是比较大的。

## 8.10 const和constexpr

**【建议】**

建议在任何可能的情况下都要使用 const。

尽可能使用 const，详见 Effective C++ 条款 03。

我们尚未大范围使用 constexpr，除非有必要，一般不使用 constexpr。

**【说明】**

constexpr 和 const 的区别，[参见这里](https://stackoverflow.com/questions/14116003/difference-between-constexpr-and-const)。

constexpr 的 reference，[参见这里](http://en.cppreference.com/w/cpp/language/constexpr)。

constexpr 的说明，[参见这里](https://wizardforcel.gitbooks.io/cpp-11-faq/content/17.html)。

constexpr 的规则在 C++14 有较多修改，这意味着使用 constexpr 对编译器可能有依赖。

（补充一下，搜了下基础库 cpputil，貌似没有使用过 constexpr。）

## 8.11 整型

**【建议】**

建议使用确定长度的整型。对于需要比较大小的整数优先用 signed 类型。

如果一个非负的整型数只用来做 id，但从不用来比较大小，或者做数值运算（位运算除外），则优先用unsigned。

从标准容器中临时获得大小时，可以使用 size_t，但不要将 size_t 用于存储或接口。

**【说明】**

C++ 没有指定整形的大小（C 也没有指定）。通常，人们假定 short 是 16 位，int 是 32 位，long 是 32/64 位，long long 是 64 位。

<stdint.h> 中定义了 int8_t、 int16_t、int32_t、int64_t 等确定长度的整型。在需要确保整型大小时，尽量使用它们。相应的，无符号类型为 uint8_t、uint16_t、uint32_t、uint64_t 等。

对于临时使用的整数，如果已知整数不会太大，我们可以使用 int，如循环计数。

如果变量可能不小于2G那么大，（根据墨菲定律，则一定会溢出），就使用 int64_t 确保类型够大。

## 8.12 预处理宏

**【建议】**

使用宏时要非常谨慎，尽量以内联函数，枚举和常量代替。

**【说明】**

宏意味着你和编译器看到的代码是不同的。这可能会导致异常行为，尤其因为宏具有全局作用域。

在C++ 中，宏不像在 C 中那么必不可少。以往用宏展开性能关键的代码，现在可以用内联函数替代。用宏表示常量可被 const 代替。用宏缩写长变量名可被引用代替。

宏可以做一些其他技术无法实现的事情，在一些代码库（尤其是底层库中）可以看到宏的某些特性（如用 # 字符串化，用 ## 连接等）。

但在使用前，仔细考虑一下能不能不使用宏达到同样的目的。

（个人建议，宏在某些场景下还是很有用的，本条款关键点是，请谨慎使用宏，谨防带来问题。）

下面给出的用法模式可以避免使用宏带来的问题。如果你要宏，尽可能遵守：

-   不要在 .h 文件中定义宏
-   在马上要使用时才进行 #define，使用后要立即 #undef
-   不要只是对已经存在的宏使用#undef，选择一个不会冲突的名称
-   不要试图使用展开后会导致 C++ 构造不稳定的宏，不然也至少要附上文档说明其行为
-   不要用 ## 处理函数、类和变量的名字

## 8.13 0、nullptr、NULL

**【规范】**

整数用 0，实数用 0.0，指针用 nullptr 或 NULL。

整数用 0，实数用 0.0，这一点是毫无争议的。

对于指针，到底是用 0、NULL 还是 nullptr 呢？C++11 项目用 nullptr；C++03 项目则用 NULL，毕竟它看起来像指针。

实际上，一些 C++ 编译器对 NULL 的定义比较特殊，可以输出有用的警告，特别是 sizeof(NULL) 就和 sizeof(0) 不一样。

## 8.14 sizeof

**【建议】**

尽可能使用 sizeof(varname) 代替 sizeof(type)。

使用 sizeof(varname) 是因为当代码中变量类型改变时会自动更新。

当然，有些场景是处理不涉及变量的操作，这时用 sizeof(type) 更合适。

## 8.15 auto

**【规范】**

在不影响可读性的前提下，可以用 auto 绕过繁琐的类型名。

不要在局部变量之外的地方使用 auto。

除非您需要复制，否则请使用auto&

**【说明】**

C++11 中，若变量被声明成 auto，那它的类型就会被自动匹配成初始化表达式的类型。您可以用 auto 来复制初始化或绑定引用。

应当注意，auto 的类型推导规则和模板参数是一致的。

当表达式是一个比较小的对象、或支持移动构造的右值对象时，应该使用值语义。典型的，如迭代器、或构造器的返回类型。

```
std::stringstream ss;

ss << "abc";

auto s = ss.str();     // move from an rvalue

auto iter = s.begin(); // copy from an rvalue

auto ch = *iter;       // copy from a small lvalue
```

当表达式返回一个左值对象时，使用 auto& 可推导出左值引用类型。典型的如容器成员。

```
std::vector<std::string> v = {"aa", "bb", "cc"};

for (auto iter = v.begin(); iter != v.end(); ++iter) {

    auto& s = *iter;

    // ...

}



// another equivalent form below

for (auto& s: v) {

    // ...

}
```

如果你试图从一个右值推导一个左值引用类型，编译器会报错。

不要使用 auto&&，除非你知道自己在做什么！

## 8.16 列表初始化

**【建议】**

可以使用列表初始化。

**【说明】**

在 C++03 里，聚合类型（aggregate types）就已经可以被列表初始化了，比如数组和不自带构造函数的结构体：

```
struct Point {

    int x;

    int y;

};



Point p = {1, 2};
```

C++11 中，该特性得到进一步的推广，任何对象类型都可以被列表初始化。示例如下：

```
// Vector 接收了一个初始化列表。

vector<string> v{"foo", "bar"};



// 不考虑细节上的微妙差别，大致上相同。

// 您可以任选其一。

vector<string> v = {"foo", "bar"};



// 可以配合 new 一起用。这里可以使用 auto，因为后面有类型。

auto p = new vector<string>{"foo", "bar"};



// 注意，千万别直接列表初始化 auto 变量，对比下面两个语句：

auto d = {1.23};  // 不可以

auto d = double{1.23}; // 可以



// map 接收了一些 pair, 列表初始化大显神威。

map<int, string> m = {{1, "one"}, {2, "2"}};



// 初始化列表也可以用在返回类型上的隐式转换。

vector<int> test_function() { return {1, 2, 3}; }



// 初始化列表可迭代。

for (int i : {-1, -2, -3}) {}



// 在函数调用里用列表初始化。

void TestFunction2(vector<int> v) {}

TestFunction2({1, 2, 3});
```

## 8.17 Lambda 表达式

**【规范】**

适当的使用 lambda 表达式。

不要使用默认 lambda 捕获，所有捕获都要显式写出来。

lambda 参数列表中定义的变量名不要和外层空间中的变量名冲突。

**【说明】**

Lambda 表达式是创建匿名函数对象的一种简易途径，常用于把函数当参数传。

C++11 首次提出 Lambdas，还提供了一系列处理函数对象的工具，比如多态包装器（polymorphic wrapper）std::function。

C++14 允许在捕获列表中定义变量。除非十分确定项目本身已开启了 C++14 支持，否则不要使用这类语法。对于已开启 C++14 的项目，在捕获列表中定义变量应当仅限于将具名对象以 move 的方式传入捕获列表。一定要避免改变 lambda 外层空间和捕获列表中同一变量名指代的对象。

```
void foo() {

    std::string s = "aaa";

    // move s to cmp

    auto cmp = [s = std::move(s)] (const std::string& z) -> bool {

        return s == z;

    }

    cmp("bbb");    // OK, "bbb" == "aaa"

}



// BAD!!!

int x = 4;

auto y = [&r = x, x = x + 1]()->int {

    r += 2;

    return x * x;

}(); // updates ::x to 6 and initializes y to 25. 
```

注：对于依赖 folly 库异步编程的场景，可能会较多的用到这类 C++14 风格的 lambda。将对象 move 给 capture list 的需求是存在的，不能简单禁绝，但一定不可滥用。

## 8.18 模板

**【建议】**

不要使用复杂的模板编程。

**【优点】**

模板编程能够实现非常灵活的类型安全的接口和极好的性能，一些常见的工具比如 Google Test、std::tuple、std::function等，这些工具如果没有模板是实现不了的。

**【缺点】**

模板编程所使用的技巧对于使用 C++ 不是很熟练的人是比较晦涩难懂的，在复杂的地方使用模板的代码让人更不容易读懂，并且 debug 和维护都很麻烦。

模板编程经常会导致编译出错的信息非常不友好：在代码出错的时候，即使这个接口非常的简单，模板内部复杂的实现细节也会在出错信息显示，导致这个编译出错信息看起来非常难以理解（遇到过STL容器报错的都懂，那错误刷屏。。。）

## 8.19 线程

**【规范】**

使用 std::mutex 实现互斥锁。

使用 std::condition_variable 实现条件变量。

使用 std::thread 封装线程。

使用 thread_local 关键字实现线程存储周期变量（请勿滥用）。

使用 std::future/std::promise 或 folly::future/promise 实现异步变量传递。

**【建议】**

读写锁目前（C++11）尚未有标准支持，可以选用 boost::shared_mutex，std::shared_timed_mutex（C++14），或用pthread（有可能性能更好）。

# 9、一些工程问题

## 9.1 Makefile 还是 BUILD

**【规范】**

使用 BUILD 文件，而不是Makefile。

这里有一篇很赞的 [Blade使用手册(最新更新2020-12-24）](https://bytedance.feishu.cn/wiki/wikcnqnojHWxHyXMTLUVHwZzTug) 。

除非历史项目，BUILD 文件中应设置"-Werror"，将所有warning视为error。

默认的 BLADE_ROOT 配置了 -std=c++14 标准、-Wall、-Wextra 警告选项，以及忽略了一些常见可忽略的 warning。不要修改默认的 BLADE_ROOT 配置。

## 9.2 静态编译还是动态编译

**【规范】**

使用 blade 编译，对公司内部的代码库使用源码依赖。默认情况下 library 编译为静态库。

只对第三方库和保密库使用二进制依赖。

二进制依赖的库需要包含动态库，可选包含静态库。

**【说明】**

使用 blade，内部的代码库之间的依赖大多使用源码依赖，而不是二进制库，避免了大多数二进制兼容性问题。

第三方库依赖，大部分情况下应使用动态库。但对于一些间接依赖，使用静态库有利于缩小发布包的体积（因为发布

包会包含所有依赖库，而对于依赖的静态库则只依赖库中被使用到的符号）。

一些情况下，项目的最终产出是动态库（以 cc_plugin 形式，或 --generate-dynamic 参数指定），这样会要求其依赖也能够被编译成动态库。第三方库需要提供动态库版本才能支持这类需求。

保密库维护成本较高，如无必要一般不使用。

## 9.3 编译器

**【建议】**

我们目前推荐使用 gcc 8.3.0 和clang11 编译器。如果希望使用其他编译器需要自担风险。

# 10、代码设计和实现

## 10.1 智能指针

**【规范】**

鼓励正确使用 std::shared_ptr、std::unique_ptr，除非有必要，一般不使用裸指针 T* 。禁止使用 std::auto_ptr。

除非涉及旧代码的兼容问题，一般不用 boost::shared_ptr、boost::scoped_ptr、boost::unique_ptr（例如，apache thrift 部分接口仍然需要boost::shared_ptr）。

**【建议】**

对于不需要共享使用的对象，使用 std::unique_ptr有更好的编译器检查和运行时性能。

## 10.2 线程安全性

**【建议】**

类接口设计，除非有注释说明，否则遵循以下规则：

-   类的 const 成员函数，可以对一个对象，在多个线程中并发调用；
-   类的非 const 成员函数，可以对不同对象，在多个线程中并发调用，但除非有特殊说明，否则不能对同一个对象并发调用；
-   类的 static 成员函数，可以在多个线程中并发调用。

## 10.3 容器

**【建议】**

使用std::unordered_map时，应提前计算好大小，预先reserve。设置max_load_factor可以减少哈希冲突（一般设置0.5-0.75之间，默认1.0）。

使用std::unordered_map时，如果value是大对象，可以使用智能指针代替，可以节省buckets占用的内存空间。

使用std::vector时，如果一个对象构造完毕，需要传入vector，使用push_back配合std::move即可，不要滥用emplace_back。

```
std::string s = "abc";

std::vector<std::string> vec;

vec.push_back(s);            // copied

vec.push_back(std::move(s)); // good, moved in

vec.emplace_back("abc");     // good, constructed in place

vec.emplace_back(s);         // copied

vec.emplace_back(10, 'a');   // constructed as "aaaaaaaaaa"
```

## 10.4 传参和返回值

**【建议】**

向函数传入参数、或从函数返回的对象，如果对象的体积较小（例如，4 word 以内，仍需进一步测试），建议直接传值。

向函数传入参数是较大的对象时：

-   如果接收方会保存这个对象，且对象定义了移动构造函数（调用构造函数时）或移动赋值操作符（调用其他函数时），则优先使用传值语法；
-   如果对象不支持移动构造或拷贝，使用常量引用语法传入；
-   如果函数只是“使用”传入的参数，而并不保存，使用常量引用语法传入。

从函数返回较大的对象时：

-   如果是返回一个临时构造的对象，或“取出”一个对象，且对象定义了移动构造函数，则优先使用按值返回语法，或按需求返回智能指针；
-   如果是访问一个被储存的对象，但对象并未从原来的存储位置移除，可以按需求返回常量引用、智能指针等；
-   如果要返回的类不支持移动构造，可以用传入引用或指针的方式返回；使用引用或指针取决于该返回值是否可以省略（为返回值传入指针时，如果传入空指针，应当忽略返回值）；
-   如果要返回多个值，次要的返回值也应使用传入引用或指针的方式返回。

```
struc Foo {

    Foo(std::vector<int> v) : v_(std::move(v)) { // move construction

    }



    void set_v(std::vector<int> v) {

        v_ = std::move(v);                       // move assignment

    }



    // read "anther" but does not store

    std::vector<int> intersect(const std::vector<int>& another) {

        std::vector<int> ret;

        // intersetct v_ and another

        return ret; // return by value, will apply move constructor

    }



    std::vector<int> v_;

};



Foo f ({1, 2, 3});       // move the temporary vector to constructor

f.set_v({4, 5, 6});      // move the temporary vector to function

f.set_v(f.intersect({3, 4, 5}));     // move the returned temporary
```

**【讨论】**

如果函数内部会保存传入的参数，那么以 const 引用形式传入参数，会不可避免的产生一次拷贝。而以往以 swap 等方式消除拷贝，则必须传入非 const 引用，因而不能接收右值。使用值的形式传入，配合移动构造函数，可以在一些情况下完全消除拷贝。

对于函数栈上的非入参对象（即函数内定义的局部变量），按名字返回时（return 变量名，不包含表达式），会首先适用移动构造函数，如果没有移动构造函数也会适用拷贝构造函数，同时适用 NRVO（一个常见的无效动作是 return std::move(ret)，这样是移动语义，但会造成 NRVO失效）。另外，如果 return 一个右值表达式，按值返回也适用移动构造函数。

在通过移动构造函数、移动赋值操作符解决了复制对象的性能问题的情况下，使用传值语义会使得代码更加易读，能够

同时兼容左值、右值。

## 10.5 Boost 库

**【建议】**

使用 Boost 中被认可的库。（待议，哪部分被认可呢？）

如果 Boost 中的库在标准库中已有可替代版本，则优先使用标准库（除非向前兼容）。

**【说明】**

目前我们的 Boost 库版本较旧，一些功能和 C++11 的标准库有重复。

## 10.6 Folly 库

**【建议】**

如有必要使用，尽量约束 folly 库的使用范围。

**【说明】**

folly 库（以及 wangle）是 facebook 开发的一套基础库，仍然在快速迭代过程中，接口随时会发生变化。目前部分工程使用了 fbthrift，依赖 folly 和 wangle 等基础库。涉及到与 fbthrift 直接交互的代码，尤其是异步代码，可能会用到 folly。但考虑到未来升级的可能性，仍然建议尽量约束 folly 库的使用范围，避免大面积依赖。

# 11、工具支持

## 11.1 clang-format

[推荐] 80列宽、2空格缩进配置：

```
IndentWidth: 2

TabWidth: 2



Language: Cpp

Standard: Cpp11

BasedOnStyle: Google

# indent

AccessModifierOffset: -1

ContinuationIndentWidth: 4

# align

BreakBeforeTernaryOperators: true

BreakBeforeBinaryOperators: false

ColumnLimit: 80

# constructor

BreakConstructorInitializersBeforeComma: false

ConstructorInitializerIndentWidth: 4

ConstructorInitializerAllOnOneLineOrOnePerLine: true

# short block

AllowShortBlocksOnASingleLine: false

AllowShortFunctionsOnASingleLine: false

AllowShortIfStatementsOnASingleLine: false

AllowShortLoopsOnASingleLine: false

# other

AlwaysBreakTemplateDeclarations: true

DerivePointerAlignment: false

PointerAlignment: Left



# clang-format 3.9+

SortIncludes: false

BreakStringLiterals: false

ReflowComments: true
```

[备选] 120列宽、4空格缩进配置：

```
IndentWidth: 4

TabWidth: 4



Language: Cpp

Standard: Cpp11

BasedOnStyle: Google

# indent

AccessModifierOffset: -4

ContinuationIndentWidth: 8

# align

BreakBeforeTernaryOperators: true

BreakBeforeBinaryOperators: false

ColumnLimit: 120

# constructor

BreakConstructorInitializersBeforeComma: false

ConstructorInitializerIndentWidth: 8

ConstructorInitializerAllOnOneLineOrOnePerLine: true

# short block

AllowShortBlocksOnASingleLine: false

AllowShortFunctionsOnASingleLine: false

AllowShortIfStatementsOnASingleLine: false

AllowShortLoopsOnASingleLine: false

Cpp11BracedListStyle: true

# other

AlwaysBreakTemplateDeclarations: true

DerivePointerAlignment: false

PointerAlignment: Left



# clang-format 3.9+

SortIncludes: false

BreakStringLiterals: false

ReflowComments: true
```

## 11.2 vimrc

注：使用plug，安装rhysd/vim-clang-format插件

```
"""""""""""""""""""""""""""""""

" clang-format

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Plug 'rhysd/vim-clang-format'

let g:clang_format#command='/usr/bin/clang-format-3.5'

let g:clang_format#detect_style_file = 1

let g:clang_format#auto_format = 0

let g:clang_format#auto_format_on_insert_leave = 0



" map to <Leader>cf in C++ code

autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>

autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
```