//
//  main.swift
//  MetalCompute
//
//  Created by 苏沫离 on 2021/9/17.
//

import Foundation
import Metal

if let device : MTLDevice = MTLCreateSystemDefaultDevice() {
    let opeartion = MetalOperation(device: device)
    // 创建数据缓冲区并加载数据
    opeartion.prepareData()
    // 向GPU发送命令执行计算
    opeartion.sendComputeCommand()
}
