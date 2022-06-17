//
//  AppDelegate+HyphenateChat.m
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "AppDelegate+HyphenateChat.h"
#import "EaseDefaultDataHelper.h"

#import <AgoraChat/AgoraChatOptions+PrivateDeploy.h>
#import "Reachability.h"



@implementation AppDelegate (HyphenateChat)

- (void)initHyphenateChatSDK
{
    AgoraChatOptions *options = [AgoraChatOptions optionsWithAppkey:Appkey];
    /*
    [options setEnableDnsConfig:NO];
    [options setRestServer:@"a1-hsb.easemob.com"];
    [options setChatPort:6717];
    [options setChatServer:@"106.75.100.247"];*/
    
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"ChatDemoDevPush";
#else
    apnsCertName = @"ChatDemoProPush";

#endif
    options.apnsCertName = apnsCertName;
    options.isAutoAcceptGroupInvitation = NO;
    options.enableConsoleLog = YES;
    
    [[AgoraChatClient sharedClient] initializeSDKWithOptions:options];
    
    [self _setupAppDelegateNotifications];
    
    [self _registerRemoteNotification];
    
    
    BOOL isAutoLogin = [AgoraChatClient sharedClient].isAutoLogin;
    if (isAutoLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@YES];
    } else {
        if (!EaseDefaultDataHelper.shared.isInitiativeLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ELDautoRegistAccount object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@NO];
        }
    }
    
    [[AgoraChatClient sharedClient] addDelegate:self delegateQueue:nil];
}


- (BOOL)conecteNetwork
{
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}


//- (void)doLogin {
//
//    if (![self conecteNetwork]) {
//        [self showAlertControllerWithTitle:@"" message:@"Network disconnected."];
//        return;
//    }
//
//    void (^finishBlock) (NSString *aName, NSString *nickName, AgoraChatError *aError) = ^(NSString *aName, NSString *nickName, AgoraChatError *aError) {
//        if (!aError) {
//            if (nickName) {
//                [AgoraChatClient.sharedClient.userInfoManager updateOwnUserInfo:nickName withType:AgoraChatUserInfoTypeNickName completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
//                    if (!aError) {
//
//                        [[NSNotificationCenter defaultCenter] postNotificationName:ELDUSERINFO_UPDATE  object:aUserInfo userInfo:nil];
//                    }
//                }];
//            }
//
//            [self saveLoginUserInfoWithUserName:aName nickName:nickName];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@YES userInfo:@{@"userName":aName,@"nickName":!nickName ? @"" : nickName}];
//            });
//            return ;
//        }
//
//        NSString *errorDes = NSLocalizedString(@"login.failure", @"login failure");
//        switch (aError.code) {
//            case AgoraChatErrorServerNotReachable:
//                errorDes = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
//                break;
//            case AgoraChatErrorNetworkUnavailable:
//                errorDes = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
//                break;
//            case AgoraChatErrorServerTimeout:
//                errorDes = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
//                break;
//            case AgoraChatErrorUserAlreadyExist:
//                errorDes = NSLocalizedString(@"login.taken", @"Username taken");
//                break;
//            default:
//                errorDes = NSLocalizedString(@"login.failure", @"login failure");
//                break;
//        }
//
//        [self showAlertControllerWithTitle:@"" message:errorDes];
//    };
//
//
//    NSString *userName = @"";
//    NSString *nickName = @"";
//
//    NSDictionary *loginDic = [self getLoginUserInfo];
//    if (loginDic.count > 0) {
//        userName = loginDic[USER_NAME];
//        nickName = loginDic[USER_NICKNAME];
//    }else {
//        userName = @"eld_002";
//        nickName = userName;
//    }
//
//
//    //unify token login
//    [[EaseHttpManager sharedInstance] loginToApperServer:userName nickName:nickName completion:^(NSInteger statusCode, NSString * _Nonnull response) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *alertStr = nil;
//            if (response && response.length > 0 && statusCode) {
//                NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
//                NSString *token = [responsedict objectForKey:@"accessToken"];
//                NSString *loginName = [responsedict objectForKey:@"chatUserName"];
//                NSString *nickName = [responsedict objectForKey:@"chatUserNickname"];
//                if (token && token.length > 0) {
//                    [[AgoraChatClient sharedClient] loginWithUsername:[loginName lowercaseString] agoraToken:token completion:^(NSString *aUsername, AgoraChatError *aError) {
//                        finishBlock(aUsername, nickName, aError);
//                    }];
//                    return;
//                } else {
//                    alertStr = NSLocalizedString(@"login analysis token failure", @"analysis token failure");
//                }
//            } else {
//                alertStr = NSLocalizedString(@"login appserver failure", @"Sign in appserver failure");
//            }
//
//
//            [self showAlertControllerWithTitle:@"" message:alertStr];
//
//        });
//    }];
//
//}



- (void)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
    [alertControler addAction:conform];
    [self.window.rootViewController presentViewController:alertControler animated:YES completion:nil];

}

- (NSDictionary *)getLoginUserInfo {
    NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [shareDefault objectForKey:LAST_LOGINUSER];
    return dic;
}

- (void)saveLoginUserInfoWithUserName:(NSString *)userName nickName:(NSString *)nickName {
    NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = @{USER_NAME:userName,USER_NICKNAME:nickName};
    [shareDefault setObject:dic forKey:LAST_LOGINUSER];
    [shareDefault synchronize];
}



#pragma mark - app delegate notifications
// Listen the life cycle of the system so that it will be passed to the SDK
- (void)_setupAppDelegateNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)appDidEnterBackgroundNotif:(NSNotification*)notif
{
    [[AgoraChatClient sharedClient] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[AgoraChatClient sharedClient] applicationWillEnterForeground:notif.object];
}

#pragma mark - register apns
// regist push
- (void)_registerRemoteNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    //iOS8 regist APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
#endif
}

#pragma mark - App Delegate
// Get deviceToken to pass SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[AgoraChatClient sharedClient] bindDeviceToken:deviceToken];
    });
}

// Regist deviceToken failed,not HyphenateChat SDK Business,generally have something wrong with your environment configuration or certificate configuration
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
//                                                    message:error.description
//                                                   delegate:nil
//                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
//                                          otherButtonTitles:nil];
//    [alert show];
}

@end
