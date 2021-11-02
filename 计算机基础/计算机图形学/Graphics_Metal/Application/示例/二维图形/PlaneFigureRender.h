//
//  PlaneFigureRender.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/29.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PlaneFigureType) {
    PlaneFigureTypeHello = 0,
    PlaneFigureTypeTriangle,
    PlaneFigureTypeRhombus,
    PlaneFigureTypeCircle,
    PlaneFigureTypePolarCoordinate,
};

@interface PlaneFigureRender : NSObject
<MTKViewDelegate>

@property (nonatomic, assign) PlaneFigureType figureType;

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
