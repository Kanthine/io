//
//  LSP_Rifle.swift
//  DesignPattern
//
//  Created by 苏沫离  on 2018/11/13.
//

import Cocoa

class LSP_Rifle: LSP_AbstractGun {
    override func shoot() {
        print("步枪射击")
    }
}


class LSP_Rifle_AK: LSP_Rifle {
    override func shoot() {
        print("AK47步枪射击")
    }
}


class LSP_Rifle_AUG: LSP_Rifle {
    func zoomout() {
        print("通过望远镜观察敌人")
    }
    override func shoot() {
        print("AUG步枪射击")
    }
}
