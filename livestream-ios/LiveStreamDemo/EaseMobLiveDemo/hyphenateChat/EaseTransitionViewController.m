//
//  EaseTransitionViewController.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/3/7.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseTransitionViewController.h"
#import "Masonry.h"
NSString *defaultPwd = @"000000";//默认密码

@interface EaseTransitionViewController ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIImageView *nameImageView;

@end

@implementation EaseTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self placeAndLayoutSubviews];
    self.view.backgroundColor = UIColor.clearColor;
    [self autoRegistAccount];
}

- (void)placeAndLayoutSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.width.equalTo(@(KScreenWidth));
        make.height.equalTo(@(KScreenHeight));
    }];

}


- (void)autoRegistAccount
{

    NSString *uuidAccount = [UIDevice currentDevice].identifierForVendor.UUIDString;
    uuidAccount = [[uuidAccount stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    if (uuidAccount.length >= 8) {
        uuidAccount = [uuidAccount substringToIndex:8];
    }
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [[AgoraChatClient sharedClient] registerWithUsername:uuidAccount password:defaultPwd completion:^(NSString *aUsername, AgoraChatError *aError) {
             [[AgoraChatClient sharedClient] loginWithUsername:(NSString *)uuidAccount password:defaultPwd completion:^(NSString *aUsername, AgoraChatError *aError) {
                 //set avatar url
                 if (aError == nil) {
                     [self setDefaultUseInfo];
                 }else {
                     [self showHint:aError.errorDescription];
                 }
                 
             }];
         }];
     });
}


- (void)setDefaultUseInfo {
        
    [self uploadUserAvatarcompletion:^(NSString *url, BOOL success) {
        AgoraChatUserInfo *userInfo = [[AgoraChatUserInfo alloc] init];
        userInfo.userId = [AgoraChatClient sharedClient].currentUsername;
        userInfo.gender = 1;
        userInfo.birth = @"2004-01-01";

        if (success) {
            userInfo.avatarUrl = url;
        }
        
        [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:userInfo completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 if (!aError) {
                     NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                     [ud setObject:[AgoraChatClient sharedClient].currentUsername forKey:kLiveLastLoginUsername];
                     [ud synchronize];
                     [[AgoraChatClient sharedClient].options setIsAutoLogin:YES];
                     [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@YES];
                }
            });
        }];
    }];
}

- (void)uploadUserAvatarcompletion:(void (^)(NSString *url, BOOL success))aCompletion {
    UIImage *avatarImage = kDefultUserImage;
    NSData *avatarData = UIImageJPEGRepresentation(avatarImage, 1.0);;
     
    [EaseHttpManager.sharedInstance uploadFileWithData:avatarData completion:aCompletion];
}

#pragma mark getter and setter
- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        
        [_contentView addSubview:self.bgImageView];
        [_contentView addSubview:self.logoImageView];
        [_contentView addSubview:self.nameImageView];
        
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView.mas_centerY);
            make.size.equalTo(@(120.0));
        }];

        [self.nameImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-64.0);
            make.width.equalTo(@(100.0));
            make.height.equalTo(@(34.0));
        }];

    }
    
    return _contentView;
}


- (UIImageView *)bgImageView {
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeCenter;
        [_bgImageView setImage:ImageWithName(@"Splash_bg")];
    }
    return _bgImageView;
}

- (UIImageView *)logoImageView {
    if (_logoImageView == nil) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_logoImageView setImage:ImageWithName(@"live_logo")];

    }
    return _logoImageView;
}

- (UIImageView *)nameImageView {
    if (_nameImageView == nil) {
        _nameImageView = [[UIImageView alloc] init];
        _nameImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_nameImageView setImage:ImageWithName(@"agora_logo")];

    }
    return _nameImageView;
}


@end
