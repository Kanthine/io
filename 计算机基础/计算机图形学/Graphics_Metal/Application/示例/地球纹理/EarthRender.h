//
//  EarthRender.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/29.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface EarthRender : NSObject
<MTKViewDelegate>

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkview;

@end

NS_ASSUME_NONNULL_END
