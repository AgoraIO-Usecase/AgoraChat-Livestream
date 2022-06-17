//
//  ELDContactView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/11.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDUserInfoView.h"
#import "ELDTitleSwitchCell.h"
#import "ELDUserInfoHeaderView.h"
#import "ELDTitleDetailCell.h"

#define kUserInfoCellTitle @"kUserInfoCellTitle"
#define kUserInfoCellActionType @"kUserInfoCellActionType"
#define kUserInfoAlertTitle @"kUserInfoAlertTitle"

#define kMuteAll @"All timed out"

#define kUserInfoCellHeight 44.0
#define kHeaderViewHeight 154.0

@interface ELDUserInfoView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) ELDUserInfoHeaderView *headerView;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) ELDTitleSwitchCell *muteCell;

@property (nonatomic, strong) AgoraChatUserInfo *userInfo;
@property (nonatomic, strong) NSString *currentUsername;
@property (nonatomic, strong) AgoraChatroom *chatroom;
@property (nonatomic, assign) ELDMemberRoleType beOperationedMemberRoleType;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableDictionary *actionTypeDic;

//owner check oneself
@property (nonatomic, assign) BOOL ownerSelf;

//whether isMute
@property (nonatomic, assign) BOOL isMute;

//whether isBlock
@property (nonatomic, assign) BOOL isBlock;

//whether isWhite
@property (nonatomic, assign) BOOL isWhite;


@property (nonatomic, assign) ELDMemberVCType memberVCType;

@property (nonatomic, strong) NSString *displayName;

@end


@implementation ELDUserInfoView
- (instancetype)initWithUsername:(NSString *)username
                        chatroom:(AgoraChatroom *)chatroom
                    memberVCType:(ELDMemberVCType)memberVCType {
    self = [super init];
    if (self) {
        
        self.currentUsername = username;
        self.chatroom = chatroom;
        self.memberVCType = memberVCType;
        
        [self fetchUserInfoWithUsername:username];
     
    }
    return self;
}

- (instancetype)initWithOwnerId:(NSString *)ownerId
                       chatroom:(AgoraChatroom *)chatroom {
    self = [super init];
    if (self) {
        self.currentUsername = ownerId;
        self.chatroom = chatroom;
        
        if ([AgoraChatClient.sharedClient.currentUsername isEqualToString:ownerId]) {
            self.ownerSelf = YES;
            self.beOperationedMemberRoleType = ELDMemberRoleTypeOwner;
            self.isMute = NO;
        }
        
        [self fetchUserInfoWithUsername:self.currentUsername];
     
    }
    return self;
}


- (void)fetchUserInfoWithUsername:(NSString *)username {
    [AgoraChatClient.sharedClient.userInfoManager fetchUserInfoById:@[username] completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
        if (aError == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userInfo = aUserDatas[username];
                [self.headerView updateUIWithUserInfo:self.userInfo roleType:self.beOperationedMemberRoleType isMute:self.isMute];
                [self buildCells];
                
            });
        }
    }];
}


- (void)placeAndlayoutSubviews {
    self.backgroundColor = UIColor.clearColor;

    UIView *alphaBgView = UIView.alloc.init;
    alphaBgView.alpha = 0.0;

    
    [self addSubview:alphaBgView];
    [self addSubview:self.headerView];
    [self addSubview:self.table];

    
    CGFloat topPadding = (kUserInfoHeaderImageHeight + 2 * 2) * 0.5;

    [alphaBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

        
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(kHeaderViewHeight));
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.table.mas_top).offset(7.0);
    }];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.dataArray.count * kUserInfoCellHeight));
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-[self bottomPadding]);
    }];
}



- (void)buildCells {
    NSMutableArray *tempArray = NSMutableArray.new;

    if (self.ownerSelf) {
        [tempArray addObject:@{kUserInfoCellTitle:kMuteAll}];
    }else {
        //owner check oneself
        if (self.chatroom.permissionType == AgoraChatroomPermissionTypeOwner) {
            if (self.beOperationedMemberRoleType == ELDMemberRoleTypeOwner) {
                self.ownerSelf = YES;
                [tempArray addObject:@{kUserInfoCellTitle:kMuteAll}];
            }else if(self.beOperationedMemberRoleType == ELDMemberRoleTypeAdmin){
                
                if (self.memberVCType == ELDMemberVCTypeAll) {
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveAdmin]];
                    if (self.isMute) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveMute]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];
                    }
                    
                    if (self.isWhite) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveWhite]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeWhite]];
                    }
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeBlock]];
                }else {
                    [tempArray  addObjectsFromArray:[self addOperationNotInAllView]];
                }
                
            }else {
                if (self.memberVCType == ELDMemberVCTypeAll) {
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeAdmin]];
                    if (self.isMute) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveMute]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];
                    }
                    
                    if (self.isWhite) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveWhite]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeWhite]];
                    }
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeBlock]];
                }else {
                    [tempArray  addObjectsFromArray:[self addOperationNotInAllView]];
                }
            }
        }
        
        if (self.chatroom.permissionType == AgoraChatroomPermissionTypeAdmin) {
            if (self.beOperationedMemberRoleType == ELDMemberRoleTypeOwner || self.beOperationedMemberRoleType == ELDMemberRoleTypeAdmin) {
                // no operate permission
            }else {
                if (self.memberVCType == ELDMemberVCTypeAll) {
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeAdmin]];
                    if (self.isMute) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveMute]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];
                    }
                    
                    if (self.isWhite) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveWhite]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeWhite]];
                    }
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeBlock]];
                }else {
                    [tempArray  addObjectsFromArray:[self addOperationNotInAllView]];
                }
            }
        }
        
        if (self.chatroom.permissionType == AgoraChatroomPermissionTypeMember) {
           // no operate permission
        }
    }

    self.dataArray = tempArray;
    
    [self placeAndlayoutSubviews];
    [self.table reloadData];
}

- (NSArray *)addOperationNotInAllView {
    NSMutableArray *tArray = NSMutableArray.array;
    if (self.memberVCType == ELDMemberVCTypeAdmin) {
        [tArray addObject:self.actionTypeDic[kMemberActionTypeRemoveAdmin]];
    }
    
    if (self.memberVCType == ELDMemberVCTypeAllow) {
        [tArray addObject:self.actionTypeDic[kMemberActionTypeRemoveWhite]];
    }

    if (self.memberVCType == ELDMemberVCTypeMute) {
        [tArray addObject:self.actionTypeDic[kMemberActionTypeRemoveMute]];
    }

    if (self.memberVCType == ELDMemberVCTypeBlock) {
        [tArray addObject:self.actionTypeDic[kMemberActionTypeRemoveBlock]];
    }
    
    return [tArray copy];
}


#pragma mark operation
//make all member silence 
- (void)allTheSilence:(BOOL)isAllTheSilence
{
    if (isAllTheSilence) {
        [[AgoraChatClient sharedClient].roomManager muteAllMembersFromChatroom:self.chatroom.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
            if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
                [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
            }
        }];
    } else {
        [[AgoraChatClient sharedClient].roomManager unmuteAllMembersFromChatroom:self.chatroom.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
            if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
                [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
            }
        }];
    }
}

- (void)addAdminAction
{
    [[AgoraChatClient sharedClient].roomManager addAdmin:self.currentUsername
                                       toChatroom:self.chatroom.chatroomId
                                       completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }
                                       }];
}

- (void)removeAdminAction {
    if (_chatroom) {
        ELD_WS
        [[AgoraChatClient sharedClient].roomManager removeAdmin:self.currentUsername
                                            fromChatroom:self.chatroom.chatroomId
                                              completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
            if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
                [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
            }
                                              }];
    }
}



- (void)addMuteAction {
    [[AgoraChatClient sharedClient].roomManager muteMembers:@[self.currentUsername]
                                    muteMilliseconds:-1
                                        fromChatroom:self.chatroom.chatroomId
                                          completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }
                                          }];
}

//解除禁言
- (void)removeMuteAction
{
    ELD_WS
    [[AgoraChatClient sharedClient].roomManager unmuteMembers:@[self.currentUsername]
                                          fromChatroom:self.chatroom.chatroomId
                                            completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }
                                            }];
}




- (void)addBlockAction
{
    [[AgoraChatClient sharedClient].roomManager blockMembers:@[self.currentUsername]
                                         fromChatroom:self.chatroom.chatroomId
                                           completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }
                                           }];
}


- (void)removeBlockAction {
    [[AgoraChatClient sharedClient].roomManager unblockMembers:@[self.currentUsername] fromChatroom:self.chatroom.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }

    }];
    
}

- (void)addWhiteAction {
    [[AgoraChatClient sharedClient].roomManager addWhiteListMembers:@[self.currentUsername] fromChatroom:self.chatroom.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }

    }];
}


//从白名单移除
- (void)removeWhiteAction
{
[[AgoraChatClient sharedClient].roomManager removeWhiteListMembers:@[self.currentUsername]
                                           fromChatroom:self.chatroom.chatroomId
                                             completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
    if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
        [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
    }
                                             }];
}

- (void)kickAction
{
    [[AgoraChatClient sharedClient].roomManager removeMembers:@[self.currentUsername]
                                                 fromChatroom:self.chatroom.chatroomId
                                                   completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }
                                            }];
}




- (void)confirmActionWithActionType:(ELDMemberActionType)actionType {
    switch (actionType) {
        case ELDMemberActionTypeMakeAdmin:
        {
            [self addAdminAction];
        }
            break;
        case ELDMemberActionTypeRemoveAdmin:
        {
            [self removeAdminAction];
        }
            break;
        case ELDMemberActionTypeMakeMute:
        {
            [self addMuteAction];
        }
            break;
        case ELDMemberActionTypeRemoveMute:
        {
            [self removeMuteAction];
        }
            break;

        case ELDMemberActionTypeMakeWhite:
        {
            [self addWhiteAction];
        }
            break;
        case ELDMemberActionTypeRemoveWhite:
        {
            [self removeWhiteAction];
        }
            break;
        case ELDMemberActionTypeMakeBlock:
        {
            [self addBlockAction];
        }
            break;
        case ELDMemberActionTypeRemoveBlock:
        {
            [self removeBlockAction];
        }
            break;

        default:
            break;
    }
    
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kUserInfoCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ELDTitleDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[ELDTitleDetailCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ELDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ELDTitleDetailCell reuseIdentifier]];
    }

    NSDictionary *dic = self.dataArray[indexPath.row];
    NSString *title = dic[kUserInfoCellTitle];
    NSString *alertTitle = dic[kUserInfoAlertTitle];
    NSInteger actionType = [dic[kUserInfoCellActionType] integerValue];

    if (self.ownerSelf) {
        self.muteCell.nameLabel.text = title;
        [self.muteCell.aSwitch setOn:self.chatroom.isMuteAllMembers];
        
        return self.muteCell;
    }else {
        cell.nameLabel.text = title;
        
        cell.tapCellBlock = ^{
            if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(showAlertWithTitle:messsage:actionType:)]) {
                [self.userInfoViewDelegate showAlertWithTitle:alertTitle messsage:@"" actionType:actionType];
            }
        };
    }
    
    return cell;
}


#pragma mark getter and setter
- (UITableView*)table
{
    if (_table == nil) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        //ios9.0+
        if ([_table respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
            _table.cellLayoutMarginsFollowReadableWidth = NO;
        }
        _table.dataSource = self;
        _table.delegate = self;
        _table.backgroundView = nil;
        _table.rowHeight = 44.0;
    }
    return _table;
}


- (ELDUserInfoHeaderView *)headerView {
    if (_headerView == nil) {
        _headerView = [[ELDUserInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kHeaderViewHeight)];
    }
    return _headerView;
}

- (ELDMemberRoleType)beOperationedMemberRoleType {
    NSString *currentUserId = self.userInfo.userId;
    if ([self.chatroom.owner isEqualToString:currentUserId]) {
        return ELDMemberRoleTypeOwner;
    }else  if ([self.chatroom.adminList containsObject:currentUserId]) {
        return ELDMemberRoleTypeAdmin;
    }else {
        return ELDMemberRoleTypeMember;
    }
}

- (BOOL)isMute {
    return [self.chatroom.muteList containsObject:self.userInfo.userId];
}

- (BOOL)isBlock {
    return [self.chatroom.blacklist containsObject:self.userInfo.userId];
}

- (BOOL)isWhite {
    return [self.chatroom.whitelist containsObject:self.userInfo.userId];
}


- (ELDTitleSwitchCell *)muteCell {
    if (_muteCell == nil) {
        _muteCell = [[ELDTitleSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ELDTitleSwitchCell reuseIdentifier]];
        _muteCell.selectionStyle = UITableViewCellSelectionStyleNone;
        ELD_WS
        _muteCell.switchActionBlock = ^(BOOL isOn) {
            [weakSelf allTheSilence:isOn];
        };
    }
    return _muteCell;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.new;
    }
    return _dataArray;
}


//解禁：Want to unban Username?  添加白名单：Want to Move Username From the Allowed List? 从白名单移出：Want to Remove Username From the Allowed List? 设定管理员：Want to Move Username as a Moderator? 罢免管理员：Want to Remove Username as Moderator?

- (NSMutableDictionary *)actionTypeDic {
    if (_actionTypeDic == nil) {
        _actionTypeDic = NSMutableDictionary.new;
        
        _actionTypeDic[kMemberActionTypeMakeAdmin] = @{kUserInfoCellTitle:@"Assign as Moderator",kUserInfoCellActionType:@(ELDMemberActionTypeMakeAdmin),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Move %@ as a Moderator?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveAdmin] = @{kUserInfoCellTitle:@"Remove as Moderator",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveAdmin),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Remove %@ as Moderator?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeMakeMute] = @{kUserInfoCellTitle:@"Timeout",kUserInfoCellActionType:@(ELDMemberActionTypeMakeMute),kUserInfoAlertTitle:[NSString stringWithFormat:@"Timeout %@?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveMute] = @{kUserInfoCellTitle:@"Remove Timeout",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveMute),kUserInfoAlertTitle:[NSString stringWithFormat:@"Remove Timeout %@?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeMakeWhite] = @{kUserInfoCellTitle:@"Move to Allowed List",kUserInfoCellActionType:@(ELDMemberActionTypeMakeWhite),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Move %@ From the Allowed List?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveWhite] = @{kUserInfoCellTitle:@"Remove from Allowed List",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveWhite),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Remove %@ From the Allowed List?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeMakeBlock] = @{kUserInfoCellTitle:@"Ban",kUserInfoCellActionType:@(ELDMemberActionTypeMakeBlock),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Ban %@?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveBlock] = @{kUserInfoCellTitle:@"Unban",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveBlock),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Unban %@?",self.displayName]};

    }
    return _actionTypeDic;
}

- (NSString *)displayName {
    if (self.userInfo) {
        return self.userInfo.nickName ?: self.userInfo.userId;
    }
    return @"";
}


@end

#undef kUserInfoCellTitle
#undef kUserInfoCellActionType
#undef kUserInfoAlertTitle
#undef kUserInfoCellHeight
#undef kHeaderViewHeight
#undef kMuteAll

