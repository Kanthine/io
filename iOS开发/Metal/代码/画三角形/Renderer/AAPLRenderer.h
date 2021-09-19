/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for a platform independent renderer class, which performs Metal setup and per frame rendering.
*/

@import MetalKit;

/// 封装一个渲染器
@interface AAPLRenderer : NSObject
<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end
