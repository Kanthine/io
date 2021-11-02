//
//  PrimitiveTypeRender.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
//

@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface PrimitiveTypeRender : NSObject
<MTKViewDelegate>

@property (nonatomic ,assign) MTLPrimitiveType  primitiveType;

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
