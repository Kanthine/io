import UIKit
import Foundation

struct YLRect {
    var x : Double = 0.0
    var y : Double = 0.0
    var z : Double = 0.0
    
    /// 自定义下标
    subscript(index : Int) -> Double? {
        get {
            switch index {
            case 0 : return x
            case 1 : return y
            case 2 : return z
            default: return nil
            }
        }
        set {
            guard let value = newValue else{ return }
            switch index {
            case 0 : x = value
            case 1 : y = value
            case 2 : z = value
            default: return
            }
        }
    }
    subscript(index : String) -> Double? {
        switch index {
        case "x","X" : return x
        case "y","Y" : return y
        case "z","Z" : return z
        default: return nil
        }
    }
}

func + (left : YLRect, right : YLRect) -> YLRect {
    return YLRect.init(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}
    
func - (left : YLRect, right : YLRect) -> YLRect {
    return YLRect.init(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}
    
postfix operator +++
postfix func +++( rect : inout YLRect) {
    rect = YLRect.init(x: rect.x + 1, y: rect.y + 1, z: rect.z + 1)
}

precedencegroup MyPower{
    associativity : right ///有结合
    lowerThan : AdditionPrecedence /// 优先级低于加法
}

    

var rect1 = YLRect.init(x: 1, y: 2, z: 3)
rect1[0]
rect1[1]
rect1[2]
rect1[3]

rect1+++


rect1[0] = 10


rect1["x"]
rect1["Y"]
rect1["a"]


var rect2 = YLRect.init(x: 30, y: 40, z: 50)
rect1 + rect2
rect1 - rect2

infix operator **** : MyPower
func ****(left : Double, right : Double) -> Double {
    return pow(left, right)
}

2 **** 3
//3 **** 2



class YLDay {
    var day : Int = 0
    init(day:Int) {
        self.day = day
    }
}

extension YLDay {
    var time : Int{
        set {
            day = newValue / 10
        }
        get {
            return day * 10
        }
    }
    convenience init(time : Int) {
        self.init(day: time / 10)
    }
    
    func getTime() {
        print(time)
    }
    func setTime(time : Int) {
        self.time = time
        print(day)
    }
}


var day = YLDay.init(time: 100)
day.getTime()
day.setTime(time: 1000)
day.getTime()

var ind : String.Index = "s".startIndex


extension Int {
    var square : Int {
        return self * self
    }
    var cube : Int {
        return self * self * self
    }
}

var ab : Int = 10
ab.square
ab.cube

func swapThings<T>(_ a : inout T, _ b : inout T){
    (a , b) = (b , a)
}

var a = 10
var b = 20
swapThings(&a, &b)
a
b


struct Pair<T1, T2> {
    var a : T1
    var b : T2
}

var p : Pair<Int, String> = Pair.init(a: 1, b: "b")


protocol pA : CustomStringConvertible {
    var desA : String { get }
    func desAInfo() -> String
}

protocol pB : CustomStringConvertible {
    var desB : String { get }
    func desBInfo()
}

protocol pC : pA, pB {
    
}

extension pA {
    var desA : String {
        return "协议A"
    }
    var description: String {
        return NSDate().description + " 协议A"
    }
    func desAInfo() -> String {
        return "这是协议A的默认实现"
    }
}

extension pB {
    var desB : String {
        return "协议B"
    }
    var description: String {
        return NSDate().description + " Class"
    }
    func desBInfo(){
        print("这是协议B的默认实现")
    }
}


extension pA where Self : pB {
    var desA : String {
        return "协议A+B"
    }
    var description: String {
        return NSDate().description + " Class"
    }
    func desAInfo() -> String{
        return "这是协议A+B的默认实现"
    }
}

class A : pA, pB {
    var name : String = "ClassA"
    func test() {
        print(desAInfo())
    }
}

/// 参数实现了 pA 与 pB 协议 （协议聚合）
func tesss(name : pA & pB){
    
}

/// Protocol 'Comparable' can only be used as a generic constraint because it has Self or associated type requirements
//func qwsdfg(name : [Comparable]) -> Comparable{
//    return name as! Comparable
//}

/// 参数是一个数组
func tesssqw<T : Comparable & CustomStringConvertible>(name : [T]) -> T{
    
    return name as! T
}

var cA = A()
cA.desAInfo()
cA.test()
print(cA)



func maxOne<T : Comparable>(array:[T]) -> T {
    assert(array.count > 0)
    return array.reduce(array[0]){max($0, $1)}
}

maxOne(array: [1,2,3,4,6,7,8,5])

//assert(1 > 0)
//assertionFailure("强制中断")
