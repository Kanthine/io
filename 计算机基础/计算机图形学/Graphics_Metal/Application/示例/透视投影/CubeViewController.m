//
//  CubeViewController.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "CubeViewController.h"
#import "CubeRender.h"
#import "PlatformModule.h"

@interface CubeViewController ()
@property (nonatomic, strong) CubeRender *render;
@property (nonatomic, strong) MatrixSetView *setView;
@end

@implementation CubeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _render = [[CubeRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
    
    [self setSlideView];
}

- (void)setSlideView {
    PlatformSlider *zNearSlider = [PlatformSlider item:@"zNear" minValue:-10 maxValue:20 currentValue:self.render.zNear];
    PlatformSlider *zFarSlider = [PlatformSlider item:@"zFar" minValue:10 maxValue:1000 currentValue:self.render.zFar];
    PlatformSlider *fovSlider = [PlatformSlider item:@"fov" minValue:0 maxValue:M_PI currentValue:self.render.fov];
    PlatformSlider *zPosSlider = [PlatformSlider item:@"zPos" minValue:-10 maxValue:1000 currentValue:self.render.zPos];
    _setView = [MatrixSetView viewWithItems:@[zNearSlider,zFarSlider,fovSlider,zPosSlider]];
    [self.view addSubview:_setView];
    
    __weak typeof(self) weakSelf = self;
    zNearSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.zNear = value;
    };
    zFarSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.zFar = value;
    };
    fovSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.fov = value;
    };
    zPosSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.zPos= value;
    };
}

@end
