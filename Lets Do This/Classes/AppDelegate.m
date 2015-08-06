//
//  AppDelegate.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "DSOAPI.h"
#import <Parse/Parse.h>
#import "LDTLoadingViewController.h"
#import "LDTUserConnectViewController.h"
#import "LDTTheme.h"
#import "LDTMessage.h"
#import "LDTNavigationController.h"
#import "LDTTabBarController.h"
#import "DSOUserManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	[Fabric with:@[CrashlyticsKit]];
	
    NSDictionary *keysDictionary = [DSOUserManager keysDict];

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    [Parse setApplicationId:keysDictionary[@"parseApplicationId"] clientKey:keysDictionary[@"parseClientKey"]];
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[LDTLoadingViewController alloc] initWithNibName:@"LDTLoadingView" bundle:nil];
    [self.window makeKeyAndVisible];

    if (![[DSOUserManager sharedInstance] userHasCachedSession]) {

        [self displayUserConnectVC];

    }
    else {

        [[DSOUserManager sharedInstance] connectWithCachedSessionWithCompletionHandler:^(DSOUser *user) {

            [self.window.rootViewController presentViewController:[[LDTTabBarController alloc] init] animated:YES completion:nil];

        } errorHandler:^(NSError *error) {

            [self displayUserConnectVC];
            [LDTMessage errorMessage:error];

        }];
    }
    return YES;
}

- (void)displayUserConnectVC {
    LDTNavigationController *navVC = [[LDTNavigationController alloc]initWithRootViewController:[[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil]];
    [self.window.rootViewController presentViewController:navVC animated:YES completion:nil];
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
