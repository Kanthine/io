//
//  LoD_Scene.swift
//  DesignPattern
//
//  Created by 苏沫离 on 2018/11/13.
//

import Foundation


// MARK: - 反面案例

class Student {
    var leave : Bool = (arc4random() % 2 == 0)
}

class GroupLeader {
    
    func actualCounts(student: [Student]) -> Int {
        func isLeave(stu:Student) -> Bool {
            return stu.leave
        }
        return student.filter(isLeave).count
    }
}

class Teacher {
    func request(leader:GroupLeader) {
        var students : [Student] = []
        while students.count < 30 {
            let stu = Student()
            stu.leave = (arc4random() % 2 == 0)
            students.append(stu)
        }
        let actualCounts = leader.actualCounts(student: students)
        print("实到人数 \(actualCounts)")
    }
}


// MARK: - 修改案例

class Lod_GroupLeader {
    var student: [Student]
    init(student: [Student]) {
        self.student = student
    }
    
    func actualCounts() -> Int {
        func isLeave(stu:Student) -> Bool {
            return stu.leave
        }
        return student.filter(isLeave).count
    }
}

class LoD_Teacher {
    func request(leader:Lod_GroupLeader) {
        let actualCounts = leader.actualCounts()
        print("实到人数 \(actualCounts)")
    }
}

//func LoD_Scene_Test() {
//
//    var students : [Student] = []
//    while students.count < 30 {
//        let stu = Student()
//        stu.leave = (arc4random() % 2 == 0)
//        students.append(stu)
//    }
//
//    let teacher = LoD_Teacher()
//    teacher.request(leader: Lod_GroupLeader(student: students))
//}


protocol Lod_People {
    func rest()
    func askPeople(people:Lod_People)
}

extension Lod_People {
    func askPeople(people:Lod_People)  {
        people.rest()
    }
}

class Lod_People_1: Lod_People {
    private func sleep_weekend() {
        print("睡到中午")
    }
    private func eat(){
        print("通宵撸个串")
    }
    
    func rest() {
        eat()
        sleep_weekend()
    }
}

class Lod_People_2: Lod_People {

    private func study() {
        print("好好学习")
    }
    func rest() {
        study()
    }
}

func LoD_Scene_Test() {    
    let p1 = Lod_People_1()
    let p2 = Lod_People_2()
    p2.askPeople(people: p1)
    p1.askPeople(people: p2)
}
