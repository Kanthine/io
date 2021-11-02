//
//  ReadTexturePixelController.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/10.
//

#import "ReadTexturePixelController.h"
#import "ReadTexturePixelRender.h"

#if TARGET_IOS
#include <Photos/Photos.h>
#endif

@interface ReadTexturePixelController ()
@property (nonatomic, strong) ReadTexturePixelRender *render;
@property (nonatomic, assign) CGPoint readRegionBegin;
@end

@implementation ReadTexturePixelController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _render = [[ReadTexturePixelRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
}


#pragma mark - Helper : 点击区域选择和渲染方法

/// 获取有效的点击区域
CGRect validateSelectedRegion(CGPoint begin, CGPoint end, CGSize drawableSize) {
    CGRect region;

    //确保 end 点在可绘制区域内
    if (end.x < 0) {
        end.x = 0;
    } else if (end.x > drawableSize.width) {
        end.x = drawableSize.width;
    }
    if (end.y < 0) {
        end.y = 0;
    } else if (end.y > drawableSize.height) {
        end.y = drawableSize.height;
    }
    
    // 确保右下角坐标总是大于左上角
    CGPoint lowerRight; // 右下角
    lowerRight.x = begin.x > end.x ? begin.x : end.x;
    lowerRight.y = begin.y > end.y ? begin.y : end.y;

    CGPoint upperLeft; // 左上角
    upperLeft.x = begin.x < end.x ? begin.x : end.x;
    upperLeft.y = begin.y < end.y ? begin.y : end.y;

    region.origin = upperLeft;
    region.size.width = lowerRight.x - upperLeft.x;
    region.size.height = lowerRight.y - upperLeft.y;

    // 确保宽、高至少为 1
    if (region.size.width < 1) {
        region.size.width = 1;
    }

    if (region.size.height < 1) {
        region.size.height = 1;
    }
    return region;
}

- (void)beginReadRegion:(CGPoint)point {
    _readRegionBegin = point;
    _render.outlineRect = CGRectMake(_readRegionBegin.x, _readRegionBegin.y, 1, 1);
    _render.drawOutline = YES;
}

- (void)moveReadRegion:(CGPoint)point {
    _render.outlineRect = validateSelectedRegion(_readRegionBegin, point, self.mtkView.drawableSize);
}

- (void)endReadRegion:(CGPoint)point {
    _render.drawOutline = NO;

    CGRect readRegion = validateSelectedRegion(_readRegionBegin, point, self.mtkView.drawableSize);

    //读取选定区域的像素
    TagImageParser *image = [_render renderAndReadPixelsFromView:self.mtkView
                                                      withRegion:readRegion];

    /// 保存图片至本地
    {
        NSURL *location;

#if TARGET_MACOS
        // 在macOS中，将读取的像素存储在一个图像文件中，并保存到用户的桌面。
        location = [[NSFileManager defaultManager] homeDirectoryForCurrentUser];
        location = [location URLByAppendingPathComponent:@"Desktop"];
        location = [location URLByAppendingPathComponent:@"ReadPixelsImage.tga"];
        [image saveToTGAFileAtLocation:location];

#else   // 在iOS中，将读取的像素存储在一个图像文件中，并保存到用户的照片库中

        PHPhotoLibrary *photoLib = [PHPhotoLibrary sharedPhotoLibrary];
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined)
        {
            //请求访问用户的照片库：只请求访问一次，然后检索用户的授权状态。
            dispatch_semaphore_t authorizeSemaphore = dispatch_semaphore_create(0);
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    dispatch_semaphore_signal(authorizeSemaphore);
            }];
            
            // 阻塞线程，直到用户完成授权请求且信号量值大于0
            dispatch_semaphore_wait(authorizeSemaphore, DISPATCH_TIME_FOREVER);
        }

        /// //如果用户拒绝访问他们的照片库，他们必须进入他们的iOS设备设置，手动更改这个应用程序的授权状态。
        NSAssert([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized,
            @"You didn't authorize writing to the Photos library. Change status in Settings/ReadPixels.\n");
        location = [[NSFileManager defaultManager] temporaryDirectory];
        location = [location URLByAppendingPathComponent:@"ReadPixelsImage.tga"];
        [image saveToTGAFileAtLocation:location];

        NSError *error;

        [photoLib performChangesAndWait:^{ [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:location]; }
                                  error:&error];
        if (error) {
            NSAssert(0, @"Couldn't add image with to Photos library: %@", error);
        }
#endif
    }
}

#pragma mark - touch method

#if TARGET_MACOS

- (void)viewDidAppear {
    // 让视图控制器成为窗口的第一个响应器，这样它就可以处理Key事件
    [self.mtkView.window makeFirstResponder:self];
}

//接受first responder，这样视图控制器就可以响应UI事件
- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)mouseDown:(NSEvent*)event {
    CGPoint bottomUpPixelPosition = [self.mtkView convertPointToBacking:event.locationInWindow];
    CGPoint topDownPixelPosition = CGPointMake(bottomUpPixelPosition.x,
                                               self.mtkView.drawableSize.height - bottomUpPixelPosition.y);
    [self beginReadRegion:topDownPixelPosition];
}

- (void)mouseDragged:(NSEvent*)event {
    CGPoint bottomUpPixelPosition = [self.mtkView convertPointToBacking:event.locationInWindow];
    CGPoint topDownPixelPosition = CGPointMake(bottomUpPixelPosition.x,
                                               self.mtkView.drawableSize.height - bottomUpPixelPosition.y);
    [self moveReadRegion:topDownPixelPosition];
}

-(void)mouseUp:(NSEvent*)event {
    CGPoint bottomUpPixelPosition = [self.mtkView convertPointToBacking:event.locationInWindow];
    CGPoint topDownPixelPosition = CGPointMake(bottomUpPixelPosition.x,
                                               self.mtkView.drawableSize.height - bottomUpPixelPosition.y);
    [self endReadRegion:topDownPixelPosition];
}

#else

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch *touch = [touches anyObject];
    [self beginReadRegion:[self pointToBacking:[touch locationInView:self.mtkView]]];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch *touch = [touches anyObject];
    [self moveReadRegion:[self pointToBacking:[touch locationInView:self.mtkView]]];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch *touch = [touches anyObject];
    [self endReadRegion:[self pointToBacking:[touch locationInView:self.mtkView]]];
}

//------------------------------------------------------------------------------
// 将视图坐标系中的接触点坐标转换为可绘制的纹理像素坐标
// 视图坐标原点在视图的左上角， 纹理坐标原点也在左上角

- (CGPoint)pointToBacking:(CGPoint)point {
    CGFloat scale = _view.contentScaleFactor;

    CGPoint pixel;

    pixel.x = point.x * scale;
    pixel.y = point.y * scale;

    // 将像素值向下四舍五入，将它们放在一个定义良好的网格上
    pixel.x = (int64_t)pixel.x;
    pixel.y = (int64_t)pixel.y;

    // Add .5 to move to the center of the pixel.
    pixel.x += 0.5f;
    pixel.y += 0.5f;

    return pixel;
}
#endif  


@end
