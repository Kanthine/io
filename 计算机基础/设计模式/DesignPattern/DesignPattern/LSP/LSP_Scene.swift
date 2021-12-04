//
//  LSP_Scene.swift
//  DesignPattern
//
//  Created by 苏沫离  on 2018/11/13.
//

import Cocoa

/// 使用场景测试
func LSP_Scene_Test() {
    let guns: [LSP_AbstractGun] = [
        LSP_Handgun(),
        LSP_Rifle(),
        LSP_Rifle_AK(),
        LSP_Rifle_AUG(),
        LSP_MachineGun(),
    ]
    for gun:LSP_AbstractGun in guns {
        let tom : LSP_Solider = LSP_Solider.init(name: "Tom")
        tom.giveGun(gun: gun)
        tom.killEnemy()
    }
    
    let john: LSP_Solider_Sniper = LSP_Solider_Sniper.init(name: "John")
    john.giveGun(gun: LSP_Rifle_AUG())
    john.killEnemy()
}
