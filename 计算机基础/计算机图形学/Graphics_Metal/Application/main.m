//
//  main.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#if defined(TARGET_IOS)

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {

#if TARGET_OS_SIMULATOR && (!defined(__IPHONE_13_0) ||  !defined(__TVOS_13_0))
#error No simulator support for Metal API for this SDK version.  Must build for a device
#endif
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

#elif defined(TARGET_MACOS)

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
    }
    return NSApplicationMain(argc, argv);
}

#endif
