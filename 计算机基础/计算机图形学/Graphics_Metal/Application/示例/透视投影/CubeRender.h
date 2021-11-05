//
//  CubeRender.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface CubeRender : NSObject
<MTKViewDelegate>

@property (nonatomic, assign) double zNear;
@property (nonatomic, assign) double zFar;
@property (nonatomic, assign) double fov;
@property (nonatomic, assign) double zPos;

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkview;

@end

NS_ASSUME_NONNULL_END
