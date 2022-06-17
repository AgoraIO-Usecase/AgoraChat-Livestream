//
//  ALSLiveViewController.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/25.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDPublishLiveViewController.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"
#import "EaseChatView.h"
#import "EaseHeartFlyView.h"
#import "EaseLiveHeaderListView.h"
#import "UIImage+Color.h"
#import "EaseProfileLiveView.h"
#import "EaseLiveCastView.h"
#import "EaseLiveRoom.h"
#import "EaseDefaultDataHelper.h"
#import "EaseGiftListView.h"
#import "EaseCustomMessageHelper.h"
#import "EaseFinishLiveView.h"
#import "EaseCustomMessageHelper.h"
#import "EaseLiveViewController.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import <CallKit/CXCallObserver.h>
#import "ELDChatroomMembersView.h"

#import "ELDUserInfoView.h"
#import "ELDNotificationView.h"

#import "ELDChatView.h"
#import "ELDChatViewHelper.h"

#define kDefaultTop 35.f
#define kDefaultLeft 10.f

@interface ELDPublishLiveViewController () <AgoraChatroomManagerDelegate,TapBackgroundViewDelegate,EaseLiveHeaderListViewDelegate,EaseProfileLiveViewDelegate,UIAlertViewDelegate,AgoraChatClientDelegate,EaseCustomMessageHelperDelegate,AgoraRtcEngineDelegate,ELDChatroomMembersViewDelegate,ELDUserInfoViewDelegate,AgoraDirectCdnStreamingEventDelegate,ELDChatViewDelegate>
{
    
        
    BOOL _isFinishBroadcast;
        
    NSInteger _praiseNum;//赞
    NSInteger _giftsNum;//礼物份数
    NSInteger _totalGifts;//礼物合计总数
    
    EaseCustomMessageHelper *_customMsgHelper;//自定义消息帮助
        
}

@property (nonatomic, strong) EaseLiveRoom *room;
@property (nonatomic, strong) AgoraChatroom *chatroom;


@property (strong, nonatomic) UITapGestureRecognizer *singleTapGR;

@property (nonatomic, strong) UIView *liveView;
@property (nonatomic, strong) UIWindow *subWindow;
@property (nonatomic, strong) EaseLiveHeaderListView *headerListView;
//chatroom view
@property (nonatomic, strong) ELDChatView *chatview;
@property (nonatomic, strong) UIImageView *backImageView;

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) UIView *agoraLocalVideoView;

@property (nonatomic, strong) CTCallCenter *callCenter;


@property (nonatomic, strong) ELDChatroomMembersView *memberView;
@property (nonatomic, strong) ELDUserInfoView *userInfoView;

@property (nonatomic, strong) ELDNotificationView *notificationView;


@end

@implementation ELDPublishLiveViewController

- (instancetype)initWithLiveRoom:(EaseLiveRoom*)room
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];

        _room = room;
        _customMsgHelper = [[EaseCustomMessageHelper alloc]initWithCustomMsgImp:self chatId:_room.chatroomId];
        _praiseNum = [EaseDefaultDataHelper.shared.praiseStatisticstCount intValue];
        _giftsNum = [EaseDefaultDataHelper.shared.giftNumbers intValue];
        _totalGifts = [EaseDefaultDataHelper.shared.totalGifts intValue];
        _isFinishBroadcast = NO;
        EaseDefaultDataHelper.shared.currentRoomId = _room.roomId;
        [EaseDefaultDataHelper.shared archive];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AgoraChatClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient] addDelegate:self delegateQueue:nil];
    
    
    [self setupForDismissKeyboard];
        
    [self joinChatroom];
    
    [self _setupAgoreKit];
    
//    if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]||[_room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_INTERACTION_LIVE]) {
//        [self _setupAgoreKit];
//    }
//    if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeLIVE]) {
//        [self _prepareForCameraSetting];
//        [self actionPushStream];
//        [self monitorCall];
//    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication  sharedApplication].idleTimerDisabled =YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [UIApplication  sharedApplication].idleTimerDisabled =NO;
}


- (void)joinChatroom {
    ELD_WS
    [[ELDChatViewHelper sharedHelper] joinChatroomWithChatroomId:_room.chatroomId completion:^(AgoraChatroom * _Nonnull aChatroom, AgoraChatError * _Nonnull aError) {
        if (aError == nil) {
            weakSelf.chatroom = aChatroom;
            [self.view addSubview:self.liveView];
            [weakSelf.view bringSubviewToFront:weakSelf.liveView];

            [weakSelf fetchChatroomSpecificationWithChatroomId:weakSelf.chatroom.chatroomId];
            
        } else {
            [weakSelf showHint:aError.description];
        }
    }];
}


- (void)updateChatView {
    self.chatview.chatroom = self.chatroom;
    
    if (self.chatroom.isMuteAllMembers) {
        NSString *message = @"You have been timeout the Channel";
        [self showNotifactionMessage:message userId:@"" displayAllTime:YES];
    }else {
        self.notificationView.hidden = YES;
    }
    
    [self.chatview reloadTableView];
}


- (void)fetchChatroomSpecificationWithChatroomId:(NSString *)aChatroomId {
    ELD_WS
    [[AgoraChatClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:aChatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (aError == nil) {
            weakSelf.chatroom = aChatroom;
            // reset memberView
            weakSelf.memberView = nil;
            [weakSelf.headerListView updateHeaderViewWithChatroom:self.chatroom];
            [weakSelf updateChatView];
        }else {
            [weakSelf showHint:aError.description];
        }
    }];
}

- (void)dealloc
{
    /**
     @property (nonatomic, strong) NSString *praiseStatisticstCount;//点赞统计
     @property (nonatomic, strong) NSMutableDictionary *giftStatisticsCount;//礼物统计
     @property (nonatomic, strong) NSMutableArray *rewardCount;//打赏人列表
     @property (nonatomic, strong) NSString *giftNumbers;//礼物份数
     @property (nonatomic, strong) NSString *totalGifts;//礼物总数合计
     */
    [[AgoraChatClient sharedClient].roomManager removeDelegate:self];
    [[AgoraChatClient sharedClient] removeDelegate:self];
    [_headerListView stopTimer];
    _chatview.easeChatView.delegate = nil;
    
    EaseDefaultDataHelper.shared.praiseStatisticstCount = @"";
    [EaseDefaultDataHelper.shared.giftStatisticsCount removeAllObjects];
    [EaseDefaultDataHelper.shared.rewardCount removeAllObjects];
    EaseDefaultDataHelper.shared.giftNumbers = @"";
    EaseDefaultDataHelper.shared.totalGifts = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.chatview endEditing:YES];
}

//Detect incoming calls
- (void)monitorCall
{
    __weak typeof(self) weakSelf = self;
    self.callCenter.callEventHandler = ^(CTCall* call) {
        if (call.callState == CTCallStateDisconnected) {
            NSLog(@"End or hang up the call");
            [weakSelf connectionStateDidChange:AgoraChatConnectionConnected];
        } else if (call.callState == CTCallStateConnected){

        } else if(call.callState == CTCallStateIncoming) {
            if ([weakSelf.room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
                [weakSelf.agoraKit muteLocalVideoStream:YES];
                [weakSelf.agoraKit muteLocalAudioStream:YES];
            }
            if ([weakSelf.room.liveroomType isEqualToString:kLiveBoardCastingTypeAGORA_CDN_LIVE]) {
//                [weakSelf.session stopStreaming];
            }
        } else if (call.callState ==CTCallStateDialing) {

        }
    };
}

- (void)_setupAgoreKit
{
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:AppId delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    [self.agoraKit setClientRole:AgoraClientRoleBroadcaster options:nil];
    [self.agoraKit enableVideo];
    [self.agoraKit enableAudio];
    [self _setupLocalVideo];
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken ,NSUInteger agoraUserId) {
        [weakSelf.agoraKit joinChannelByToken:rtcToken channelId:_room.channel info:nil uid:(NSUInteger)agoraUserId joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
            [weakSelf.agoraKit muteAllRemoteAudioStreams:YES];
            [weakSelf.agoraKit muteAllRemoteVideoStreams:YES];
            [weakSelf.agoraKit muteAllRemoteAudioStreams:YES];
            [weakSelf.agoraKit muteAllRemoteVideoStreams:YES];
            if ([_room.liveroomType isEqualToString:kLiveBoardCastingTypeAGORA_CDN_LIVE]) {
                NSDictionary *paramtars = @{
                    @"domain":@"ws1-rtmp-push.easemob.com",
                    @"pushPoint":@"live",
                    @"streamKey":_room.channel ? _room.channel : _room.chatroomId,
                    @"expire":@"3600"
                };
                [EaseHttpManager.sharedInstance getArgoLiveRoomPushStreamUrlParamtars:paramtars Completion:^(NSString *pushStreamStr) {
                    NSLog(@"%s  pushStreamStr:%@",__func__,pushStreamStr);
//                    [weakSelf.agoraKit startRtmpStreamWithoutTranscoding:pushStreamStr];

                    AgoraRtcBoolOptional *optional = [AgoraRtcBoolOptional of:YES];
                    AgoraDirectCdnStreamingMediaOptions *option =  [[AgoraDirectCdnStreamingMediaOptions alloc] init];
                    option.publishCameraTrack = optional;
                    option.publishMicrophoneTrack = optional;
                    
        [weakSelf.agoraKit startDirectCdnStreaming:self publishUrl:pushStreamStr mediaOptions:option];
                }];
            }
            
        }];
    }];
}

- (void)_setupLocalVideo {
    self.agoraLocalVideoView = [[UIView alloc]init];
    self.agoraLocalVideoView.frame = self.view.bounds;
    [self.view insertSubview:self.agoraLocalVideoView atIndex:0];
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = 0;
    videoCanvas.view = self.agoraLocalVideoView;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    [self.agoraKit setupLocalVideo:videoCanvas];
}

#pragma mark AgoraDirectCdnStreamingEventDelegate
- (void)onDirectCdnStreamingStateChanged:(AgoraDirectCdnStreamingState)state
                                   error:(AgoraDirectCdnStreamingError)error
                                 message:(NSString *_Nullable)message {

}

- (void)onDirectCdnStreamingStats:(AgoraDirectCdnStreamingStats *_Nonnull)stats {
    
}


#pragma mark - AgoraRtcEngineDelegate
-(void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed{
    
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine
                    connectionStateChanged:(AgoraConnectionState)state
           reason:(AgoraConnectionChangedReason)reason {
    
    if (reason == AgoraConnectionChangedReasonTokenExpired || reason == AgoraConnectionChangedReasonInvalidToken) {
        __weak typeof(self) weakSelf = self;
        [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
            [weakSelf.agoraKit renewToken:rtcToken];
        }];
    }
    if (state == AgoraConnectionStateConnected) {
        [self.backImageView removeFromSuperview];
        [self.view insertSubview:self.agoraLocalVideoView atIndex:0];
    }
    if (state == AgoraConnectionStateConnecting || state == AgoraConnectionStateReconnecting) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"connecting..." toView:self.view];
        [hud hideAnimated:YES afterDelay:1.5];
        [self.agoraLocalVideoView removeFromSuperview];
        [self.view insertSubview:self.backImageView atIndex:0];
    }
    if (state == AgoraConnectionStateFailed) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"Connection failed, please re-create the live room." toView:self.view];
        [self.agoraLocalVideoView removeFromSuperview];
        [self.view insertSubview:self.backImageView atIndex:0];
        [hud hideAnimated:YES afterDelay:2.0];
    }
}


- (void)rtcEngine:(AgoraRtcEngineKit *)engine tokenPrivilegeWillExpire:(NSString *)token
{
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
        [weakSelf.agoraKit renewToken:rtcToken];
    }];
}

- (void)rtcEngineRequestToken:(AgoraRtcEngineKit *)engine
{
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
        [weakSelf.agoraKit joinChannelByToken:rtcToken channelId:_room.channel info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        }];
    }];
}

#pragma mark CNDDelegate
-(void)rtcEngine:(AgoraRtcEngineKit *)engine rtmpStreamingChangedToState:(NSString *)url state:(AgoraRtmpStreamingState)state errorCode:(AgoraRtmpStreamingErrorCode)errorCode{
    
}
-(void)rtcEngine:(AgoraRtcEngineKit *)engine rtmpStreamingEventWithUrl:(NSString *)url eventCode:(AgoraRtmpStreamingEvent)eventCode{
    
}
-(void)rtcEngine:(AgoraRtcEngineKit *)engine streamInjectedStatusOfUrl:(NSString *)url uid:(NSUInteger)uid status:(AgoraInjectStreamStatus)status{
    
}

-(void)rtcEngine:(AgoraRtcEngineKit *)engine streamPublishedWithUrl:(NSString *)url errorCode:(AgoraErrorCode)errorCode{
    
}
-(void)rtcEngine:(AgoraRtcEngineKit *)engine streamUnpublishedWithUrl:(NSString *)url{
    
}
-(void)rtcEngineTranscodingUpdated:(AgoraRtcEngineKit *)engine{
    
}
- (void)fetchAgoraRtcToken:(void (^)(NSString *rtcToken ,NSUInteger agoraUserId))aCompletionBlock;
{
    _room.channel = _room.channel.length > 0 ? _room.channel : _room.roomId;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSString* strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/token/rtcToken/v1?userAccount=%@&channelName=%@&appkey=%@",[AgoraChatClient sharedClient].currentUsername, _room.channel, [AgoraChatClient sharedClient].options.appkey];
    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:utf8Url];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[AgoraChatClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",body);
            if(body) {
                NSString* resCode = [body objectForKey:@"code"];
                if([resCode isEqualToString:@"RES_0K"]) {
                    NSString* rtcToken = [body objectForKey:@"accessToken"];
                    NSUInteger agoraUserId = [[body objectForKey:@"agoraUserId"] integerValue];
                    if (aCompletionBlock)
                        aCompletionBlock(rtcToken,agoraUserId);
                }
            }
        }
    }];

    [task resume];
}

#pragma mark - AgoraChatClientDelegate

- (void)connectionStateDidChange:(AgoraChatConnectionState)aConnectionState
{
    ELD_WS
    //断网重连后，修改直播间状态为ongoing并重新推流&加入聊天室
    if (aConnectionState == AgoraChatConnectionConnected) {
        [[EaseHttpManager sharedInstance] modifyLiveroomStatusWithOngoing:_room completion:^(EaseLiveRoom *room, BOOL success) {
            if (success)
                _room = room;
  
            [[ELDChatViewHelper sharedHelper] joinChatroomWithChatroomId:_room.chatroomId completion:^(AgoraChatroom * _Nonnull aChatroom, AgoraChatError * _Nonnull aError) {
                if (aError == nil) {
                    weakSelf.chatroom = aChatroom;
                    [weakSelf.headerListView updateHeaderViewWithChatroom:weakSelf.chatroom];
                }else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
            
            if ([weakSelf.room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
                [weakSelf.agoraKit enableLocalVideo:YES];
                [weakSelf.agoraKit enableLocalAudio:YES];
            }
            if ([weakSelf.room.liveroomType isEqualToString:kLiveBoardCastingTypeAGORA_CDN_LIVE]) {
//                [weakSelf.session restartStreamingWithPushURL:_streamURL feedback:^(PLStreamStartStateFeedback feedback) {}];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Action

- (void)closeAction
{
    [self.subWindow resignKeyWindow];
    [UIView animateWithDuration:0.3 animations:^{
        self.subWindow.top = KScreenHeight;
    } completion:^(BOOL finished) {
        self.subWindow.hidden = YES;
        [self.view.window makeKeyAndVisible];
    }];
}

#pragma mark - EaseLiveHeaderListViewDelegate

- (void)didSelectHeaderWithUsername:(NSString *)username
{
    if ([self.subWindow isKeyWindow]) {
        [self closeAction];
        return;
    }

    
    ELDUserInfoView *userInfoView = [[ELDUserInfoView alloc] initWithUsername:username chatroom:_chatroom memberVCType:ELDMemberVCTypeAll];
    userInfoView.delegate = self;
    userInfoView.userInfoViewDelegate = self;
    [userInfoView showFromParentView:self.view];
}

#pragma  mark - TapBackgroundViewDelegate

- (void)didTapBackgroundView:(EaseBaseSubView *)profileView
{
    [profileView removeFromParentView];
}

#pragma  mark ELDChatroomMembersViewDelegate
- (void)selectedUser:(NSString *)userId memberVCType:(ELDMemberVCType)memberVCType chatRoom:(AgoraChatroom *)chatroom {
    
    [self.memberView removeFromParentView];
    
    self.userInfoView = [[ELDUserInfoView alloc] initWithUsername:userId chatroom:chatroom memberVCType:memberVCType];
    self.userInfoView.delegate = self;
    self.userInfoView.userInfoViewDelegate = self;
    [self.userInfoView showFromParentView:self.view];

}

#pragma mark ELDUserInfoViewDelegate
- (void)showAlertWithTitle:(NSString *)title messsage:(NSString *)messsage actionType:(ELDMemberActionType)actionType {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:cancelAction];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.userInfoView confirmActionWithActionType:actionType];
    }];

    [alertController addAction:okAction];

    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateLiveViewWithChatroom:(AgoraChatroom *)chatroom error:(AgoraChatError *)error {
    if (error == nil) {
        [self fetchChatroomSpecificationWithChatroomId:chatroom.chatroomId];
    }else {
        [self showHint:error.description];
    }
    
    [self.userInfoView removeFromParentView];
}



- (void)didClickFinishButton
{
    ELD_WS
dispatch_block_t block = ^{
    
    [[ELDChatViewHelper sharedHelper] leaveChatroomId:_room.chatroomId completion:^(BOOL success) {
        if (success) {

            [[AgoraChatClient sharedClient].chatManager deleteConversation:_room.chatroomId isDeleteMessages:YES completion:NULL];
        } else {
            [weakSelf showHint:@"Failed to exit the chat room"];
        }
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (_finishBroadcastCompletion) {
                _finishBroadcastCompletion(YES);
            }
        }];
    }];
    
};
    
    
    [[EaseHttpManager sharedInstance] modifyLiveroomStatusWithOffline:_room completion:^(EaseLiveRoom *room, BOOL success) {
        if (success) {
            _room = room;
            
//            if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeLIVE]) {
//                [weakSelf.session stopStreaming];//结束推流
//                [weakSelf.session destroy];
//            }
//            if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
//                [weakSelf.agoraKit leaveChannel:nil];
//                [AgoraRtcEngineKit destroy];
//            }
            
//            [EaseHttpManager.sharedInstance deleteLiveRoomWithRoomId:_room.roomId completion:^(BOOL success) {
//                [weakSelf.agoraKit leaveChannel:nil];
//                [AgoraRtcEngineKit destroy];
//                _isFinishBroadcast = YES;
//                //重置本地保存的直播间id
//                EaseDefaultDataHelper.shared.currentRoomId = @"";
//                [EaseDefaultDataHelper.shared archive];
//                block();
//            }];
            
            [weakSelf.agoraKit leaveChannel:nil];
            [AgoraRtcEngineKit destroy];
            _isFinishBroadcast = YES;
            
            EaseDefaultDataHelper.shared.currentRoomId = @"";
            [EaseDefaultDataHelper.shared archive];
            block();

        }
        
    }];
}

#pragma mark ELDChatViewDelegate
- (void)chatViewDidBottomOffset:(CGFloat)offSet
{
    if ([self.subWindow isKeyWindow]) {
        return;
    }
    
    if (offSet > 0) {
        [self.chatview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_liveView).offset(-offSet);
        }];
    }else {
        [self.chatview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_liveView).offset(-kBottomSafeHeight);
        }];
    }
}

- (void)didSelectUserWithMessage:(AgoraChatMessage *)message
{
    [self.view endEditing:YES];
  
    self.userInfoView = [[ELDUserInfoView alloc] initWithUsername:message.from chatroom:_chatroom memberVCType:ELDMemberVCTypeAll];
    self.userInfoView.delegate = self;
    self.userInfoView.userInfoViewDelegate = self;
    [self.userInfoView showFromParentView:self.view];

}

- (void)chatViewDidSendMessage:(AgoraChatMessage *)message error:(AgoraChatError *)error {
    if (error) {
        [self showHint:error.errorDescription];
    }
}


//切换前后摄像头
- (void)didSelectChangeCameraButton
{
    [self.agoraKit switchCamera];
}


- (void)didSelectedExitButton
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"End your Livestream?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:cancelAction];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _isFinishBroadcast = YES;
//        _session.delegate = nil;
        [self didClickFinishButton];
    }];

    [alertController addAction:okAction];

    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];

}


#pragma mark - EaseCustomMessageHelperDelegate
//有观众送礼物
- (void)steamerReceiveGiftId:(NSString *)giftId giftNum:(NSInteger)giftNum fromUser:(nonnull NSString *)userId {
    [self.chatview userSendGiftId:giftId giftNum:giftNum userId:userId backView:self.view];
    /*
     * gift message is local create message ,can not caculate gift count
    */
    
//    AgoraChatCustomMessageBody *msgBody = (AgoraChatCustomMessageBody*)msg.body;
//    NSString *giftid = [msgBody.ext objectForKey:kGiftIdKey];
//
//    _totalGifts += count;
//    ++_giftsNum;
//    //礼物份数
//    EaseDefaultDataHelper.shared.giftNumbers = [NSString stringWithFormat:@"%ld",(long)_giftsNum];
//    //礼物合计总数
//    EaseDefaultDataHelper.shared.totalGifts = [NSString stringWithFormat:@"%ld",(long)_totalGifts];
//    //送礼物人列表
//    if (![EaseDefaultDataHelper.shared.rewardCount containsObject:msg.from]) {
//        [EaseDefaultDataHelper.shared.rewardCount addObject:msg.from];
//    }
//    NSMutableDictionary *giftDetailDic = (NSMutableDictionary*)[EaseDefaultDataHelper.shared.giftStatisticsCount objectForKey:giftid];
//    if (!giftDetailDic) giftDetailDic = [[NSMutableDictionary alloc]init];
//    long long num = [(NSString*)[giftDetailDic objectForKey:msg.from] longLongValue];
//    [giftDetailDic setObject:[NSString stringWithFormat:@"%lld",(num+count)] forKey:msg.from];
//    //礼物统计字典
//    [EaseDefaultDataHelper.shared.giftStatisticsCount setObject:giftDetailDic forKey:giftid];
//    [EaseDefaultDataHelper.shared archive];
}

//弹幕
- (void)didSelectedBarrageSwitch:(AgoraChatMessage*)msg
{
    [self.chatview barrageAction:msg backView:self.view];
}


//收到点赞
- (void)didReceivePraiseMessage:(AgoraChatMessage *)message
{
    [self.chatview praiseAction:self.view];
    AgoraChatCustomMessageBody *customBody = (AgoraChatCustomMessageBody*)message.body;
    _praiseNum += [(NSString*)[customBody.ext objectForKey:@"num"] integerValue];
    EaseDefaultDataHelper.shared.praiseStatisticstCount = [NSString stringWithFormat:@"%ld",(long)_praiseNum];
    [EaseDefaultDataHelper.shared archive];
}


#pragma mark EaseLiveHeaderListViewDelegate
- (void)didClickAnchorCard:(AgoraChatUserInfo*)userInfo
{
    [self.view endEditing:YES];

    ELDUserInfoView *userInfoView = [[ELDUserInfoView alloc] initWithOwnerId:userInfo.userId chatroom:_chatroom];
    userInfoView.delegate = self;
    userInfoView.userInfoViewDelegate = self;
    [userInfoView showFromParentView:self.view];
    
}

- (void)didSelectMemberListButton:(BOOL)isOwner currentMemberList:(NSMutableArray*)currentMemberList
{
    [self.view endEditing:YES];
    [self.memberView showFromParentView:self.view];

}

- (void)willCloseChatroom {
    [self didClickFinishButton];
}



#pragma mark - AgoraChatroomManagerDelegate
- (void)userDidJoinChatroom:(AgoraChatroom *)aChatroom user:(NSString *)aUsername {
    if ([aChatroom.chatroomId isEqualToString:self.chatroom.chatroomId]) {
        [self fetchChatroomSpecificationWithChatroomId:self.chatroom.chatroomId];
        [self.chatview insertJoinMessageWithChatroom:self.chatroom user:aUsername];
    }
}

- (void)userDidLeaveChatroom:(AgoraChatroom *)aChatroom user:(NSString *)aUsername {
    if ([aChatroom.chatroomId isEqualToString:self.chatroom.chatroomId]) {
        [self fetchChatroomSpecificationWithChatroomId:self.chatroom.chatroomId];
    }
}


- (void)chatroomAllMemberMuteChanged:(AgoraChatroom *)aChatroom isAllMemberMuted:(BOOL)aMuted
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if (aMuted) {
            NSString *message = @"You have been timeout the Channel";
            [self showNotifactionMessage:message userId:@"" displayAllTime:YES];
        } else {
            NSString *message = @"You have been remove timeout the Channel";
            [self showNotifactionMessage:message userId:@"" displayAllTime:NO];

        }
        
        [self fetchChatroomSpecificationWithChatroomId:aChatroom.chatroomId];
        
    }
}


- (void)chatroomWhiteListDidUpdate:(AgoraChatroom *)aChatroom addedWhiteListMembers:(NSArray *)aMembers
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMembers) {
            [text appendString:name];
        }
        [self fetchChatroomSpecificationWithChatroomId:aChatroom.chatroomId];
        
        NSString *message = @"has been add to whitelist.";
        [self showNotifactionMessage:message userId:text displayAllTime:NO];

    }
}

- (void)chatroomWhiteListDidUpdate:(AgoraChatroom *)aChatroom removedWhiteListMembers:(NSArray *)aMembers
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMembers) {
            [text appendString:name];
        }
        [self fetchChatroomSpecificationWithChatroomId:aChatroom.chatroomId];
    
        NSString *message = @"has been remove from whitelist.";
        [self showNotifactionMessage:message userId:text displayAllTime:NO];
    }
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMutes) {
            [text appendString:name];
        }
        [self fetchChatroomSpecificationWithChatroomId:aChatroom.chatroomId];
    
        NSString *message = @"has been banned.";
        [self showNotifactionMessage:message userId:text displayAllTime:NO];

    }
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMutes) {
            [text appendString:name];
        }
        
        [self fetchChatroomSpecificationWithChatroomId:aChatroom.chatroomId];
        
        NSString *message = @"has been unbanned.";
        [self showNotifactionMessage:message userId:text displayAllTime:NO];
    }
}

- (void)chatroomOwnerDidUpdate:(AgoraChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner
{
    ELD_WS

    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"live chatroom create update  :%@",aChatroom.chatroomId] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([aOldOwner isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
                if ([_room.liveroomType isEqualToString:kLiveBoardCastingTypeAGORA_CDN_LIVE]) {
//                    [weakSelf.session stopStreaming];
//                    [weakSelf.session destroy];
                }
                if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
                    [weakSelf.agoraKit leaveChannel:nil];
                    [AgoraRtcEngineKit destroy];
                }
                _isFinishBroadcast = YES;
                EaseDefaultDataHelper.shared.currentRoomId = @"";
                [EaseDefaultDataHelper.shared archive];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    UIViewController *view = [[EaseLiveViewController alloc] initWithLiveRoom:_room];
                    view.modalPresentationStyle = 0;
                    [weakSelf.navigationController presentViewController:view animated:YES completion:NULL];
                    if (_finishBroadcastCompletion) {
                        _finishBroadcastCompletion(YES);
                        [self fetchChatroomSpecificationWithChatroomId:aChatroom.chatroomId];
                    }
                }];
            }
        }];
        
        [alert addAction:ok];
        alert.modalPresentationStyle = 0;
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)showNotifactionMessage:(NSString *)message
                        userId:(NSString *)userId
                displayAllTime:(BOOL)displayAllTime {
    
    if ([userId isEqualToString:@""]) {
        self.notificationView.hidden = NO;
        ELD_WS
        [self.notificationView showHintMessage:message
                                displayAllTime:displayAllTime
                                    completion:^(BOOL finish) {
            if (finish) {
                weakSelf.notificationView.hidden = YES;
            }
        }];
    }else {
        [EaseUserInfoManagerHelper fetchUserInfoWithUserIds:@[userId] completion:^(NSDictionary * _Nonnull userInfoDic) {
            AgoraChatUserInfo *userInfo = userInfoDic[userId];
            if (userInfo) {
                NSString *displayName = userInfo.nickName ?:userInfo.userId;

                NSString *displayMsg = [NSString stringWithFormat:@"%@ %@",displayName,message];
                self.notificationView.hidden = NO;
                ELD_WS
                [self.notificationView showHintMessage:displayMsg
                                        displayAllTime:displayAllTime
                                            completion:^(BOOL finish) {
                    if (finish) {
                        weakSelf.notificationView.hidden = YES;
                    }
                }];
            }
            
        }];
        
    }
}


//- (void)showNotifactionMessage:(NSString *)message displayAllTime:(BOOL)displayAllTime {
//    self.notificationView.hidden = NO;
//    ELD_WS
//    [self.notificationView showHintMessage:message
//                            displayAllTime:displayAllTime
//                                completion:^(BOOL finish) {
//        if (finish) {
//            weakSelf.notificationView.hidden = YES;
//        }
//    }];
//
//}



- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = endFrame.origin.y;
    
    if ([self.subWindow isKeyWindow]) {
        if (y == KScreenHeight) {
            [UIView animateWithDuration:0.3 animations:^{
                self.subWindow.top = KScreenHeight - 290.f;
                self.subWindow.height = 290.f;
            }];
        } else  {
            [UIView animateWithDuration:0.3 animations:^{
                self.subWindow.top = 0;
                self.subWindow.height = KScreenHeight;
            }];
        }
    }
}

#pragma mark - UITapGestureRecognizer
- (void)setupForDismissKeyboard
{
    self.singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(tapAnywhereToDismissKeyboard:)];
    [self.view addGestureRecognizer:self.singleTapGR];
}


- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
    [self.chatview endEditing:YES];
}


#pragma mark getter and setter
- (UIWindow*)subWindow
{
    if (_subWindow == nil) {
        _subWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 290.f)];
    }
    return _subWindow;
}

- (UIImageView*)backImageView
{
    if (_backImageView == nil) {
        _backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _backImageView.contentMode = UIViewContentModeScaleAspectFill;
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:_room.coverPictureUrl];
        __weak typeof(self) weakSelf = self;
        if (!image) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:_room.coverPictureUrl]
                                                                     options:SDWebImageDownloaderUseNSURLCache
                                                                    progress:NULL
                                                                   completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                       if (image) {
                                                                           [[SDImageCache sharedImageCache] storeImage:image forKey:_room.coverPictureUrl toDisk:NO completion:^{
                                                                               weakSelf.backImageView.image = image;
                                                                           }];
                                                                       } else {
                                                                           weakSelf.backImageView.image = [UIImage imageNamed:@"default_back_image"];
                                                                       }
                                                                   }];
           }
        _backImageView.image = image;
    }
    return _backImageView;
}

- (EaseLiveHeaderListView*)headerListView
{
    if (_headerListView == nil) {
        _headerListView = [[EaseLiveHeaderListView alloc] initWithFrame:CGRectMake(0, kDefaultTop, KScreenWidth, 40.f) chatroom:self.chatroom isPublish:YES];
        _headerListView.delegate = self;
        [_headerListView setLiveCastDelegate];
    }
    return _headerListView;
}


- (ELDChatView *)chatview {
    if (_chatview == nil) {
        _chatview = [[ELDChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - kChatViewHeight, CGRectGetWidth(self.view.bounds), kChatViewHeight) chatroom:self.chatroom isPublish:YES customMsgHelper:_customMsgHelper];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (UIView*)liveView
{
    if (_liveView == nil) {
        _liveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        _liveView.backgroundColor = [UIColor clearColor];
        
        [_liveView addSubview:self.headerListView];
        [_liveView addSubview:self.notificationView];
        [_liveView addSubview:self.chatview];

        [self.headerListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_liveView).offset(kDefaultTop);
            make.left.right.equalTo(_liveView);
            make.height.equalTo(@(kLiveHeaderViewHeight));
        }];
        
        [self.notificationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerListView.mas_bottom).offset(5.0);
            make.left.right.equalTo(_liveView);
            make.height.equalTo(@(kLiveNotifacationViewHeight));
        }];

        [self.chatview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_liveView);
            make.height.equalTo(@(kChatViewHeight));
            make.bottom.equalTo(_liveView).offset(-kBottomSafeHeight);
        }];
    }
    return _liveView;
}


- (ELDChatroomMembersView *)memberView {
    if (_memberView == nil) {
        _memberView = [[ELDChatroomMembersView alloc] initWithChatroom:_chatroom];
        _memberView.delegate = self;
        _memberView.selectedUserDelegate = self;
    }
    return _memberView;
}


- (CTCallCenter *)callCenter {
    if (!_callCenter) {
        _callCenter = [[CTCallCenter alloc] init];
    }
    return _callCenter;
}

- (ELDNotificationView *)notificationView {
    if (_notificationView == nil) {
        _notificationView = [[ELDNotificationView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerListView.frame), KScreenWidth, 30)];
        _notificationView.hidden = YES;
    }
    return _notificationView;
}


@end
