//
//  EarthViewController.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/29.
//

#import "EarthViewController.h"
#import "EarthRender.h"

@implementation EarthViewController{
    EarthRender *_render;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _render = [[EarthRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
}

@end
