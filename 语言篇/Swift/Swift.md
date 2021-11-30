# Swift

# 1、常量和变量

```
{
    /// 常量：声明时赋初值后不可再修改
    let num = 100
    
    /// 设置一个常量或者变量后，可以先不赋初值，在随后的某个时机设置一次
    let isSuccess : Bool
    
    /// 不管是常量、还是变量，必须赋初值之后才能使用，
    if isSuccess { /// Constant 'isSuccess' used before being initialized
        print("success")
    }

    isSuccess = true  /// 常量，仅能设置一次初值  
    isSuccess = false /// error : Immutable value 'isSuccess' may only be initialized once


    /// 变量：声明后还可以多次修改
    var a = 10
    a = 20
}
```

## 1.1、Swift 是一门强类型的语言

Swift 语言有一种机制：当给一个变量赋上初值后，会自动的判断该变量的类型是什么，而无需显示的声明其类型！

```
var a = 10
a = "Hello word!"
/// error : Cannot assign value of type 'String' to type 'Int'
```

Swift 是一门强类型的语言，为变量赋值时会判断值类型是否一致！如果不一致，则编译报错！


```
/// 可以一次声明多个变量，然后一起指定它们的值类型
var e, f, g :Double
```

## 1.2、常用类型

## 1.2.1、整型

`Int` 类型由计算机决定：在 32 位机器上是 32 位，在 64 位机器上占 64 位

```
/// 声明一个整型 Int
var a : Int = 10

Int.max ///  9223372036854775807
Int.min /// -9223372036854775808
```

__Swift 是一门安全的语言__ :  当发生内存溢出时，Swift 在编译层面给出错误提示!

```
/// error: Integer literal '92233720368547758079' overflows when stored into 'Int'
a = 92233720368547758079
```

可以为整型赋上一个二进制的值

```
/// 二进制
var b : Int = 0b10001
/// 八进制
var c : Int = 0o21
/// 十六进制
var d : Int = 0x11
```

创新：可以使用下划线 `_` 给一个多位数的整型分割：

```
var bigA : Int = 922_337_203_685_477_580
```

## 1.2.2、浮点型

```
///  单精度浮点型（六位有效数字）
var a : Float = 3.1415926   /// 实际存储值 3.141593

///  双精度浮点型
var b : Double = 3.1415926

/// 使用科学计数法来表示一个非常大（小）的浮点数
var c = 1.25e-9

/// 使用下划线使程序更加可读
var d = 1.234_567_890
```

## 1.2.3、布尔类型

```
let isEnable : Bool = true
let isCan = false

/// 布尔类型多用于选择语句，而非计算语句
if isEnable {
    
}
```

__Swift 是一门安全的语言__ : `if` 语句只支持布尔类型，不支持整型等其它类型！

```
/// Error Type 'Int' cannot be used as a boolean; test for '!= 0' instead
if 1 {
    
}
```

## 1.2.4、元组


元组: 将多个不同的数据放在一个数据类型中！
* 可以有任意多个值；
* 不同的值可以是不同类型；

```
/// 表示一个平面坐标
var point = (1.5, 2.0)

/// 元祖不仅可以存储相同的数据类型，也可以存储不同的数据类型
var response = (404, "not found")
```

显式的声明一个元组:

```
var point: (Float, Float) = (2.5, 5.6)
var response: (Int, String) = (200, "ok")
```

可以直接通过下表使用元组的值，也可以解包元组！当元组中的数据很多时，通过下标访问的方式没有解包直观清晰！

```
var point: (Float, Float) = (10.5, 50.6)

/// 通过下标使用元组
point.0 /// 10.5
point.1 /// 50.6

/// 解包元组
let (x, y) = point
x /// 10.5
y /// 50.6
```

Swift 允许我们在定义一个元组时，为每个分量定义名字：

```
/// 命名元组分量
var point = (x : 2.5, y : 5.6)
var point: (x : Float, y : Float) = (2.5, 5.6)
```

如果元组的分量不必全部使用，也可以解包某一个需要的分量，其它分量使用 `_` 表示！

```
let result = (true, "info")
let (isSuccess, _) = result /// 下划线 _ 忽略元组的第二个分量 
if isSuccess {
    
}
```

## 1.2.5、类型转换

__Swift 是一门安全的语言__ : 不同类型的数据做运算，不被允许！
很多语言都具有自动类型转换这一个功能，但太多的隐式错误都是由自动类型转换引发的，因此 Swift 没有自动类型转换这一个功能！


```
let a : UInt = 100
let b : Int = 50
var c = a + b
/// error: binary operator '+' cannot be applied to operands of type 'UInt' and 'Int'
```

不同的类型运算，需要由开发者明确转换类型：在开发者进行类型转换时可以 _避免数值溢出等隐式错误_ ！

```
let a : UInt = 100
let b : Int = 50
var c = Int(a) + b /// 强制类型转换
```

## 1.3、打印函数

```
{
    let a = 1, b = 2, c = 3
    
    print(a, b, c)              /// 1 2 3
    /// 打印多个参数，使用指定分隔符分割
    print(a, b, c, separator: "｜")      /// 1｜2｜3
    /// 一般而言，打印字符串的最后一位是回车符，但可以重写该字符（此时不会换行）
    print(a, b, c, separator: "｜", terminator: "-")  /// 1｜2｜3-
}
```
 

# 2、运算符

最短路原则

```
/// 三目运算符
var a = 1
var hello = a > 1 ? "你好" : "不好"
```

区间运算符

```
let left = 1, right = 10

/// 闭区间 [left, right] 表示为 left...right
for index in left...right { /// 注意：此处的 index 是一个常量，不能被改变
    index
}

/// 前闭后开区间 [left, right) 表示为 left..<right
let array = [1, 2, 3, 4, 5, 6, 7]
for i in 0..<array.count{ /// 前闭后开的应用场景
    array[i]
}
```

# 3、控制流

Swift 的控制转移符号：`break`、`continue`、`fallthrough`、`return`、`throw`！

* 顺序结构
* 循环结构
* 选择结构


## 3.1、for 循环的一些用法

`for in` 的局限性：只能在一个整型区间内，逐次向前遍历

```
/// 在 Swift 3 已经废弃 
for var i = 0.5; i < 100; i=i*0.3 {
    print(i)
}
```

当多层 `for` 循环语句嵌套使用时，满足某一条件后，如何停止所有 `for` 循环呢？
可以为每一层的 `for` 循环命名，然后 `break name`

```
/// x^4 - y^2 = 15 * x * y
outFor : for x in 1...300 {
    for y in 1...300 {
        if x * x * x * x - y * y == 15 * x * y {
            print(x,y)
            break outFor /// 跳出两层 for 循环
        }
    }
}
```

for 循环非常直接的告诉我们，一个循环的四部分内容：
* 循环变量的初始化；
* 循环结束的条件；
* 变量的变化；
* 循环体；


## 3.2、where 语句的某些用法

```
/// while 条件语句：适用于不知道多少次循环才能结束的情况
var a = 1, b = 1
while a < 5, b < 5 {
    if a < b {
        a += 1
    } else {
        b += 1
    }
}

/// repeat...while 至少执行一次循环体
var c = 1, d = 1
repeat {
    if c < d {
        c += 1
    } else {
        d += 1
    }
}while c < 1 && d < 1
```

## 3.3、switch 语句

switch 语句默认支持 break 控制！
* switch 语句不仅支持 int 型变量，还支持浮点型、布尔型、字符串型等
* 由于没有了 break，要求每个`case`后面必须跟一条语句；
* 两个 case 合在一起需要使用 `case "John" , "Ron"` 的写法；
* `default` 如果没有逻辑执行，可以使用 `()` 或者 `break`
* 当把所有可能的结果都穷举出来后，可以不写 `default` 语句；

```
/// 判读字符串
var name = "Tom"
switch name {
case "Tom" :
    print("Tom")
case "John" , "Ron":
    print("John-Ron")
default :
    () /// break
}
```

switch 配合元组，可以将非常复杂的逻辑，巧妙的表达出来

```
var point = (1, 0)
switch point {
case (0, 0):
    print("坐标原点")
case (0, _):  /// 忽略 Y 轴坐标
    print("在 Y 轴")
case (let x, 0): /// 匹配并解包元组数据
    print("在 X 轴 \(x)")
case (-2...2, -2...2):
    print("在一个矩形区间内")
default:
    break
}
```

针对上述代码，假如 `point.0` 既在原点的 case ，也在 X 轴的 case，如果想要将这两种条件都执行；需要使用 `fallthrough` 

```
var point = (1, 0)
switch point {
case (0, 0):
    print("坐标原点")
    fallthrough /// 当执行完该 case ，不会跳出 switch ，而是接着执行下条 case
case (0, _):  /// 忽略 Y 轴坐标
    print("在 Y 轴")
case (let x, 0): /// 匹配并解包元组数据
    print("在 X 轴 \(x)")
case (-2...2, -2...2):
    print("在一个矩形区间内")
default:
    break
}
```


## 3.4、不同语句的结合使用

switch 语句结合 where 语句 ：

```
var point = (1, 1)
switch point {
case (0, 0):
    print("坐标原点")
    fallthrough /// 当执行完该 case ，不会跳出 switch ，而是接着执行下条 case
case (0, _):  /// 忽略 Y 轴坐标
    print("在 Y 轴")
case (let x, 0): /// 匹配并解包元组数据
    print("在 X 轴 \(x)")
case let (x, y) where x == y : /// 解包后，进一步使用某种条件来筛选
    print("在直线 x = y 上 ")
case (-2...2, -2...2):
    print("在一个矩形区间内")
default:
    break
}
```

if 语句结合 case 使用 ：

```
let height = 100
if case 90...100 = height {
    print(height)
}
```

if 语句结合 case ，并增加限制条件：

```
let height = 93
if case 90...100 = height, height > 95 { /// 使用 , 在原有条件的基础上，再增加一个限制条件
    print(height)
}
```

for 语句结合 case，并使用 where 语句增加限制条件：

```
/// 遍历打印 [1, 100] 以内被 5 整除的数字
for case let i in 1...100 where i % 5 == 0 {
    print(i)
}
```

## 3.5、`guard` 语句

在函数内部，当判断的逻辑过多时，就会造成代码冗余，可读性差

```
func buy(money : Int, price : Int, capacity : Int, volume : Int){
    if money >= price {
        if capacity >= volume {
            print("Success")
        } else {
            print("fail")
        }
    } else {
        print("fail")
    }
}
```

使用 `guard` 语句精简上述函数

```
func buy(money : Int, price : Int, capacity : Int, volume : Int){
    guard money >= price else { /// 首先使用 guard 判断边界条件，剥离不相干情况
        print("fail")
        return
    }
    guard capacity >= volume else {
        print("fail")
        return
    }
    
    /// 然后开发者安安心心的编写代码
    print("Success")
}
```

`guard` 语句的作用类似于控制流语句，只有满足条件才能向下执行，否则 `return`；

# 4、字符串 


## 4.1、字符 `Character`

在其它语言中字符一般使用单引号表示；但在 Swift 中字符使用双引号，为区分字符串，故而需显示声明为 `Character` !

```
var ch : Character = "C"
```


在其它语言中，一个中文可能被编译为多个字符；但在 Swift 中一个中文可以表示一个字符，一个表情可以表示一个字符

```
var ch : Character = "重"  /// 中文字符
var ch : Character = "🐶" ///  表情字符
```

## 4.2、字符串 `String`


```
let tom : String = "Tom"
let name = String("name")

/// 空字符串
var empty = ""
var empty1 = String()
empty.isEmpty /// 判空操作

/// 字符串插值 \()
let des = "My name is \(tom), my age is \(18)"
```

拼接字符串

```
var addStr = name + tom /// 两个字符串直接相加
addStr += addStr        /// 一个字符串自加

/// append 后可以拼接 字符、字符串
var greeting = "Hello, Swift"
greeting.append(ch)
greeting.append(name)
```

遍历字符串中的每个字符

```
var greeting = "Hello, Swift"
for c in greeting {
    print(c)
}
```

Swift 中的字符串基于 Unicode 字符，不同的字符长度也不一样！这使得对于 Swift 字符串中的字符，不能通过下标的方式获取

```
let s1 : String = "😂😄👌"    /// s1.count = 3
let s2 : NSString = "😂😄👌"  /// s2.length = 6

/// error: 'subscript(_:)' is unavailable: cannot subscript String with an Int, use a String.Index instead.
s1[0]
```

在 Swift 语言中，为字符串封装了一个字符索引 `String.Index`

```
var greeting = "Hello, Swift"
var index = greeting.startIndex /// 获取索引类型 String.Index

/// 获取第 0 个位置的字符
greeting[index] 

/// 在索引 index 处插入一个字符
greeting.insert("#", at: index)

/// 移除指定索引位置的字符
greeting.remove(at: index)
```

字符串大小写转换

```
var greeting = "Hello, Swift"
let greetingB = greeting.uppercased() /// 转为大写
let greetingS = greeting.lowercased() /// 转为小写
let greetingC = greeting.capitalized  /// 首字母转为大写
```

`NSString` 可以被强制转换为 `String` 类型，因此可以使用一些 `NSString` 独有的功能！

```
/// 使用 NSString 保留浮点数指定位数，再强转为 String 类型
let flNStr = NSString(format: "保留2位小数: %.2f", 978 / 1235.0) as String
/// 强制转换，也可以称之为 桥接
```
