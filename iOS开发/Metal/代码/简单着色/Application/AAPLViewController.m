/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of the cross-platform view controller.
*/

#import "AAPLViewController.h"
#import "AAPLRenderer.h"

@implementation AAPLViewController
{
    MTKView *_view;

    AAPLRenderer *_renderer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _view = (MTKView *)self.view;
    
    /// 内容更新时，重绘视图
    _view.enableSetNeedsDisplay = YES;
    
    /// 首先将视图的 device 属性设置为现有的 MTLDevice
    _view.device = MTLCreateSystemDefaultDevice();
    
    /// 当创建渲染通道描述符时，用来清除颜色目标的颜色。
    _view.clearColor = MTLClearColorMake(227/255.0, 237/255.0, 205/255.0, 1.0);
    
    _renderer = [[AAPLRenderer alloc] initWithMetalKitView:_view];
    
    if(!_renderer) {
        NSLog(@"Renderer initialization failed");
        return;
    }
    
    // Initialize the renderer with the view size.
    [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];
    _view.delegate = _renderer;
}

@end
