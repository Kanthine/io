//
//  OffscreenRender.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface OffscreenRender : NSObject
<MTKViewDelegate>

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
