//
//  ELDContactView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/11.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseSubView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ELDUserInfoViewDelegate <NSObject>
- (void)showAlertWithTitle:(NSString *)title  messsage:(NSString *)messsage actionType:(ELDMemberActionType)actionType;

- (void)updateLiveViewWithChatroom:(AgoraChatroom *)chatroom error:(AgoraChatError *)error;


@end


@interface ELDUserInfoView : EaseBaseSubView
@property (nonatomic, weak) id<ELDUserInfoViewDelegate> userInfoViewDelegate;

//from member list
- (instancetype)initWithUsername:(NSString *)username
                        chatroom:(AgoraChatroom *)chatroom
                    memberVCType:(ELDMemberVCType)memberVCType;

//check owner userinfo
- (instancetype)initWithOwnerId:(NSString *)ownerId
                       chatroom:(AgoraChatroom *)chatroom;


- (void)confirmActionWithActionType:(ELDMemberActionType)actionType;


@end

NS_ASSUME_NONNULL_END
