//
//  MetalViewController.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/26.
//

@import MetalKit;

#if defined(TARGET_IOS)
@import UIKit;
@interface MetalViewController : UIViewController
@property (nonatomic ,strong) MTKView *mtkView;
@end

#elif defined(TARGET_MACOS)

#import <Cocoa/Cocoa.h>
@interface MetalViewController : NSViewController
@property (nonatomic ,strong) MTKView *mtkView;
@end

#endif
