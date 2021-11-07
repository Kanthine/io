//
//  OBJ_Render_1.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
//
// 二维空间的渲染

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>


@interface OBJ_Render_1 : NSObject
<MTKViewDelegate>
- (nonnull instancetype)initWithMTKView:(nonnull MTKView *)mtkView;
@end

