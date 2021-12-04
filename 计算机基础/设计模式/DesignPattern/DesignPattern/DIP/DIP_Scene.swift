//
//  DIP_Scene.swift
//  DesignPattern
//
//  Created by 苏沫离  on 2018/11/13.
//

import Cocoa


// MARK: - 反面案例

class DIP_B_BMW: NSObject {
    func run() {
        print("开动宝马汽车")
    }
}

class DIP_B_Driver: NSObject {
    func drive(car: DIP_B_BMW) {
        car.run()
    }
}

//func DIP_Scene_Test() {
//    let drive = DIP_B_Driver()
//    drive.drive(car: DIP_B_BMW())
//}

// MARK: - 依赖倒置原则

/// 汽车接口
protocol DIP_Car {
    /// 负责跑
    func run()
}

/// 司机接口
protocol DIP_Driver {
    /// 负责驾驶
    func drive(car: DIP_Car)
}

/// C1 驾照的司机
class DIP_Driver_C1: DIP_Driver {
    /// 司机的主要职责就是驾驶汽车
    func drive(car: DIP_Car) {
        car.run()
    }
}

class DIP_BMW: DIP_Car {
    func run() {
        print("宝马车在奔跑")
    }
}

class DIP_SGMW: DIP_Car {
    func run() {
        print("五菱神车在超车")
    }
}

func DIP_Scene_Test() {
    let drive = DIP_Driver_C1()
    drive.drive(car: DIP_BMW())
    drive.drive(car: DIP_SGMW())
}
