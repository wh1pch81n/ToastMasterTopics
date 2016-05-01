//
//  DHAppDelegate.m
//  TMTopic
//
//  Created by Derrick Ho on 5/10/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHAppDelegate.h"
#import "DHViewController.h"
#import "iRate.h"

NSString *const kUDPersistentArrOfTopics = @"kUDPersistentArrOfTopics";
NSString *const kUDLastUpdatedArray = @"kUDLastUpdatedArray";

@implementation DHAppDelegate

+ (void)initialize {
#if DEBUG
    [[iRate sharedInstance] setPreviewMode:YES];
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self registerUserDefaults];
	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	switch ([[UIApplication sharedApplication] backgroundRefreshStatus]) {
		case UIBackgroundRefreshStatusAvailable:
			break;
		default:
			[(DHViewController *)self.window.rootViewController launchAsyncURLCall];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - user defaults

- (void)registerUserDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     @{
       kUDPersistentArrOfTopics:[self defaultArrayOfTopics]
       }];
}

- (NSArray *)defaultArrayOfTopics {
    NSArray *arrOfTableTopics = @[
                                  @"What inspries you?",
                                  @"What books do you like to read?",
                                  @"What would you like to learn?",
                                  @"Who has influenced your life the most?"
								  ];
    
    return arrOfTableTopics;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	DHViewController *vc = [DHViewController new];
	switch ([vc refreshTableTopicsFromOnline]) {
		case 1:
			completionHandler(UIBackgroundFetchResultNewData);
			break;
		case 0:
			completionHandler(UIBackgroundFetchResultNoData);
			break;
		case -1:
			completionHandler(UIBackgroundFetchResultFailed);
			break;
	}
}


@end
