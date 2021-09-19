/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of our cross-platform view controller
*/

#import "AAPLViewController.h"
#import "AAPLRenderer.h"

@implementation AAPLViewController
{
    MTKView *_view;

    AAPLRenderer *_renderer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _view = (MTKView *)self.view;
    _view.device = MTLCreateSystemDefaultDevice();
    
    NSAssert(_view.device, @"Metal is not supported on this device");
    
    /// 渲染器
    _renderer = [[AAPLRenderer alloc] initWithMetalKitView:_view];
    NSAssert(_renderer, @"Renderer failed initialization");
    
    // Initialize our renderer with the view size
    [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];
        
    _view.delegate = _renderer;
}

@end
