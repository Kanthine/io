//
//  AroundNeckRender.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface AroundNeckRender : NSObject
<MTKViewDelegate>

@property (nonatomic, assign) double zNear;
@property (nonatomic, assign) double zFar;
@property (nonatomic, assign) double fov;
@property (nonatomic, assign) double zPos;
@property (nonatomic, assign) double tx;
@property (nonatomic, assign) double ty;
@property (nonatomic, assign) double tz;
@property (nonatomic, assign) double ax;
@property (nonatomic, assign) double ay;
@property (nonatomic, assign) double az;

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkview;

@end

NS_ASSUME_NONNULL_END
