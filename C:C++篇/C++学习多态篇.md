# C++学习多态篇

> 多态：指相同对象收到不同消息或不同对象收到相同消息时产生不同的动作！

# 1、虚函数

## 1.1、静态多态

静态多态也称为早绑定！


```
class People {
public:
    void eat();
    void eat(string food);
};

{
    People p;
    p.eat();///编译器能够准确识别调用哪个函数
    p.eat("食物");
}
```

调用互为重载的函数，程序在编译的时期已经决定调用哪些函数；这种情况称为早绑定，也称为静态多态！


## 1.2、动态多态

动态多态也称为晚绑定！
* 产生多态的基础是继承关系；没有继承与封装，就没有多态！
* 动态多态至少需要一个基类，一个派生类！
* 动态多态的核心是  `virtual` 关键字，必须使用  `virtual`  才能建立多态关系！

```
class Shape {
public:
    double calcArea(){
        cout << "不负责具体实现" << endl;
        return 0;
    };
};

class Circle : public Shape {
public:
    Circle(double radius){
        this -> radius = radius;
    };
    double calcArea();
private:
    double radius;
};

double Circle::calcArea() {
    return M_PI * radius * radius;
}

class Rect : public Shape {
public:
    Rect(double width, double height){
        this -> width = width;
        this -> height = height;
    };
    double calcArea();
private:
    double width;
    double height;
};

double Rect::calcArea() {
    return width * height;
}
```

上述的代码，我们做一个测试：

```
{
    Shape *s1 = new Circle(10);
    Shape *s2 = new Rect(5,6);
    s1 -> calcArea();
    s2 -> calcArea();
}
```

可以发现，调用的都是父类的成员函数，而非具体到某个子类的函数！也就是没有实现多态的功能！
要想调用到某个子类的成员函数；需要使用 `virtual` 修饰父类的成员函数，使其成为虚函数！

## 1.3、虚函数

使用 `virtual` 修饰成员函数，使其成为虚函数！

```
class Shape {
public:
    virtual double calcArea(){
        cout << "不负责具体实现" << endl;
        return 0;
    };
};

/// 注意：此时它的子类的同名函数，编译器会默认添加 virtual 关键字，也使其成为虚函数;
///      但最好还是显示标注一下比较好！
```

此时，调用上述 1.2 的测试代码，将执行子类的相关函数！也就实现了动态多态！


虚函数使用`virtual` 关键字定义，但使用 `virtual`  关键字时，并非全部是虚函数；
虚函数特性可以被继承，当子类定义的函数与父类中虚函数的声明相同时，该函数也是虚函数；


关于 `virtual` 在函数中的使用限制：
* 不能修饰普通函数；
* 不能修饰全局函数，否则产生编译错误；
* 不能修饰静态成员函数；
* 不能修饰内联函数，否则计算机会忽略 `inline` 关键字；
* 不能修饰构造函数；


## 1.4、虚析构函数

>  父类指针指向子类对象，使用父类指针调用 `delete` 销毁子类对象时，可能存在内存泄漏 !

在上述例子中：

```
{
    Shape *s1 = new Circle(10);
    if(s1 != NULL) {
        /// 父类指针调用 delete ，仅执行父类的析构函数；
        /// 子类的一些成员无法被释放，由此导致内存泄漏
        delete s1; 
    }
}
```

解决方法：使用 `virtual` 修饰析构函数：

```
class Shape {
public:
    virtual ~Shape();
};
```

__注意：__ 只有虚析构函数，没有虚构造函数！

> 虚析构函数避免了使用父类指针释放子类对象时造成内存泄漏！

## 1.5、如何实现虚函数与虚析构函数？

函数的本质就是一段二进制代码，而函数指针就是指向这段代码开头地址的指针！

### 1.5.1、测试：证明虚函数表的存在

* 对象的大小：在类实例化出的对象中，数据成员总计占据的内存大小，不包含成员函数！
* 对象的地址：通过一个类实例化一个对象后，该对象会在内存中占据一定的内存单元；第一个内存单元就是该对象的地址！
* 对象成员的地址：每个数据成员所占据的地址；不同类型的数据成员占据不同的内存大小；
* 虚函数表指针： 一个有声明虚函数的类，具有一个隐藏的数据成员 _虚函数表指针_ `vftable_pr` ！


###### 测试1

C++ 中的一个类实例，如果没有一个数据成员，将会标记一个内存单元

```
class Shape {
public:
    int width;
};

{
    /// 测试代码
    cout << sizeof(Shape) << endl; /// 4
    Shape *p = new Shape();
    cout << p << endl;             /// 0x103016e70
    cout << &(p -> width) << endl; /// 0x103016e70
}
```

###### 测试2 (证明了虚函数表的存在)

```
class Shape {
public:
    int width;
    virtual double calcArea();
};

{
    /// 测试代码
    cout << sizeof(Shape) << endl; /// 16
    Shape *p = new Shape();
    cout << p << endl;             /// 0x10381e2a0
    cout << &(p -> width) << endl; /// 0x10381e2a8
}
```

通过上述两个测试用例，发现有虚函数的  `Shape` 类，其指针并非是第一个成员变量的地址！中间差距 8 个字节的内存单元！
这 8 个字节的内存单元，主要用于存储 虚函数表指针！


### 1.5.2、虚函数表

一个有声明虚函数的类，具有一个隐藏的数据成员：__虚函数表指针__ `vftable_pr` ！
* 虚函数表指针指向一个虚函数表，与类的定义同时出现！
* 虚函数表指针 占据一个对象的前 8 个字节的内存单元！
* 虚函数表占用一定的内存空间
* 该类只有一个虚函数表，所有该类的实例对象，共同使用一个虚函数表；
* 定义其子类时，一个子类也维护一个虚函数表；
* 父类与子类的两张虚函数表中的函数指针，可能指向同一个函数；

![虚函数表](https://upload-images.jianshu.io/upload_images/7112462-06fd841b83dbeb28.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


父类调用虚函数步骤：
* 1、通过虚函数表指针 `vftable_pr` 找到虚函数表；
* 2、在虚函数表中，通过地址偏移量，找到对应的虚函数入口地址；
* 3、根据函数地址，执行对应的虚函数；


子类调用父类的虚函数步骤（前提是子类没有同名函数）：
* 1、通过虚函数表指针 `vftable_pr` 找到自身的虚函数表；
* 2、在虚函数表中，通过地址偏移量，找到对应的虚函数入口地址；
* 3、该虚函数的入口地址，就是父类中的虚函数入口地址；
* 4、根据函数地址，执行对应的虚函数；


子类调用自身实现的虚函数步骤：
* 1、通过虚函数表指针 `vftable_pr` 找到自身的虚函数表；
* 2、在虚函数表中，通过地址偏移量，找到对应的虚函数入口地址；
* 4、根据函数地址，执行对应的虚函数；



### 1.5.3、虚析构函数

> 理论前提：执行完子类的析构函数之后，系统将会自动执行父类的析构函数；

### 1.5.4、多态中的覆盖与隐藏

* 隐藏：子类与父类出现同名函数；在子类中，父类的同名函数将被隐藏；
* 覆盖：在子类的虚函数表中，同名函数的地址被覆盖为子类函数的入口地址；


# 2、 纯虚函数

> 只有函数声明，没有函数定义的虚函数称为 纯虚函数！

```
class Shape {
public:
    int width;
    /// 虚函数
    virtual double calcArea() { return 0; }
    /// 纯虚函数：声明后面 + '= 0' 
    virtual double funcArea() = 0;
};
```

## 2.1、虚函数表中的纯虚函数

![纯虚函数](https://upload-images.jianshu.io/upload_images/7112462-ccf630fd1dd04ff7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 2.2、抽象类

> 含有纯虚函数的类，称其为抽象类！ 

* C++ 不允许抽象类实例化一个对象
* 抽象类的一个子类，也可以是抽象类


```
{
    Shape *p = new Shape();
    /// erroe : Allocating an object of abstract class type 'Shape'!
}
```


# 3、 接口类

接口类：仅含有纯虚函数的类，不含有其它的成员函数；不含有任何数据成员！

```
class Shape {
public:
    virtual double calcArea() = 0;      ///计算面积
    virtual double calcPerimeter() = 0; ///计算周长
};
```

上面  `Shape` 类不包含任何数据成员，仅有两个成员函数还都是纯虚函数！此时  `Shape` 类被称为接口类！

接口类仅需要 `.hpp` 文件来声明，不需要 `.cpp` 文件来实现！
接口类也是抽象类，因此不能使用接口类来实例化一个对象！
一个类可以继承多个接口类，同时也可以继承非接口类；

> 接口类更多的是表达一种能力或者一个协议 !



## 3.1、Objective-C 中的协议

Objective-C 中的协议类似于 C++ 的接口类，就是一堆方法的声明，但没有实现！
一个 Objective-C 类可以遵循一个或多个协议，任何类只要遵循了协议就相当于拥有了这个协议中所有的方法声明。
协议可以定义在一个类的头文件上部，并直接应用在该类中（如作为delegate功能使用时）；也可单独定义到一个类中，作为多个不同类来遵循并实现的接口。


```
@protocol HumanProtocol <NSObject>

@required
- (void)name;
- (void)age;

@optional
// ...

@end
```

协议可以用于存储方法声明，可以将多个类中的公有方法抽取出来，让这些类遵守协议即可！


# 4、运行时类型识别 `RTTI`

什么是 `RTTI` ？ 通过父类指针，识别其所指向对象的真实数据类型！
运行时类型识别必须建立在虚函数的基础上，否则无需  `RTTI` 技术！

`typeid` 注意事项:
* typeid 返回一个 `type_info` 对象的引用；
* 如果想通过基类的指针获得派生类的数据类型，基类必须带有虚函数；否则只能返回定义时的数据类型；
* 只能获取对象的实际类型；


`dynamic_cast` 注意事项:
* 只能应用于指针和引用转换；
* 要转换的类型中必须包含虚函数；
* 转换成功返回子类的地址，失败则返回 `NULL`；

## 4.1、 `RTTI` 用例

###### 定义一个接口类 

```
class Flyable {
    
public:
    /// 纯虚函数
    virtual void takeOff() = 0; ///起飞
    virtual void land() = 0;    ///降落
};
```

###### 继承接口类

```
/// 飞机类
class Plane : public Flyable{
public:
    Plane();
    ~Plane();
    
    void carry();
    
    virtual void takeOff();
    virtual void land();
};

/// 鸟类
class Bird : public Flyable{    
public:
    Bird();
    ~Bird();
    
    virtual void takeOff();
    virtual void land();
    
    void foraging();
};
```

###### 测试函数

```
void doSomething(Flyable *fly) {
    
    std::cout << "对象类型 : " << typeid(*fly).name() << std::endl;
    fly -> takeOff();
    
    if (typeid(*fly) == typeid(Bird)) {
        /// 类型强制转换
        /// 转换成功返回子类的地址，失败则返回 NULL
        Bird *niao = dynamic_cast<Bird *>(fly);
        niao -> foraging();
    }
    
    if (typeid(*fly) == typeid(Plane)) {
        Plane *ji = dynamic_cast<Plane *>(fly);
        ji -> carry();
    }
    
    fly -> land();
}


void PolymorphismDemo(void) {
    /// 分别将 Bird 类与 Plane 类实例传入上述函数
    Bird niao;
    doSomething(&niao);
    
    Plane *ji = new Plane();
    doSomething(ji);
    
    std::cout << "对象类型 2 : " << typeid(ji).name() << std::endl;
    std::cout << "对象类型 3 : " << typeid(*ji).name() << std::endl;
}
```

# 5、异常处理

异常：程序在运行过程中出现的错误！
异常处理：对有可能发生异常的地方做出预见性的安排！

常见异常：
* 数组下标越界；
* 除数为 0；
* 内存不足；

## 5.1、如何异常处理？

在 C++ 中通常 `throw` 抛出异常， 使用 `try...catch` 语法结构尝试捕获并处理异常！


```
void func1() {
    try {
        func2();
    } catch (string &value) { ///捕获异常
        /// 发生异常时，可以在此处处理一些异常
        std::cout << value << endl;
    }
}

void func2() {
    ///运行到某个异常场景时，抛出 throw 一个异常
    throw string("数组越界");
}
```

`try...catch` 可以是一对一的关系，也可以是一对多的关系！

```
catch (...) { 
    /// 省略号，表示可以捕获所有异常
}
```

多态与异常处理的关系 : 定义一个接口类 `Exception` ，处理不同场景的异常!
 
