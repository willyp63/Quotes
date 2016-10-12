//
//  AppDelegate.m
//  Quotes
//
//  Created by Wil Pirino on 10/8/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "AppDelegate.h"
#import "A0SimpleKeychain.h"
#import "AuthApiUtil.h"
#import "constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // check for token in keychain
    NSString *token = [[A0SimpleKeychain keychain] stringForKey:@"user-jwt"];
    if (token && ![token isEqualToString:@""]) {
        
        // make api request
        NSLog(@"attempting to authorize launch");
        [AuthApiUtil refreshWithCompletionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
            if (!error) {
                // check token
                NSString *newToken = [jsonData objectForKey:@"token"];
                if (newToken) {
                    // Success
                    NSLog(@"successfully authorized launch!!");
                    
                    // save new token
                    [[A0SimpleKeychain keychain] setString:newToken forKey:JWT_KEY];
                    
                    // goto feed
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.window.rootViewController = [sb instantiateViewControllerWithIdentifier:@"TabCtrl"];
                    });
                } else {
                    // goto register
                    NSLog(@"No Response Token");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.window.rootViewController = [sb instantiateViewControllerWithIdentifier:@"Register"];
                    });
                }
            } else {
                // goto register
                NSLog(@"Error Connecting to refresh endpoint: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.window.rootViewController = [sb instantiateViewControllerWithIdentifier:@"Register"];
                });
            }
        }];
    } else {
        // goto register
        self.window.rootViewController = [sb instantiateViewControllerWithIdentifier:@"Register"];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
