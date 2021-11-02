//
//  SineViewController.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "SineViewController.h"
#import "SineRender.h"

@interface SineViewController ()
{
    SineRender *_render;
}
@end

@implementation SineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _render = [[SineRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
}

@end
