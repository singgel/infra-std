# 一、注释风格

## (一) 能被 Doxygen 识别写进文档的注释

## ```
/**   * 第一种：多行注释   * 会被 Doxygen 识别写进文档   * JavaDoc 风格   */  int apple = 1;    /// 第二种：会被 Doxygen 识别写进文档的单行行首插入注释，Cpp 风格  int num = 4;    int girl = 6; ///< 第三种，会被 Doxygen 识别写进文档的单行行末追加注释，Cpp 风格 
```(二) 不能被 Doxygen 识别写进文档的注释

```
// 第四种：

// 不会被 Doxygen 识别写进文档的常规多行注释

int one = 1;



// 第五种，不会被 Doxygen 识别写进文档的常规单行注释

int three = 4;
```

***

# 二、文件头注释规范

文件头的注释内容应被 Doxygen 识别写进文档，采用多行注释。

```
/**

 * @file 文件名

 * @author 你的名字 (你的邮箱)

 * @brief 文件内容简介

 * @version 版本号

 * @date 日期

 * @copyright 版权声明，比如：Copyright (c) 2019

 */
```

***

# 三、类、结构体、枚举注释规范

类、结构体、枚举的注释内容应被 Doxygen 识别写进文档，采用多行注释或单行行首插入注释。

```
/**

 * @brief 类内容简述，行首的“@brief” 为隐含关键字，单行注释时可以省略

 */

class Student

{

    // ...

};



/**

 * @brief 模板类内容简述

 * @tparam T 模板类型参数描述

 */

template <typename T>

class Widgt

{

    // ...

};



/**

 * @brief 结构体内容简述，如果注释有多行，须在每行末尾加上“\”和“n”\n

 * 简述的第二行

 */

struct TreeNode

{

    // ...

};



/// 枚举内容简述，只有一行可以省略“@brief”，Doxygen 依旧能识别这是简介的内容

enum Week

{

    // ...

};
```

***

# 四、函数注释规范

函数的注释内容应被 Doxygen 识别写进文档，采用多行注释。

```
/**

 * @brief 模板函数功能简述

 * @tparam T 模板参数描述

 * @param num 形参描述

 * @return T 返回值描述

 */

template <typename T>

T Foo(T num)

{

    // ...

}



class Student

{

public:

    /**

     * @brief 函数内容简述

     * @param age 形参说明

     * @param num 形参说明

     */

    Student(int age, int num)

        : mAge(age)

        , mNum(num)

    {

    }



    /**

     * @brief 函数内容简述

     * @return size_t

     */

    size_t getAge() { return mAge; }



    /**

     * @brief 函数内容简述

     * @return size_t

     * @since 可选字段，表明代码段或文件初始添加的版本号

     */

    size_t getNum() { return mNum; }



    /**

     * @brief 函数内容简述，如需对对返回值进行说明可选用 @retval 关键字，示例如下

     * @return bool

     * @retval true 返回 true 的情况描述

     * @retval false 返回 false 的情况描述

     */

    bool isAdult()

    {

        return mAge >= 18;

    }



private:

    size_t mAge;

    size_t mNum;

};
```

***

# 五、公有变量、枚举常量、宏定义、类型定义（typedef、using）注释规范

公有变量、枚举常量、宏定义、类型定义的注释内容应被 Doxygen 识别写进文档，采用单行行首插入注释或单行行末追加注释都行。

```
class Student

{

public:

    /// 对公有变量 mkTotal 的简述，mAge 和 mNum 不属于公有变量

    static const size_t mkTotal = 100;

    // ...



private:

    size_t mAge;

    size_t mNum;

};



struct Node

{

    /// 第一种方案，在代码段上方用“///”开头，如果注释有多行，须在每行末尾加上“\”和“n”\n

    /// 这是第二行

    int mVal;

    

    std::vector<Node *> mChildren; ///< 行末追加的单行注释用“///<”开头

};



enum Gender

{

    /// 对枚举常量的简述，注释方法一

    MALE,

    FEMALE ///< 对枚举常量的简述，注释方法二

};



/// 对宏定义 MAX 的简述，跟上面一样有两种注释方法

#define MAX 10000



/// 对类型定义 SizeType 的简述，跟上面一样有两种注释方法，也可用 @brief 标签，见下方

typedef size_t SizeType;



/// @brief 对类型定义 ValueType 的简述，如果注释有多行，须在每行末尾加上“\”和“n”\n

/// 简述的第二行

using ValueType = char;
```

***

# 六、非公有变量注释规范

非公有变量包括类的私有、保护变量和文件 static 局部变量，这些变量不作为接口，不应让注释内容出现在 Doxygen 的输出文档中，故使用常规注释，即双斜杆“//”开头。

```
// 对文件 static 变量的简述，若需多行注释，直接换行，无需再行末添加“\n”

// 简述第二行

static int gsMarks[100] = {0};



/// @brief 类内容简述

class Student

{

private:

    // 对类私有变量 mAge 的简述，若需多行注释，直接换行，无需再行末添加“\n”

    // 简述第二行

    size_t mAge;

    // 对类私有变量 kNum 的简述

    size_t mNum;



public:

    /// 对公有变量 mkTotal 的简述，mAge 和 mNum 不属于公有变量

    const static size_t mkTotal = 100;

}
```

***

# 七、函数体内注释规范

函数体内的注释内容属于细节说明，也不应出现在 Doxygen 的输出文档里，应采用常规注释。

```
int main(void)

{

    // 函数体内注释

    auto ptr = new Student(20, 100000);

    std::cout << "A new student created. Number: "

              << ptr->getNum() << "; Age: " << ptr->getAge() << "." << std::endl;

    // 函数体内注释，若需多行注释，直接换行，无需再行末添加“\n”

    // 注释第二行

    delete ptr;

    return 0;

}
```

***

# 八、TODO、HACK、FIXME 注释规范

TODO、HACK、FIXME 这些标识的注释可以出现在任何地方，但也属于细节内容，不应被 Doxygen 识别写进文档，故也采用常规的双斜线“//”注释，同时要添加小括号，括号内要写上邮箱前缀。


// “HACK”内容第二行
```

***

# 九、Doxygen 其他关键字

Doxygen 能识别的关键字除了上文列举的 @brief、@param、@return、@retval 等关键字之外，还能识别更多关键字，下面通过离子说明几个常用的字段的用法。

```
/**

 * @brief 这里填写函数功能简述，第三行示例 @deprecated 的用法

 * @param root 这里填写形参描述

 * @deprecated：（可选）表明该函数可能会被弃用

 */

void preorderTraversalRecursively(Node* root)

{

    // ...

}



/**

 * @brief 这里填写函数功能简述，下面示例 @see 的用法

 * @param root 这里填写形参描述

 * @see （可选）迭代版参见 preOrderTraversalIteratively(Node *root)

 */

void preOrderTraversalIteratively(Node* root)

{

    // ...

}



/**

 * @brief 函数功能简述，下面示例 @note 和 @code、@endcode 的用法

 * @param year 形参描述

 * @param month 形参描述

 * @param day 形参描述

 * @note （可选）描述在使用时容易出错需要注意的点，比如：使用该函数前必须判断参数范围是否合理

 * @code

 *     if (year >= 0 && 1 <= month && month <= 12 && 1 <= day && day <= 31) {

 *         setDate(year, month, day);

 *     }

 * @endcode

 */

void setDate(int year, int month, int day)

{

    // ...

}
```

更多关键字用法详见[官方说明文档](http://www.doxygen.nl/manual/commands.html)。