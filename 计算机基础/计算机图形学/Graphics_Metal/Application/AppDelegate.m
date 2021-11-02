//
//  AppDelegate.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "AppDelegate.h"
#import "MetalViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#if defined(TARGET_IOS)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ItemsViewController alloc] init]];
    nav.navigationBar.translucent = NO;
    self.window.rootViewController = nav;
    return YES;
}

#elif defined(TARGET_MACOS)


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
#endif


@end
