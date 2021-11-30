# Swift 容器类

Swift 中有三个容器类：
* 数组 `Array`
* 字典 `Dictionary`
* 集合

# 1、Swift 数组 `Array`

## 1.1、数组的声明

Swift 是一门强类型的语言，对变量类型有着严格的规定： 数组中的元素类型必须一致！

```
let numbers = [1, 2, 3, 4, 5, 6]

/// 显示声明一个数组
let numbers : [Int] = [1, 2, 3, 4, 5, 6]

/// 声明一个空数组（通过构造函数创建一个数组）
let numbers = [Int]()

/// 使用泛型声明一个数组
let numbers : Array<Int> = []
let numbers = Array<Int>()

/// 声明并创建一个数组：包含 1000 个元素，每个元组的初值为 1
let numbers = Array<Int>(repeating: 1, count: 1000)
```


## 1.2、数组的常用用法

```
let numbers : [Int] = [1, 2, 3, 4, 5, 6]
numbers.count   /// 获取元素数量
numbers.isEmpty /// 判断是否为空数组
numbers[0]      /// 根据索引获取指定位置的元素
numbers.first   /// 获取首元素
numbers.last    /// 获取最后一个元素
numbers.min()   /// 获取最小值
numbers.max()   /// 获取最大值
numbers[0...3]  /// 通过下标，获取一个子数组
numbers[1..<numbers.count] 

/// 遍历数组，需要使用索引 
for (index, value) in numbers.enumerated() {
    print(index,value)
}

/// 比较两个数组 
let number1 : [Int] = [1, 2, 3, 4, 5, 6]
let number2 : [Int] = [2, 3, 4, 5, 6, 7]
number1 == number2 /// 数组是一个有序集合，故而返回 false
```

## 1.3、数组的增删查改

```
var numbers : [Int] = [1, 2, 3, 4, 5, 6]

/// 增加操作
numbers.append(7)
numbers += [8, 9]        /// 添加一个数组
numbers.insert(0, at: 0) /// 插入一个值到指定索引

/// 删除操作
numbers.removeFirst()
numbers.removeLast()
numbers.remove(at: numbers.count - 1)
numbers.removeSubrange(0...3)    /// 删除某个范围内的元素
numbers.removeAll()

/// 修改操作
numbers[0] += 10    /// 修改某个元素
numbers[0...3] = [10, 11, 12, 14] /// 修改子集
```

## 1.4、多维数组

```
var origin = [[1, 1], [2, 2], [3,3]]
origin.first?.first

/// 显示声明一个二维数组
var origin: [[Int]] = [[1, 1], [2, 2], [3,3]]

/// Swift 二维数组中的长度可以不同
var origin: Array<Array<Int>> = [[1], [1, 2], [1, 2, 3]]

origin += [[1, 2, 3, 4]]
```

## 1.5、`NSArray` 

`NSArray` 与 Swift 中的 `Array` 的最大不同是：`NSArray`可以承载不同的元素类型！ 
* `NSArray` 是一个类，Swift 中的 `Array` 是一个结构；
* 一个使用值的方式传递；一个采用引用的方式传递；
* 虽然都是数组，但有着本质的不同！


```
var rects : NSArray = [1, true, 3.5, "4"]
```


# 2、字典 `Dictionary`

## 2.1、字典的一些声明方法

```
let dict = ["key1":"value1","key2":"value2","key3":"value3"]

let dict : [String: String] = ["key1":"value1","key2":"value2","key3":"value3"]
let dict = [Int: String]()

/// 声明一个空字典
let dict : Dictionary<String, String> = [:]
let dict = Dictionary<String, Int>()
```

## 2.2、字典的常用用法

```
/// 返回一个可选型，返回值可能为 nil
if let value = dict["key"] {
    
}

dict.count
dict.isEmpty
Array(dict.keys)    /// 字典的所有键
Array(dict.values)  /// 字典的所有值

for key in dict.keys {
    print(key)
}

/// 打印键值对
for (key, value) in dict {
    print(key,value)
}

//// 字典的相等性比较：字典是无序的
dict1 == dict2
```

## 2.3、字典的增删改

```
var dict : [String: String] = ["key1":"value1","key2":"value2","key3":"value3"]

/// 修改操作
dict["key1"] = "value1.1"
dict.updateValue("value1.2", forKey: "key1") /// 返回旧值

/// 可以根据返回的旧值做一些逻辑操作
if let oldPwd = dict.updateValue("Hello", forKey: "password"),
   let newPwd = dict["password"], oldPwd == newPwd {
    print("oldPwd: \(oldPwd) == newPwd: \(newPwd), 可能引发安全问题")
}

/// 添加操作
dict["key4"] = "value4"
dict.updateValue("value5", forKey: "key5") /// 可以用来添加新值

/// 删除操作
dict["key5"] = nil
dict.removeValue(forKey: "key4")  /// 返回被删除的值
dict.removeAll()
```

# 3、集合 `Set`

`Set` 是一个无序、无重复的数据集！

## 3.1、集合的一些声明方法

```
/// 声明一个集合：通过显示声明为 Set
var names : Set<String> = ["Tom", "John", "Tom"] /// 系统会自动剔除一个 "Tom"

var ages : Set<Int> = []
var heights = Set<Double>()

/// 将字符串数组强制转为字符串集合
var names = Set(["A", "B", "C", "A", "B", "C"])
```

## 3.2、集合的常用用法

```
var names = Set(["A", "B", "C", "A", "B", "C"])

names.count /// names.count = 3
names.isEmpty
names.first /// 随机取出的元素

names.contains("A") /// 是否包含

set1 == set2 /// 判断相等性
```

## 3.3、集合的增删改

集合中的元素没有修改的 API！

```
var names = Set(["A", "B", "C"])

/// 添加操作
names.insert("D") /// 返回 true
names.insert("D") /// 再次添加，返回 false

/// 删除操作
names.remove("A") /// 返回被删除的元素
names.remove("F") /// 删除不存在的元素，返回 nil
```

## 3.4、集合的并集、交集、补集等

```
var set1 : Set = [1, 2, 3, 4]
var set2 : Set = [3, 4, 5, 6]

/// 计算并集
var set3 = set1.union(set2) /// 原集合不被改变，返回一个新的集合
set1.formUnion(set2) /// 类似于 += 操作，将集合 set2 的元素添加到 set1，集合 set1 被改变
set1.formUnion([10,11,12]) /// 将一个数组传入一个集合

/// 计算交集
var set4 = set1.intersection(set2) /// 原集合不被改变，返回一个新的集合
set1.formIntersection(set2) /// 集合 set1 被改变

/// 计算补集 : 返回 set1 独有而 set2 不具备的元素
var set5 = set1.subtracting(set2) /// 原集合不被改变，返回一个新的集合

set1.isSubset(of: set2)       /// set1 是否是 set2 的子集
set1.isStrictSubset(of: set2) /// set1 是否是 set2 的真子集

set1.isSuperset(of: set2)    ///  set1 是否是 set2 的超集
set1.isStrictSuperset(of: set2)  /// set1 是否是 set2 的真超集

/// 是否相离：没有公共元素
set1.isDisjoint(with: set2)
```
