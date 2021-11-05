//
//  ComputeTextureController.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/10.
//

#import "ComputeTextureController.h"
#import "ComputeTextureRender.h"

@interface ComputeTextureController ()
@property (nonatomic ,strong) ComputeTextureRender *render;
@end

@implementation ComputeTextureController

- (void)viewDidLoad {
    [super viewDidLoad];
    _render = [[ComputeTextureRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
}

@end
