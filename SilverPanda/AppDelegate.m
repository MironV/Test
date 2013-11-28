//
//  AppDelegate.m
//  SilverPanda
//
//  Created by Miron Vranjes on 11/16/13.
//  Copyright (c) 2013 Miron Vranjes. All rights reserved.
//

#import "AppDelegate.h"
#import "Friend.h"
#import "FriendsViewController.h"

@implementation AppDelegate
{
NSMutableArray *friends;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
	UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
	FriendsViewController *friendsViewController = [[navigationController viewControllers] objectAtIndex:0];

    RKObjectMapping* friendMapping = [RKObjectMapping mappingForClass:[Friend class]];
    [friendMapping addAttributeMappingsFromArray:@[@"first", @"last"]];
     
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:friendMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"users" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    //NSURL *URL = [NSURL URLWithString:@"http://silverpanda.herokuapp.com/userlist"];
    
    NSURL *URL = [NSURL URLWithString:@"http://169.254.207.230:5000/userlist"];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        friendsViewController.friends = [mappingResult.array mutableCopy];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFriends"
                                                            object:nil];
        RKLogInfo(@"Load collection of Friends: %@", mappingResult.array);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
    }];
    
    [objectRequestOperation start];
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
