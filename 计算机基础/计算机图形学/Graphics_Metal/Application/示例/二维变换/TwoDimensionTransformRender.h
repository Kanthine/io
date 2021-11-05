//
//  TwoDimensionTransformRender.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/29.
//

#import <Foundation/Foundation.h>
@import MetalKit;
NS_ASSUME_NONNULL_BEGIN

@interface TwoDimensionTransformRender : NSObject
<MTKViewDelegate>

@property (nonatomic, assign) double tx;
@property (nonatomic, assign) double ty;
@property (nonatomic, assign) double scale;
@property (nonatomic, assign) double rotate;

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
