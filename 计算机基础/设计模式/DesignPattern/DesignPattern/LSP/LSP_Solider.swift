//
//  LSP_Solider.swift
//  DesignPattern
//
//  Created by 苏沫离  on 2018/11/13.
//

import Cocoa

/// 士兵类
class LSP_Solider: NSObject {
    let name: String!
    var gun : LSP_AbstractGun?
    
    init(name: String) {
        self.name = name
    }
    
    func giveGun(gun: LSP_AbstractGun) {
        self.gun = gun
    }
    
    func killEnemy() {
        guard let gun = self.gun, let name = name else {
            print("无名士兵没有获取枪支")
            return
        }
        print("士兵\(String(describing: name))杀敌")
        gun.shoot()
    }
}


class LSP_Solider_Sniper: LSP_Solider {
    
    override func killEnemy() {
        guard let gun = self.gun, let name = name else {
            print("无名士兵没有获取枪支")
            return
        }
        if gun.isKind(of: LSP_Rifle_AUG.self) {
            let gun : LSP_Rifle_AUG = gun as! LSP_Rifle_AUG
            print("狙击手\(String(describing: name))杀敌")
            gun.zoomout()
            gun.shoot()
        } else {
            print("狙击手\(String(describing: name))杀敌")
            gun.shoot()
        }

    }
}
