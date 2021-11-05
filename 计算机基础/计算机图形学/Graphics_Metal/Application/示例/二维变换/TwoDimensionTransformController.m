//
//  TwoDimensionTransformController.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/29.
//

#import "TwoDimensionTransformController.h"
#import "TwoDimensionTransformRender.h"
#import "PlatformModule.h"

@interface TwoDimensionTransformController ()
@property (nonatomic, strong) TwoDimensionTransformRender *render;
@property (nonatomic, strong) MatrixSetView *setView;
@end

@implementation TwoDimensionTransformController

- (void)viewDidLoad {
    [super viewDidLoad];
    _render = [[TwoDimensionTransformRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
    [self setSlideView];
}

- (void)setSlideView {
    PlatformSlider *xSlider = [PlatformSlider item:@"Tx" minValue:-500 maxValue:500 currentValue:0];
    PlatformSlider *ySlider = [PlatformSlider item:@"Ty" minValue:-500 maxValue:500 currentValue:0];
    PlatformSlider *rSlider = [PlatformSlider item:@"Rotate" minValue:-M_PI * 2.0 maxValue:M_PI * 2.0 currentValue:0];
    PlatformSlider *sSlider = [PlatformSlider item:@"Scale" minValue:0.00001 maxValue:30 currentValue:1.0];
    _setView = [MatrixSetView viewWithItems:@[xSlider,ySlider,rSlider,sSlider]];
    [self.view addSubview:_setView];
    
    __weak typeof(self) weakSelf = self;
    xSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.tx = value;
    };
    ySlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.ty= value;
    };
    rSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.rotate = value;
    };
    sSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.scale = value;
    };
}

@end
