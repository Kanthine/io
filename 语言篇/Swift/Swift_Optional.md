# Swift 可选型 `Optional`

## 1、可选型概念

```
var httpErrorCode : Int = 404

/// 内部约定，假如没有错误，使用 0 来表示
httpErrorCode = 0
/// 外部人员可能误将 0 理解为一种错误类型
```

在 Swift 中，不应该使用同一种类型中的某个特殊值来代表 _没有_ 这个概念；
* 而应该某个统一的符号或者值，来代表没有这个概念；
* 这个特殊的值或者符号就是 `nil`
* 在 Swift 中 `nil` 不代表 0 ，不代表空字符串，它是一种类型(一种 _没有_ 的概念)


基于上述原因，Swift 创造了可选型 `Optional` 这个概念
* `nil` 是一种类型，不能将一个变量赋值为 `nil`；
* 可选型：某种类型和 `nil` 类型共存的概念；
* 可选型必须显示声明；

```
var s3 : String = "你好"
/// error: 'nil' cannot be assigned to type 'String'
s3 = nil

var s4 : String? /// 声明一个字符串的可选型
s4 = nil     /// 此时可以赋予 nil 型
s4 = "字符串" /// 也可以被赋予字符串型

s4 = s3 /// 字符串的可选型 可以被赋予一个 字符串类型的值
/// s3 = s4 字符串类型，不能被赋予一个 字符串的可选型 的类型值

print(s4) /// Optional("你好")
```

## 2、可选型解包

由于 Swift 是一门类型安全的语言，可选型不可以被直接使用！

可选型可能为 nil ，直接使用存在潜在风险；使用之前需要首先解包！

__强制解包__：在某种场景下，如果确定可选型一定不为 `nil`，可以强制解包可选型！

```
var greeting : String?
greeting = "Hello, Swift"

/// 强制解包 greeting!
greeting! + "!"
```

可选型可能为 nil ，强制解包会存在一定的风险，对于多人参与的大项目，如果不确定是否有值，可以在强制解包前先判断是否为 `nil` ：

```
var greeting : String?
/// 强制解包前，可以先判断是否为 nil
if greeting != nil {
    
}
```

使用 if 语句，将可选型解包到某个常量：
* 由于只是读取可选型的值，因此解包到一个常量中
* 也可以解包到变量中

```
/// 尝试将可选型 greeting? 解包，如果不为 nil ，则解包成功
/// 解包成功后，会把值赋给一个常量
if let greet = greeting {
    /// 此时 greet 是一个被解包的字符串类型，可以直接使用
    print(greet)
}

/// 出了 if 作用域，greeting 仍然是一个可选型
```

可以一次解包多个变量：

```
var name1 : String?
var name2 : String?

/// 既同时解包了两个可选项， 
/// 又对某个解包值做了近一层的逻辑判断
if let name1 = name1, let name2 = name2, name2 == "Tom" {
    
}
```


## 3、可选型链

在 Swift 中，可能解包出来的值，调用某个函数后还是可选型，需要再次解包，然后向下调用函数！

类似于这种可选型层层传递的现象，称之为可选型链！

下述两种可选型的解包方式是等价的：

```
var greeting : String?

/// 使用 if 解包后使用它的某个函数
if let greeting = greeting {
    greeting.uppercased()
}

/// 虽然 greeting 是一个可选型，但尝试对可选型解包
/// 如果解包成功，则调用 uppercased
/// 如果解包失败，则停止向下调用
var upString = greeting?.uppercased() /// upString 也是一个可选型
```

可选型的 `nil-Coalesce`，Swift 支持为可选型提供一个默认值！

```
var greeting : String?
let hello = greeting ?? "Hello" /// 类似于三目运算符
```

## 4、可选型在元组的使用

下述代码仅仅限定元组的第二个值是可选型，整个元组并不是可选型

```
var error : (code : Int, message : String?) = (404, "Not found")
```

设置元组是可选型，但它的分量不是可选型

```
var error : (code : Int, message : String)? = (404, "Not found")
```

由于元组有多个分量，因此一定要明确设置某个分量为可选型、还是设置整个元组为可选型！

```
var error : (code : Int, message : String?)? = (404, "Not found")
```

## 5、隐式可选型

对于隐式可选型，虽然不强制解包，但它仍然是可选型！在使用时，如果不能保证是一个非 `nil` 值，仍然有程序崩溃的风险！

```
/// 下述写法是隐式可选型的声明
/// 此时变量可以存放 nil ，但在使用时不需要解包
var greeting:String!
print(greeting)
```

隐式可选型多用于类的构造函数，将一个变量声明为隐式可选型，在构造函数为这些隐式可选型赋值；从而保证使用时，这个变量一定有值！

```
/// 汽车需要传入 name、user 才能构造成功
class Car {
    let name : String
    unowned let user : People
    init(name:String, user:People) {
        self.name = name
        self.user = user
    }
}

/// 司机需要传入 name、car 才能构造成功
/// 
class Driver {
    let name : String
    var car : Car!
    init(name:String, carName : String) {
        self.name = name
        
        /// 为什么 Driver.car 必须是可选型？
        /// 此时可以认为一个临时的 Driver 类已经构造完毕，只不过 car 变量是 nil
        /// 此时已经可以使用 self
        
        /// 构造汽车类时，传入 Driver 自己
        self.car = Car(name: carName, user: self)
    }
}
```



## 6、可选型作为函数返回值
