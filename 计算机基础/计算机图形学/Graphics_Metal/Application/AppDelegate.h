//
//  AppDelegate.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//


#if defined(TARGET_IOS)

#import <UIKit/UIKit.h>
#import "ItemsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;

@end


#elif defined(TARGET_MACOS)

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@end

#endif

