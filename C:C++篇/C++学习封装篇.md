# C++ 学习封装篇

# 1、类与对象

类是用户定义的数据类型规范，它详细的描述了如何表示信息以及可对数据执行的操作。
对象是根据类规范创建的实体，就像简单变量是根据类型描述创建的实体一样。

## 1.1、类的定义 与 实例化对象

### 1.1.1、 使用关键字 `class` 定义一个 `People` 类

```
class People {
    
};
```

### 1.1.2、数据的封装

C++ 作为一门面向对象的语言，通过 __封装__ 将数据成员与成员函数封装在一个类中；通过 `class` 定义的类公布其接口。


```
/// 使用关键字 class 定义一个类
class People {

/// 公有成员
public:
    std::String name;
    float height;
    void eat(std::String food);
/// 受保护    
protected:
    int age;
    
/// 私有成员
private:
    float weight;
};
```


可以使用 __访问限定符__  `public` | `protected`  |  `private` 选择暴露或者隐藏某些类的信息！在类中，访问限定符可以使用一个、也可以使用多个！

`public`： 公有的；可以在外部访问，读写；
`protected`： 受保护的；被修饰的成员不能在外部被访问；只能在类定义内部读写； 
`private`： 私有的；被修饰的成员不能在外部被访问；只能在类定义内部读写； 

### 1.1.3、分别在栈中与堆中实例化  `People` 对象

```
{
    /// 栈中实例化对象
    People zhangSan;
    People peos[10];

    /// 堆中实例化对象
    People *liSi = new People();
    People *rens = new People[10];
    
    /// 对象的成员访问
    cout << zhangSan.height << endl;
    cout << peos[0].height << endl;
    zhangSan.eat();
    
    if (liSi != NULL){
        cout << liSi -> height << endl;
        liSi -> eat();
        delete liSi;
        liSi = NULL;
    }
    
    if (rens != NULL){
        cout << rens[1] -> height << endl;
        
        delete []rens;
        rens = NULL;
    }    
}
```

## 1.2、类内定义与类外定义

成员函数的函数体写在类的定义体之内、还是外面，是有区别的：
* 类内定义：函数体写在类的定义体之内；
* 类外定义：函数体写在类的定义体之外；类外定义的函数可以重载；

一般而言，将类的声明与实现分为两个文件：

* 同文件类外定义：类的定义、与成员函数的实现，都在一个文件中！ 
* 分文件类外定义：类定义在 `People.hpp` 文件，而成员函数的实现，主要在  `People.cpp` 文件中！

```
/// 类外定义的格式
void People::eat(std::String food) {
    cout << "人要吃什么？" << food << endl; 
}
```


不得不提：对于类内定义的函数体，编译器会优先使用 `inline` 的方式来编译这些函数；但对于复杂的函数，还是会编译为普通的函数！

## 1.3、对象指针

对象指针指向一块堆内存（第一个成员的地址）

堆中内存 ：运算符 `new` 与函数  `malloc()` 的区别 :
* `new` 会调用默认构造函数;
* `malloc()` 仅仅开辟内存，不会初始化这段内存的数据；


```
{
    ///对象指针 peo 指向一块堆内存
    People *liSi = new People; /// new 一个类后面，不加 () 则调用默认构造函数
    
    if (liSi != NULL){
        cout << (*liSi).age << endl; /// (*liSi) 以对象的方式访问数据成员
        cout << liSi -> name << endl; /// liSi 以对象指针的方式访问数据成员
        delete liSi;
        liSi = NULL;
    }
}
```

## 1.4、`this` 指针

> `this` 指针就是指向自身数据的指针！

说的通俗点， `this` 指针指向其类实例对象的起始地址！

###### 参数与数据成员同名怎么办？

```
class People {
public:
    /// 参数与数据成员同名怎么办？
    setHeight(float height) {
        /// 注意：此时编译器无法识别两个 height 的含义
        /// 导致无法达到预期的赋值结果
        height = height;
    }
private:
    float height;
};
```

上述代码中 _参数与数据成员同名_ ,导致赋值失败！碰见这种情况，我们应该使用`this` 指针指向自身的数据成员！

```
class People {
public:
    setHeight(float height) {
        /// this 指针一般写在容易混淆的地方
        this -> height = height;
    }
private:
    float height;
};
```

###### 成员函数如何访问到对应的数据成员？


实例对象的变量存储在栈区或者堆区，而编译的类的二进制文件存储在代码区！当一个类创建多个对象时：
* 编译器是如何区分哪个对象调用了成员函数 `setHeight()` 呢？
* 编译器是如何在成员函数 `setHeight()` 中为对应的对象赋值，而没有产生混乱呢？


```
class People {
public:
    setHeight(T *this, float height) {
        /// 编译器自动的为每个成员函数的参数列表添加了一个 this 指针！
        this -> height = height;
    }
private:
    float height;
};
```

编译器自动的为每个成员函数的参数列表添加了一个 this 指针！因此当不同对象调用同一个成员函数时，不会混淆调用者！


######  `this` 指针添加到成员员函数的位置！

添加到第一个位置？最后一个位置？


###### 打印自身


```
class People {
public:
    setHeight(float height) {
        this -> height = height;
    }
    
    /// 通过引用的方式，打印自身
    People &printfPeople(){
        return *this;
    }
    /// 通过指针的方式，打印自身
    People *printfPeople(){
        return this;
    }
    
private:
    float height;
};
```



###### `this` 指针总结：

*  `this` 指针无需用户定义，是编译器自动产生的！
*  同一个类的多个对象的`this` 指针，指向其实例的内存地址！
* 当成员函数的参数或临时变量与数据成员同名时，可以使用  `this` 指针区分同名的数据成员；
*  `this` 指针也是指针类型，在 64 位编译器下占用 8 个字节的内存！

# 2、构造函数与析构函数

内存分区 | 解释
-|-
栈区 | `int a = 5; int *p = NULL;`
堆区 | `int *q = new int[10];`
全局区 | 存储全局变量及静态变量
常量区 | `String str = "Hello"`
代码区 | 存储编译之后的二进制代码

## 2.1、构造函数

构造函数的规则和特点：
* 构造函数在对象实例化时被自动调用
* 构造函数与类名同名；
* 构造函数没有返回值；
* 构造函数可以有多个重载形式（遵循重载函数的规则）；
* 构造函数的参数列表，可以有默认值；
* 实例化一个对象时，仅仅用到一个构造函数；
* 当用户没有定义构造函数时，编译器自动生成一个构造函数；

### 2.1.1、无参构造函数

构造函数内部为一些成员变量赋值
```
class People {
    People(){ name = "人类"; }
private:
    String name;
}
```

### 2.1.2、有参构造函数

```
class People {
    People(String name);
private:
    String name;
}

People::People(String name){ 
    this -> name = name; 
}
```

### 2.1.3、重载构造函数

```
class People {
    People();
    People(String name);
    People(int age, String name = "狗蛋"); /// 构造函数也可以有默认参数
    
public:
    String name;
private:
    int age;
}

People::People(){ 
    name = "人类"; 
    age = 0;
}

People::People(String name){ 
    this -> name = name; 
    age = 0;
}

People::People(int age, String name){ 
    this -> name = name; 
    this -> age = age; 
}
```

### 2.1.4、默认构造函数

> 在实例化对象时，如果不使用任何参数，则调用的是默认构造函数！

当构造函数没有参数时，被称为默认构造函数；
当构造函数有参数，但每个参数都有默认值时，也被称为默认构造函数；


```
class People {
    People();
    People(String name = "狗蛋");
    
public:
    String name;
}

People::People(){ 
    name = "人类"; 
}

People::People(String name){ 
    this -> name = name; 
}
```

### 2.1.5、构造函数初始化列表

推荐使用初始化列表来完成对数据成员的初始化操作！

```
class People {
    People():name("狗蛋"),age(10);
    
public:
    String name;
private:
    int age;
}
```

初始化列表特性：
* 初始化列表先于构造函数执行；
* 初始化列表只能用于构造函数；
* 初始化列表可以同时初始化多个数据成员；

###### 初始化列表存在的必要性

```
class People {
    People(){ species = "人类"}; /// ❌ const修饰，不能修改
    People():species("人类"); ///可以通过初始化列表完成 const 常量的修改
    
public:
    const String species;
}
```


### 2.1.6、拷贝构造函数

定义格式： `类名(const 类名& 变量名)` !

```
class People {
    People(const People &peo){};     
public:
};
```

拷贝构造函数特性：
* 如果没有自定义的拷贝构造函数，则系统自动生成一个默认的拷贝构造函数；
* 当采用直接初始化或复制初始化实例化对象时，系统自动调用拷贝构造函数；
* 拷贝构造函数的参数时确定的，不能重载；

###### 浅拷贝

```
class People {
public:
    People(){
        this -> age = 10;
        this -> name = new string("堆中申请内存");
    };
    /// 浅拷贝
    People(const People &peo){
        this -> age = peo.age;/// 没毛病
        
        /// 指针 name 指向同一块内存
        /// name 时通过 new 运算符申请的块内存，需要在 析构函数 中释放该块内存
        /// 两个对象释放同一块内存，会造成内存的过度释放，引起程序崩溃
        this -> name = peo.name;
    };
    ~People(){
        delete name;
    }
    int age;
    string *name;
};
```

`string` 的浅拷贝是让两个不同的指针指向同一块空间，而这在析构的时候会出现将一块空间释放两次，程序会崩溃! 因此需要进行深拷贝，即第二个指针开辟和第一个指针一样大小空间，然后将内容复制过去。


###### 深拷贝

```
class People {
public:
    People(){
        this -> age = 10;
        this -> name = new string("堆中申请内存");
    };
    
    People(const People_YL &peo){
        this -> age = peo.age;
        this -> name = new string((*peo.name)); /// 深拷贝
    };
    ~People(){
        delete name;
    }
    int age;
    string *name;
};
```


## 2.2、析构函数


对象的生命历程： 申请内存 -> 初始化列表 -> 构造函数 -> 参与运算 -> 析构函数 -> 释放内存！
申请的内存，最终要归还


* 如果没有自定义析构函数，则系统自动生成；
* 析构函数在对象被销毁时，系统自动调用！
* 析构函数没有返回值；不允许添加任何参数，也就不会重载！
* 析构函数的唯一作用就是释放资源！

定义格式：`~类名()` ！

```
class People {
    People():species("人类"); ///可以通过初始化列表完成 const 常量的修改
    ~People(){};
public:
    const String species;
}
```

### 2.2.1、析构函数存在的必要性

```
class People {
    People(){ name = new char[20]}; 
    ~People(){ delete []name; }; /// 释放掉堆中内存
public:
    char *name;
}
```

# 3、对象数组

实例化对象数组时
* 每一个对象的构造函数都会被执行；
* 内存既可以从堆上分配、也可以从栈上分配；

销毁对象数组时
* 每一个对象的析构函数都会被执行；
* 堆中实例化的数组，需要手动销毁释放内存；
* 栈中实例化的数组，系统自动回收内存；


```
class Coordinate {
public:
    Coordinate():longitude(0.0),latitude(0.0){};
    
    double longitude;
    double latitude;
};

///测试代码段
{
    Coordinate coor[3];///栈上实例化一个对象数组
    coor[0].longitude = 9.12;
    coor[0].latitude = 105.72;

    Coordinate *p = new Coordinate[3];///堆上实例化一个对象数组
    if (p != NULL) {
        p[0].longitude = 21.567;
        p[0].latitude = 56.32543;
        
        delete []p;
        p = NULL;
    }
}
```


# 4、对象成员

对象成员：一个对象成为另一个类的数据成员！

实例化一个对象 A 的时候，如果对象 A 有对象成员 B 、C，那么先执行对象成员 B 、C 的构造函数，再执行 A 的构造函数；销毁对象 A 时，先执行 A 的析构函数，再执行对象成员 C 、B 的析构函数！

/// 构造函数没有参数
/// 构造函数有参数

```
class Coordinate {
public:
    Coordinate():x(0.0),y(0.0){};   /// 默认构造函数
    Coordinate(double _x, double _y):x(_x),y(_y){}; /// 带有参数的构造函数
    
    double x;
    double y;
};


class Line {
public:
    Line():start(10,20), end(40, 50){}; /// 默认构造函数
    Line(double sx, double sy, double ex, double ey):start(sx,sy), end(ex, ey){}; /// 带有参数的构造函数
    Coordinate start;
    Coordinate end;
};
```

///测试代码段
```
{
    Line a1; ///栈上实例化一个对象
    /// 先实例化成员 start 、接着实例化成员 end， 最后实例化 Line 对象
    /// 释放内存时：先销毁 Line 对象 、接着销毁 end， 最后销毁 start
}
```


## 4.1、对象成员指针

对象成员指针：对象指针成为另一个类的数据成员！

```
class Line {
public:
    Line():start(NULL), end(NULL){}; /// 默认构造函数
    Line(double sx, double sy, double ex, double ey){
        start = new Coordinate(sx, sy);
        end = new Coordinate(ex, ey);
    }; /// 带有参数的构造函数
    
    ~Line(){
        delete start; start = NULL;
        delete end; end = NULL;
    };
    Coordinate *start;
    Coordinate *end;
};
```

类 `Line` 中仅有两个成员指针，一个指针在 64 位电脑上占 8 个字节内存，`sizeof(Line)` 理论上应该占 16 个字节内存！


## 4.2、常对象成员与常成员函数


常对象成员 ：`const` 可以修饰对象成员！


例子：一条线段一旦构造完毕，就不能再修改它的起始终点位置！

```
class Coordinate {
public:
    Coordinate():x(0.0),y(0.0){};  
    Coordinate(double _x, double _y):x(_x),y(_y){};
    double x;
    double y;
};

class Line {
public:
    /// 使用构造函数初始化列表为被 const 修饰的数据成员赋值！  
    Line():start(10,20), end(40, 50){};
    Line(double sx, double sy, double ex, double ey):start(sx,sy), end(ex, ey){}; 
    const Coordinate start;
    const Coordinate end;
};
```

## 4.3、常成员函数

常成员函数 ：`const` 修饰成员函数！

* 常成员函数本质是对 `this` 指针的修饰；
* 常成员函数中不能修改数据成员的值；

```
class Coordinate {
public:
    Coordinate():x(0.0),y(0.0){};  
    Coordinate(double _x, double _y):x(_x),y(_y){};
    double x;
    double y;
    /// 声明的地方写上 const 
    void changeX(double _x) const;
};

/// 实现的地方也需要写上 const 
void Coordinate::changeX(double _x) const {
    /// error : Cannot assign to non-static data member within const member function 'changeX'
    this -> x = _x;
}
```


为什么不能在常成员函数中修改数据成员的值？编译器将上述常成员函数编译为下述函数：

```
void Coordinate::changeX(const Coordinate *this, double _x) {
    /// 通过常指针修改该指针指向的数据，是不被允许的！
    this -> x = _x;
    /// this 指针此时仅具有读权限，没有写权限！
}
```


### 4.3.2、重载

常成员函数可以与普通同名函数互为重载

```
class Coordinate {
public:
    /// 下述函数互为重载
    void changeX(double _x);
    void changeX(double _x) const;
};
```

当与普通函数互为重载时，什么情况下调用普通函数？什么情况下调用常成员函数？

* 普通对象调用普通成员函数；
* 常对象调用常成员函数；

```
{
    Coordinate coor;
    coor.changeX(10);/// 调用普通成员函数

    ///在互为重载时：常对象将调用常成员函数
    const Coordinate coor1;
    coor1.changeX(10);
}
```


## 4.4、常指针与常引用

常对象只能调用常成员函数，不能调用普通成员函数；
普通对象能够调用普通成员函数，也能调用常成员函数；
常指针和常引用都只能调用对象的常成员函数；
一个对象可以有多个常引用！


# 5、字符串类 `String`

字符串库 `#include <string>` 

######  `String` 的初始化方式

代码|注释
-|-
`String str` | `str` 为空字符串
`String str1 = "A"` | 字符串 `str1` 初始化为 `"A"`
`String str2("B")` | 字符串`str2` 初始化为 `"B"`
`String str3(str2)` | 字符串`str3` 初始化为 `str2` 的一个副本
`String str4(n,'B')` | 字符串`str4` 初始化为字符 'B' 的 `n` 个副本，即 `BBB...BBBB`

######  `String` 的常用操作

代码|注释
-|-
`str.empty()` | 判  `str` 是否为空，为空返回 `true`
`str.size()` | 返回  `str` 中字符的个数
`str[n]` | 返回  `str` 中位置为  `n`  的字符（索引从 0 开始）
`str1 + str2` | 将两个字符串拼接为新串，返回新串的地址！
`str1 = str2` | 将  `str1`  的内容替换为  `str2` 的副本
`str1 == str2` | 判断  `str1`  与 `str2` 是否相等


######  `String` 的拼接

```
String str1 = "Hello";
String str2 = "Word";
String str3 = str1 + str2;
String str4 = "Hello" + str2;
String str5 = "Hello" + str2 + "Word";
String str6 = "Hello" + "Word"; /// ❌ 非法操作
```

__注意__ : 并不是所有的字符串都可以通过 `+` 连接的；双引号的字符串之间通过  `+` 连接，是不合法的！





对象复制与对象赋值
深拷贝与浅拷贝
对象数组与对象指针
this 指针
const + 对象 -> 常对象
const + 函数 -> 常成员函数
const + 对象成员 -> 常对象成员

