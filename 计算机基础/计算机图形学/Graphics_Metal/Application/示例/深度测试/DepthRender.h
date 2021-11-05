//
//  DepthRender.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import <Foundation/Foundation.h>
@import MetalKit;
NS_ASSUME_NONNULL_BEGIN

@interface DepthRender : NSObject
<MTKViewDelegate>

// 三角形的三个顶点的深度值
@property (nonatomic, assign) float topVertexDepth;
@property (nonatomic, assign) float leftVertexDepth;
@property (nonatomic, assign) float rightVertexDepth;

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
