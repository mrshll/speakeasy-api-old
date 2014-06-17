//
//  FPMAppDelegate.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 5/26/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//
#import <Crashlytics/Crashlytics.h>

#import "UIColor+CustomColors.h"
#import "FPMNetworking.h"
#import "FPMRecordViewController.h"
#import "FPMAuthModalViewController.h"
#import "FPMAppDelegate.h"

@implementation FPMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [Crashlytics startWithAPIKey:@"1a41139c46f6ca7cad9edd61ce5f62ba8d4516b5"];
  BOOL hasCookies = [FPMNetworking loadCookies];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  FPMRecordViewController* recordViewController = [FPMRecordViewController new];
  [self.window setRootViewController:recordViewController];
  self.window.backgroundColor = [UIColor whiteColor];
  self.window.tintColor = [UIColor customBlueColor];
  [self.window makeKeyAndVisible];
  
  if (YES || !hasCookies){
    [self performSelector:@selector(showAuthModal) withObject:nil afterDelay:1.f];
  }
  
  [[UINavigationBar appearance] setTitleTextAttributes:
   @{
     NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:20],
     NSForegroundColorAttributeName: [UIColor customGrayColor]
    }];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [FPMNetworking saveCookies];
}

- (void)showAuthModal {
  FPMAuthModalViewController *authModal = [FPMAuthModalViewController new];
  self.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
  [self.window.rootViewController presentViewController:authModal animated:YES completion:^{
    [authModal presentLoginModal];
  }];
}

@end
