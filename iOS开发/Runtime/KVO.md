#### 1、什么是 KVO

* KVO 是 Key-Value observing 的缩写
* KVO 是 Objective-C 中观察者模式的又一实现
* KVO 使用了 isa 混写 `isa-swizzing` 来实现 


#### 2、KVO 如何实现？

isa 混写技术在 KVO  中如何体现？当调用 `-addObserver:forKeyPath:` 方法之后，系统会在运行时动态创建一个 `NSKVONitifying_A` 的类，同时将原来的类 `A` 的 `isa` 指针指向新创建的  `NSKVONitifying_A` ！
`NSKVONitifying_A` 实质上是 类 `A`  的子类，重新了 `-setter` 方法，实现了通知所有观察者的目的！ 

#### 3、总结

* 使用  `-setter`  改变值，KVO 可以生效
* 使用   `-setValue:forkey:` 改变值， KVO 可以生效
* 成员变量直接修改需要手动添加 `-willChange`/`-didChange` ， KVO 可以生效




#### 4、什么是 KVC

* KVC 是 Key-Value coding 的缩写

```
/** 流程
 * 1、是否有 -get 方法？
 *   -getKey | key | isKey |    
 * 2、是否有对应的成员变量？
 *    _key | _isKey | key | isKey
 * 3、调用 -valueForUndefinedKey: 抛出异常 
 */
- (nullable id)valueForKey:(NSString *)key;

/** 流程
 * 1、是否有 -set 方法？
 *   -setKey | key | isKey |    
 * 2、是否有对应的成员变量？
 *    _key | _isKey | key | isKey
 * 3、调用 -setValue:forUndefinedKey: 抛出异常 
 */
- (void)setValue:(nullable id)value forKey:(NSString *)key;
```

KVC 是否遵循了面向对象编程的思想？  通过 KVC 设置了私有变量的值，这种功能破坏了面向对象编程的思想！



#### 属性关键字

* 读写权限 : `readonly`、`readwrite`
* 原子性 ： `nonatomic`、`atomic`
* 引用计数: `retain\strong` 、`assign\unsafe_unretained` 、`weak`、`copy`

`assign`  与 `weak` 的区别：
* `assign`  修饰基本数据类型；
* `assign` 修饰对象类型、不改变引用计数； 
* `assign` 修饰对象类型，被释放后仍指向原对象地址，可能导致悬挂指针；
*  `weak` 修饰对象类型、不改变引用计数；
*  `weak` 修饰对象类型，在被释放后会自动置为 `nil`；

