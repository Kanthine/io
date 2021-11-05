//
//  DepthTestingController.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "DepthTestingController.h"
#import "DepthRender.h"
#import "PlatformModule.h"

@interface DepthTestingController ()
@property (nonatomic, strong) DepthRender *render;
@end

@implementation DepthTestingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _render = [[DepthRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
    [self setSlideView];
}

- (void)setSlideView {
    PlatformSlider *topSlider = [PlatformSlider item:@"上" minValue:0 maxValue:1.0 currentValue:self.render.topVertexDepth];
    PlatformSlider *leftSlider = [PlatformSlider item:@"左" minValue:0.0 maxValue:1.0 currentValue:self.render.leftVertexDepth];
    PlatformSlider *rightSlider = [PlatformSlider item:@"右" minValue:0.0 maxValue:1.0 currentValue:self.render.rightVertexDepth];
    MatrixSetView *setView = [MatrixSetView viewWithItems:@[topSlider,leftSlider,rightSlider]];
    [self.view addSubview:setView];
    
    __weak typeof(self) weakSelf = self;
    topSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.topVertexDepth = value;
    };
    leftSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.leftVertexDepth= value;
    };
    rightSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.rightVertexDepth = value;
    };
}

@end
