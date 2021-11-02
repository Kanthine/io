//
//  AroundNeckController.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "AroundNeckController.h"
#import "AroundNeckRender.h"
#import "PlatformModule.h"

@interface AroundNeckController ()
@property (nonatomic, strong) AroundNeckRender *render;
@end

@implementation AroundNeckController

- (void)viewDidLoad {
    [super viewDidLoad];
    _render = [[AroundNeckRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
    
    [self setSlideView];
}

- (void)setSlideView {
    PlatformSlider *zNearSlider = [PlatformSlider item:@"zNear" minValue:-10 maxValue:20 currentValue:self.render.zNear];
    PlatformSlider *zFarSlider = [PlatformSlider item:@"zFar" minValue:10 maxValue:1000 currentValue:self.render.zFar];
    PlatformSlider *fovSlider = [PlatformSlider item:@"fov" minValue:0 maxValue:M_PI currentValue:self.render.fov];
    PlatformSlider *zPosSlider = [PlatformSlider item:@"zPos" minValue:-10 maxValue:1000 currentValue:self.render.zPos];
    PlatformSlider *txSlider = [PlatformSlider item:@"tx" minValue:-10 maxValue:10 currentValue:self.render.tx];
    PlatformSlider *tySlider = [PlatformSlider item:@"ty" minValue:-10 maxValue:10 currentValue:self.render.ty];
    PlatformSlider *tzSlider = [PlatformSlider item:@"tz" minValue:-10 maxValue:10 currentValue:self.render.tz];
    PlatformSlider *axSlider = [PlatformSlider item:@"ax" minValue:-M_PI maxValue:M_PI currentValue:self.render.ax];
    PlatformSlider *aySlider = [PlatformSlider item:@"ay" minValue:-M_PI maxValue:M_PI currentValue:self.render.ay];
    PlatformSlider *azSlider = [PlatformSlider item:@"az" minValue:-M_PI maxValue:M_PI currentValue:self.render.az];
    
    MatrixSetView *setView = [MatrixSetView viewWithItems:@[zNearSlider,zFarSlider,fovSlider,zPosSlider,txSlider,tySlider,tzSlider,axSlider,aySlider,azSlider]];
    [self.view addSubview:setView];
    
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
    txSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.tx = value;
    };
    tySlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.ty = value;
    };
    tzSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.tz = value;
    };
    axSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.ax= value;
    };
    aySlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.ay= value;
    };
    azSlider.sliderChangeHandle = ^(double value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.render.az= value;
    };
}

@end
