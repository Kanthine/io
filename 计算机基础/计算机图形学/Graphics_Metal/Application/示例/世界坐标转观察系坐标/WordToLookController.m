//
//  WordToLookController.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "WordToLookController.h"
#import "WordToLookRender.h"
#import "PlatformModule.h"

@interface WordToLookController ()
@property (nonatomic, strong) WordToLookRender *render;
@end

@implementation WordToLookController

- (void)viewDidLoad {
    [super viewDidLoad];
    _render = [[WordToLookRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
    
    [self setSlideView];
}

- (void)setSlideView {
    PlatformSlider *txSlider = [PlatformSlider item:@"tx" minValue:-20 maxValue:20 currentValue:self.render.tx];
    PlatformSlider *tySlider = [PlatformSlider item:@"ty" minValue:-20 maxValue:20 currentValue:self.render.ty];
    PlatformSlider *tzSlider = [PlatformSlider item:@"tz" minValue:-20 maxValue:20 currentValue:self.render.tz];
    PlatformSlider *axSlider = [PlatformSlider item:@"ax" minValue:-M_PI * 2.0 maxValue:M_PI * 2.0 currentValue:self.render.ax];
    PlatformSlider *aySlider = [PlatformSlider item:@"ay" minValue:-M_PI * 2.0 maxValue:M_PI * 2.0 currentValue:self.render.ay];
    PlatformSlider *azSlider = [PlatformSlider item:@"az" minValue:-M_PI * 2.0 maxValue:M_PI * 2.0 currentValue:self.render.az];
    
    MatrixSetView *setView = [MatrixSetView viewWithItems:@[txSlider,tySlider,tzSlider,axSlider,aySlider,azSlider]];
    [self.view addSubview:setView];
    
    __weak typeof(self) weakSelf = self;
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
