//
//  GSAppDelegate.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSAppDelegate.h"

#import "GSConnectionsTableController.h"

@implementation GSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    // Instantiate and open a NanoStore
    NSError *error;
    NSString *dbPath = [[self documentsPath] stringByAppendingString:@"/data.database"];
    _nanoStore = [NSFNanoStore createAndOpenStoreWithType:NSFPersistentStoreType path:dbPath error:&error];

    if (error) {
        NSLog(@"NSFNanoStore error: %@", error);
        exit(1);
    }

    // Set the synchronous mode setting
    [_nanoStore nanoStoreEngine].synchronousMode = SynchronousModeOff;

    GSConnectionsTableController *connectionsController;

    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *) self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        connectionsController = (GSConnectionsTableController *) navigationController.topViewController;
    } else {
        UINavigationController *navigationController = (UINavigationController *) self.window.rootViewController;
        connectionsController = (GSConnectionsTableController *) navigationController.topViewController;
    }
    connectionsController.nanoStore = _nanoStore;
    
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

#pragma mark - Utils

- (NSString *)documentsPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
