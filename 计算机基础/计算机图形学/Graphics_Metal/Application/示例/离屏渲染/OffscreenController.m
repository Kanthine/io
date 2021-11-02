//
//  OffscreenController.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "OffscreenController.h"
#import "OffscreenRender.h"

@interface OffscreenController ()
@property (nonatomic, strong) OffscreenRender *render;
@end


@implementation OffscreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    _render = [[OffscreenRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
}

@end
