//
//  OBJ_Render_2.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
//
// 三维空间下的观察

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>


@interface OBJ_Render_2 : NSObject
<MTKViewDelegate>
- (nonnull instancetype)initWithMTKView:(nonnull MTKView *)mtkView;
@end

