# C++ 学习继承篇

# 1、什么是继承？

继承是面向对象软件技术当中的一个概念，与多态、封装共为面向对象的三个基本特征。继承可以使得子类具有父类的属性和方法或者重新定义、追加属性和方法等。


```
/// 基类
class People {
    
public:
    int age;
    string firstName;
    void sleep(void);
    void eatFood(string food);
};

/// 派生类
class Worker : public People{
public:
    void work(void);
    int salary;
};
```

*被继承的类叫做基类也叫做父类，从其他类继承而来的类叫做派生类也叫做子类；
* 子类中不仅继承了父类中的数据成员，也继承了父类的成员函数；


## 1.1、内存中的对象

![子类与父类在内存中的关系](https://upload-images.jianshu.io/upload_images/7112462-487ca4c56ab9ac86.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


子类的实例化，内存中既包含父类的成员变量，又包含自己特有的成员变量

```
{
    Worker *p = new Worker();
    if (p != NULL) {
        p -> firstName = "狗蛋";
        p -> age = 10;
        p -> eatFood("面包");
        cout << p -> firstName << endl;
        cout << p -> age << endl;
        
        delete p;
    }
}
```

创建时先调用父类的构造函数初始化一些数据，接着再调用自身的构造函数！
销毁时先调用自身的析构函数释放一些内存，接着再调用父类的析构函数！



# 2、继承方式

基类到派生类的关系：
* 公有继承 `class subclass : public superclass`
* 私有继承 `class subclass : private superclass`
* 保护继承 `class subclass : protected superclass`

## 2.1、公有继承

在公有继承中：
* 子类可以访问父类的 `public` 成员函数，读写父类的 `public` 数据成员；
* 子类可以在 __内部__ 访问父类的 `protected` 成员函数，读写父类的 `protected` 数据成员；
* 子类无法访问父类的 `private` 成员函数，不能读写父类的 `private` 数据成员；父类的私有数据成员与成员函数，对于子类来说，是 __不可见__ 的！
* 父类的私有成员函数不能被子类继承并使用；


基类成员访问属性  | 继承方式 | 派生类成员访问属性
-|-|-
`private`  成员   |   `public`  |   无法访问（不可见）
`protected` 成员 |   `public`  |    `protected`
`public` 成员    |   `public`  |    `public`


## 2.2、保护继承

对于访问限定符  `protected`： 其修饰的数据成员与成员函数，只能在类内部访问与读写；在外部是不被允许使用的！

基类成员访问属性  | 继承方式 | 派生类成员访问属性
-|-|-
`private`  成员   |   `protected`  |   无法访问（不可见）
`protected` 成员 |   `protected`  |    `protected`
`public` 成员    |   `protected`  |    `protected`

在保护继承中：
* 父类的公共成员函数与数据成员，将成为子类的受保护成员函数与数据成员！
* 父类的受保护成员函数与数据成员，将成为子类的私有成员函数与数据成员！
* 父类的私有成员函数与数据成员，对于子类来说是不可见的！

## 2.3、私有继承

对于访问限定符  `private`： 其修饰的数据成员与成员函数，只能在类内部访问与读写；在外部与子类中是不可见的！


基类成员访问属性  | 继承方式 | 派生类成员访问属性
-|-|-
`private`  成员   |   `private`  |   无法访问（不可见）
`protected` 成员 |   `private`  |    `private`
`public` 成员    |   `private`  |    `private`


在私有继承中：
* 父类的公共成员函数与数据成员，将成为子类的私有成员函数与数据成员！
* 父类的受保护成员函数与数据成员，将成为子类的私有成员函数与数据成员！
* 父类的私有成员函数与数据成员，对于子类来说是不可见的！


# 3、覆盖与隐藏


继承关系中的 覆盖 与 隐藏：
* 隐藏：同名的成员变量、或者同名的成员函数 （父子关系、成员同名、隐藏）
* 

## 3.1、隐藏

隐藏的特性主要提现在：
* 子类的实例对象只能访问自己的成员函数，而似乎无法访问父类的同名函数
* 子类修改的是自己的数据成员，而不能直接修改父类的同名数据成员

```
/// 父类
class People {
protected:
    string food;
public:
    void eatFood(string food){
        this -> food = food;
    };
};

/// 子类
class Worker : public People{
protected:
    /// 同名的数据成员
    string food;
public:
    /// 子类的函数隐藏了父类的同名函数
    void eatFood(string food){
        this -> food = food;
        
        this -> People_YL::food = food;// 读写同名的父类数据成员
    };
};
```

但实际上，父类的同名函数确实被子类继承，可以通过特殊手段来访问父类的同名函数

```
{
    Worker_YL *p = new Worker_YL;
    p -> eatFood("工人在食堂吃饭");
    
    /// 通过特殊手段来访问父类的同名函数
    p -> People_YL::eatFood("人类需要吃饭");
}
```

__注意：__ 在继承关系中，同名但参数不同的函数，无法形成重载，只能以隐藏的形式出现！

即使子类已经继承了父类的函数，但函数同名，就会将父类函数隐藏，即使参数不同，也无法形成重载！

```
/// 父类
class People {
public:
    void eatFood();
};

/// 子类
class Worker : public People{
public:
    /// 子类的函数隐藏了父类的同名函数
    void eatFood(string food);
};


/// 测试代码
{
    Worker_YL *p = new Worker_YL;
    p -> eatFood("工人在食堂吃饭");

    p -> eatFood(); /// ❌ 不允许这种调用
    p -> People_YL::eatFood(); /// 要想调用该函数，只能通过父类来调用
}

```


# 4、 基类与派生类的关系： `Is'a` 与 `Has'a`


## 4.1、 `Is-a` 关系 

`Is-a` 概念：派生类的实例对象也是一个基类的实例对象
* 父类指针无法访问子类的成员变量与成员函数
* 调用父类指针销毁子类的实例对象，只会销毁父类的那一部分；子类独有的成员变量，不会被释放
* 父类指针  `new`  一个子类对象时，构造函数会先调用父类的构造函数，接着调用子类的构造函数！
* 而 `delete` 仅仅调用的是父类的构造函数 ；

```
class People {
public:
    int age;
    void eatFood();
};

class Worker : public People{
public:
    int salary;
    void work(void);
};
```

测试代码段

```
/// Is-a 概念：派生类的实例对象也是一个基类的实例对象
{    
    People *p = new Worker(); /// 先调用 People 的构造函数，接着调用 Worker 的构造函数
    std::cout << p -> age << std::endl; 
    
    /// ❌   父类指针无法访问子类的成员变量与成员函数
    std::cout << p -> salary << std::endl; 
    std::cout << p -> work() << std::endl;
    
    /// 调用父类指针销毁子类的实例对象，只会销毁父类的那一部分
    /// 子类独有的成员变量，不会被释放
    delete p; /// ❌
}
```

__思考__：在 `Is-a` 关系中如何通过父类指针释放子类内存？


### 4.1.1、虚析构函数

虚析构函数：当存在继承关系时，使用父类指针指向堆中的子类对象，并且向通过父类指针释放子类的内存，这种情况下就需要虚析构函数来解决了！

虚析构函数 `virtual ~People();`   当父类的析构函数被声明为虚析构函数时，编译器也会默认将子类的析构函数编译为虚析构函数！

```
class People {
public:
    int age;
    void eatFood();
    virtual ~People(); /// 声明为虚析构函数
};

class Worker : public People{
public:
    int salary;
    void work(void);
    ~Worker();/// 编译器也会默认将其编译为虚析构函数
};
```

此时通过父类指针指向堆中的子类对象，并且使用父类指针释放子类的内存，将会先调用子类的析构函数，接着调用父类的析构函数！


### 4.1.2、测试

测试在公有继承中，`Is-a`  在函数传递中的表现！

###### 继承关系

```
class People {
public:
    string name;
    People(){
        this -> name = "人类";
        cout << "People" << endl;
    };
    virtual ~People(){
        cout << "~People" << endl;
    };
    void logName(){
        cout << this -> name << endl;
    }
};

class Worker : public People{
public:
    Worker(){
        this -> name = "工人";
        cout << "Worker" << endl;
    };
    ~Worker(){
        cout << "~Worker" << endl;
    };
};
```

###### 测试函数

```
/// test1 函数的传值是一个对象 peo
/// 因此调用函数传值时，系统会现在栈上创建一个临时的对象，函数调用结束后，将栈上的缓存释放
void test1(People peo) {
    peo.logName();
}

void test2(People &peo) {
    peo.logName();
}

void test3(People *peo) {
    peo -> logName();
}
```

对比 `test1()` 函数 ， `test2()`与 `test3()`不会产生临时变量，效率更高！

###### 测试代码

```
{
    People p;
    Worker w;
    
    test1(p);
    test1(w);
    
    test2(p);
    test2(w);
    
    test3(p);
    test3(w);
}
```

上述三个 `test` 函数，
* 当传递 `People` 对象时，打印的是 `People` 对象的实例变量；
* 当传递 `Worker` 对象时，打印的是 `Worker` 对象的实例变量；


Has a : 包含关系！


# 5、多继承与多重继承

## 5.1、多重继承

当 `B` 类从 `A` 类派生而来，`C` 类从 `B` 类派生而来，此时称为多重继承！

```
class People {
public:
    string name;
};

class Worker : public People{
};

class BenchWorker : public Worker{
};
```

实例化一个 `BenchWorker` ，构造函数的执行顺序：`People()` ->  `Worker()` ->  `BenchWorker()` !
释放一个 `BenchWorker` ，析构函数的执行顺序：`~BenchWorker()` ->  `~Worker()` ->  `~People()` !
一个子类的对象，可以作为参数，传入父类的函数中！
不管继承的关系有多少层，只要存在继承关系，子类与父类就存在 `isa` 的关系：`PeasantWorker` isa `People` ；`PeasantWorker` isa `Worker`！


## 5.2、多继承

多继承：
* 一个子类继承多个父类
* 对父类的个数没有限制，继承方式可以是公共继承、保护继承、私有继承；
* 继承时，如果没有生命继承方式，默认为私有继承；

```
/// 工人
class Worker : public People{
};
/// 农民
class Peasant : public People{
};
/// 农民工 : 默认私有继承
class PeasantWorker : public Peasant, public Worker {
public:
    PeasantWorker(){
        ///编译❌ Non-static member 'name' found in multiple base-class subobjects of type 'People':
        this -> name = "农民工";
    };
};
```

实例化一个 `BenchWorker` ，依次调用父类的构造函数（初始化列表中的顺序）！析构函数的执行顺序正好与构造函数的执行顺序相反！


`PeasantWorker` isa `Worker`
`PeasantWorker` isa `Peasant`


## 5.3、多继承与多重继承的陷阱


菱形继承：既有多继承、又有多重继承！如下所示
     类 A                     人类
  类B     类C          农名类         工人类
      类D                     农民工类

类 D 继承类B，类B继承类A；类 D 继承类C，类C继承类A！ 
此时类 D 将含有类 A 中两份完全相同的数据，这是不被允许的；
如何解决数据冗余的问题呢？使用虚继承 `virtual` ！

## 5.4、虚继承 `virtual`

```
/// 工人
class Worker : virtual public People{
};
/// 农民
class Peasant : virtual public People{
};
/// 农民工 : 默认私有继承
class PeasantWorker : public Peasant, public Worker {
};
```
此时`PeasantWorker`类仅含有`People`类中一份数据！
