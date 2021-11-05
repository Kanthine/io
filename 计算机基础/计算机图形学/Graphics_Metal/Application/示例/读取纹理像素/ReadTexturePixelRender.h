//
//  ReadTexturePixelRender.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/10.
//

#import <Foundation/Foundation.h>
@import MetalKit;
#import "ImageParser.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReadTexturePixelRender : NSObject
<MTKViewDelegate>

@property (nonatomic, assign) BOOL drawOutline;
@property (nonatomic, assign) CGRect outlineRect;

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkview;

- (nonnull TagImageParser *)renderAndReadPixelsFromView:(nonnull MTKView *)view withRegion:(CGRect)region;

@end

NS_ASSUME_NONNULL_END
