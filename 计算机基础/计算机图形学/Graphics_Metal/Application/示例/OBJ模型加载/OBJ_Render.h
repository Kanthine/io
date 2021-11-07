//
//  OBJ_Render.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>


@interface OBJ_Render : NSObject
<MTKViewDelegate>
- (nonnull instancetype)initWithMTKView:(nonnull MTKView *)mtkView;
@end

