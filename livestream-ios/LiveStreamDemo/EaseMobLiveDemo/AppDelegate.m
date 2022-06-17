//
//  AppDelegate.m
//
//  Created by yisanmao on 15/10/21.
//  Copyright (c) 2015年 zmw. All rights reserved.
//

#import "AppDelegate.h"

#import "AppDelegate+HyphenateChat.h"
#import "EaseLoginViewController.h"
#import "EaseMainViewController.h"
#import "EaseTransitionViewController.h"

//#import <AgoraStreamingKit/AgoraStreamingKit.h>

#import "ELDAppStyle.h"
#import "EaseHttpManager.h"
#import "ELDPreLivingViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [ELDAppStyle shareAppStyle];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:ELDloginStateChange
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autoRegistAccount)
                                                 name:ELDautoRegistAccount
                                               object:nil];
        
    
    //初始化环信sdk
    [self initHyphenateChatSDK];
                    
    [self.window makeKeyAndVisible];
        
    return YES;
}


- (void)loadMainView {
    EaseMainViewController *main = [[EaseMainViewController alloc] init];
    self.mainVC = main;
    self.window.rootViewController = main;
}

- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];
    if (loginSuccess) {
        
        EaseMainViewController *main = [[EaseMainViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:main];
        
        _mainVC = main;
        self.window.rootViewController = nav;
        
    }
    else{
        _mainVC = nil;
        UINavigationController *navigationController = nil;
        EaseLoginViewController *login = [[EaseLoginViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:login];
        self.window.rootViewController = navigationController;
    }
    [self.window makeKeyAndVisible];
}

- (void)autoRegistAccount
{
    EaseTransitionViewController *transtionController = [[EaseTransitionViewController alloc]init];
    _mainVC = nil;
    UINavigationController *navigationController = nil;
    navigationController = [[UINavigationController alloc] initWithRootViewController:transtionController];
    self.window.rootViewController = navigationController;
}


#pragma mark - AgoraChatClientDelegate
- (void)autoLoginDidCompleteWithError:(AgoraChatError *)aError
{
    if (aError) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"hint" message:@"Failed to log in automatically, please log in again" delegate:self cancelButtonTitle:@"confirm" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)userAccountDidLoginFromOtherDevice
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"hint" message:@"Your account is already logged in elsewhere" delegate:self cancelButtonTitle:@"confirm" otherButtonTitles:nil, nil];
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@NO];
}

- (void)userAccountDidRemoveFromServer
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"hint" message:@"Your account has been removed from the server" delegate:self cancelButtonTitle:@"confirm" otherButtonTitles:nil, nil];
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@NO];
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
    
    UIViewController *currentVC = [ELDUtil topViewController];
    NSLog(@"%s currentVC.class:%@",__func__,NSStringFromClass([currentVC class]));
    if ([currentVC isKindOfClass:[ELDPreLivingViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ELDPreViewActiveFromBackgroudNotification object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
//    NSLog(@"%@", notification.alertBody);
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
//    if (self.vc.playerManager)
//    {
//        return self.vc.playerManager.supportInterOrtation;
//    }
//    else
//    {
//        return UIInterfaceOrientationMaskPortrait;
//    }
    return UIInterfaceOrientationMaskPortrait;
}


@end
