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
    NSAssert(_view.device, @"该设备不支持 Metal");

#if TARGET_IOS
    BOOL supportsLayerSelection = NO;

    /// macOS 系列的 GPU 都支持图层选择，但 iOS 系列的 GPU 仅部分支持
    /// iOS 设备需要判断是否支持 MTLFeatureSet_iOS_GPUFamily5_v1
    supportsLayerSelection = [_view.device supportsFeatureSet:MTLFeatureSet_iOS_GPUFamily5_v1];

    NSAssert(supportsLayerSelection, @"Sample requires iOS_GPUFamily5_v1 for Layer Selection");
#endif
    
    _renderer = [[AAPLRenderer alloc] initWithMetalKitView:_view];
    NSAssert(_renderer, @"Renderer failed initialization");
    [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];
    _view.delegate = _renderer;
}

#if defined(TARGET_IOS)
- (BOOL)prefersHomeIndicatorAutoHidden
{
    return YES;
}
#endif

@end
