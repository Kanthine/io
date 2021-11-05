//
//  PrimitiveTypeViewController.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
//

#import "MetalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PrimitiveTypeViewController : MetalViewController

@end

NS_ASSUME_NONNULL_END

/** 测试 图元类型 MTLPrimitiveType 的实现
 *  注意：绘制顺序按顶点传入顺序
 *
 * 绘制顶点
 * @value MTLPrimitiveTypePoint
 *
 * 每两个点栅格化一条线，产生一系列未连接的线；如果顶点数量为奇数，则忽略最后一个顶点
 * @value MTLPrimitiveTypeLine
 *
 * 相邻顶点之间栅格化一条线，产生一系列连接的线；也称为折线
 * @value MTLPrimitiveTypeLineStrip
 *
 * 每三个顶点栅格化一个三角形；如果顶点数不是三的倍数，则忽略一个或两个顶点
 * @value MTLPrimitiveTypeTriangle
 *
 * 每三个相邻顶点，栅格化一个三角形
 * @value MTLPrimitiveTypeTriangleStrip
 */
