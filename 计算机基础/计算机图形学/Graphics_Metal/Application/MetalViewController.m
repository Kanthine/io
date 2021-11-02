//
//  MetalViewController.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/26.
//

#import "MetalViewController.h"

@implementation MetalViewController

#if defined(TARGET_IOS)

- (UIView *)view {
    return self.mtkView;
}

- (MTKView *)mtkView {
    if (_mtkView == nil) {
        _mtkView = [[MTKView alloc] init];
    }
    return _mtkView;
}

#elif defined(TARGET_MACOS)

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:@"MetalViewController" bundle:nibBundleOrNil];
}

- (MTKView *)mtkView {
    return (MTKView *)self.view;
}

#endif

@end
