# 简介 #
本demo演示了通过环信SDK以及环信appServer实现的直播聊天室

## 怎么使用本demo ##
- 首先在EaseMobLiveDemo文件夹下执行pod install,集成环信SDK
- 初次进入app时会自动注册一个UUID游客账号，默认密码000000，注册成功自动登录，自动登录完成跳转到主页面
- 点击主页底部红色按钮，可创建一个直播间，键入封面图以及本次直播主题后，点击“开始直播”开启一场直播，直播间即出现在“直播大厅”列表，其他游客即可从“直播大厅”进入直播间
- 游客点击直播大厅任一直播间即可进入该直播间观看直播，直播间内目前可以发聊天消息给主播刷礼物，当前直播间聊天室观众均可收到消息动画

## 功能实现 ##


### 创建直播聊天室
**具体演示代码见EaseLiveTVListViewController,ELDPreLivingViewController,ELDPublishLiveViewController,EaseHttpManager**

1、创建直播聊天室
```
/*
 *  创建直播聊天室
 *
 *  @param aRoom            直播聊天室
 *  @param aCompletion      完成的回调block
 */
- (void)createLiveRoomWithRoom:(EaseLiveRoom*)aRoom
                    completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
```
2、创建成功后设置当前将要直播的直播聊天室为“ongoing”正直播状态

```
/*
*  更新直播间状态为ongoing
*
*  @param aRoom            直播间
*  @param aCompletion      完成的回调block
*/
- (void)modifyLiveroomStatusWithOngoing:(EaseLiveRoom *)room
                             completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
```

3、加入聊天室

```
/*
 *  用户加入直播聊天室
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aChatroomId      聊天室ID
 *  @param aIsCount         是否计数
 *  @param aCompletion      完成的回调block
 */
- (void)joinLiveRoomWithRoomId:(NSString*)aRoomId
                    chatroomId:(NSString*)aChatroomId
                       isCount:(BOOL)aIsCount
                       completion:(void (^)(BOOL success))aCompletion;
```
4、设置消息监听

```
	 [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
	 
	- (void)messagesDidReceive:(NSArray *)aMessages
	{
	//收到普通消息
	}

	- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
	{
	//收到cmd消息
	}
```
5、发送消息

```
EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"发送内容"];
NSString *from = [[EMClient sharedClient] currentUsername];
EMMessage *message = [[EMMessage alloc] initWithConversationID:aChatroomId from:from to:aChatroomId body:body ext:nil];
message.chatType = EMChatTypeChatRoom;
[[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
	if (!error) {
	//消息发送成功
	}
}];   
``` 
6、从appServer获取直播聊天室详情并获取成员列表

```
/*
*  获取直播聊天室详情
*
*  @param aRoom            直播聊天室
*  @param aCompletion      完成的回调block
*/
- (void)fetchLiveroomDetail:(NSString *)roomId completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
```
7、获取直播聊天室禁言列表

```
/**
 *  \~chinese
 *  将一组成员禁言。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aMuteMembers         要禁言的成员列表。
 *  @param aMuteMilliseconds    禁言时长
 *  @param aChatroomId          聊天室 ID。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Mutes chatroom members.
 * 
 *  Only the chatroom owner or admin can call this method.
 *
 *  This is an asynchronous method.
 *
 *  @param aMuteMembers         The list of mute.
 *  @param aMuteMilliseconds    Muted time duration in millisecond
 *  @param aChatroomId          The chatroom ID.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method call fails.
 *
 */
- (void)muteMembers:(NSArray<NSString *> *_Nonnull)aMuteMembers
   muteMilliseconds:(NSInteger)aMuteMilliseconds
       fromChatroom:(NSString *_Nonnull)aChatroomId
         completion:(void (^_Nullable )(AgoraChatroom *_Nullable aChatroom, AgoraChatError *_Nullable aError))aCompletionBlock;
```
8、直播聊天室某观众解除禁言

```
/*!
 *  解除禁言，需要Owner / Admin权限
 *
 *  @param aMuteMembers     被解除的列表<NSString>
 *  @param aChatroomId      聊天室ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)unmuteMembers:(NSArray *)aMembers
                 fromChatroom:(NSString *)aChatroomId
                 completion:(void (^)(EMChatroom *aChatroom, EMError *aError))aCompletionBlock;
```
9、获取直播聊天室白名单列表

```
/*!
 *  获取聊天室白名单列表
 *
 *  @param aChatroomId      聊天室ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)getChatroomWhiteListFromServerWithId:(NSString *)aChatroomId
        completion:(void (^)(NSArray *aList, EMError *aError))aCompletionBlock;
```
10、直播聊天室从白名单移除成员

```
/*!
 *  移除白名单，需要Owner / Admin权限
 *
 *  @param aMembers         被移除的列表<NSString>
 *  @param aChatroomId      聊天室ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)removeWhiteListMembers:(NSArray *)aMembers
                  fromChatroom:(NSString *)aChatroomId
                  completion:(void (^)(EMChatroom *aChatroom, EMError *aError))aCompletionBlock;
```
11、直播聊天室全体禁言

```
/*!
 *  设置全员禁言，需要Owner / Admin权限
 *
 *  @param aChatroomId      聊天室ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)muteAllMembersFromChatroom:(NSString *)aChatroomId
                  completion:(void(^)(EMChatroom *aChatroom, EMError *aError))aCompletionBlock;
```
12、直播聊天室解除全体禁言

```
/*!
 *  解除全员禁言，需要Owner / Admin权限
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aChatroomId      聊天室ID
 *  @param pError           错误信息
 *
 *  @result    聊天室实例
 */
- (EMChatroom *)unmuteAllMembersFromChatroom:(NSString *)aChatroomId
                  error:(EMError **)pError;
```
- 直播聊天室全体禁言与观众禁言列表没有直接关系，互不影响

13、离开聊天室并设置当前直播聊天室为“Offline”未直播状态，结束直播

```
/*
 *  用户离开直播聊天室
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aChatroomId      聊天室ID
 *  @param aIsCount         是否计数
 *  @param aCompletion      完成的回调block
 */
- (void)leaveLiveRoomWithRoomId:(NSString*)aRoomId
                     chatroomId:(NSString*)aChatroomId
                        isCount:(BOOL)aIsCount
                        completion:(void (^)(BOOL success))aCompletion;
                        
- 更新直播聊天室状态为Offline
/*
*  更新直播间状态为offline
*
*  @param aRoom            直播间
*  @param aCompletion      完成的回调block
*/
- (void)modifyLiveroomStatusWithOffline:(EaseLiveRoom *)room
                             completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
```

### 观看直播
**具体代码参考demo EaseLiveViewController，ELDLiveListViewController**

1、获取当前正直播的直播聊天室列表（包含点播房间和直播房间）

```
/*
 *  获取正在直播聊天室列表
 *
 *  @param aCursor          游标
 *  @param aLimit           预期获取的记录数
 *  @video_type             直播间类型（vod：点播 live：直播）
 *  @param aCompletion      完成的回调block
 */
- (void)fetchLiveRoomsOngoingWithCursor:(NSString*)aCursor
                                  limit:(NSInteger)aLimit
                             video_type:(NSString*)video_type
                             completion:(void (^)(EMCursorResult *result, BOOL success))aCompletion;
```
- 进入某个直播间加入聊天室并且设置消息监听接收消息通知，观看直播

### 聊天室消息列表
聊天室消息列表及输入框为 UIKit中的功能，详情参考 chat-uikit 聊天室部分

## 新特性：自定义消息体 ##

- 本demo所实现的‘礼物’功能通过“自定义消息体”构建传输消息

**具体功能演示代码请参见 EaseCustomMessageHelper**

1、实现自定义消息帮助类接口协议再创建该类实例

```
@protocol EaseCustomMessageHelperDelegate <NSObject>

@optional

//观众点赞消息
- (void)didReceivePraiseMessage:(AgoraChatMessage *)message;

//弹幕消息
- (void)didSelectedBarrageSwitch:(AgoraChatMessage*)msg;

//观众刷礼物
- (void)steamerReceiveGiftId:(NSString *)giftId giftNum:(NSInteger )giftNum fromUser:(NSString *)userId ;

@end


- 创建实例
/// create a EaseCustomMessageHelper Instance
/// @param customMsgImp a delegate which implment EaseCustomMessageHelperDelegate
/// @param chatId a chatroom Id
- (instancetype)initWithCustomMsgImp:(id<EaseCustomMessageHelperDelegate>)customMsgImp chatId:(NSString*)chatId;
```
2、发送包含自定义消息体的消息

```
/*
 send custom message (gift,like,Barrage)
 @param text                 Message content
 @param num                  Number of message content
 @param messageType          chat type
 @param customMsgType        custom message type
 @param aCompletionBlock     send completion callback
*/
- (void)sendCustomMessage:(NSString*)text
                      num:(NSInteger)num
                       to:(NSString*)toUser
              messageType:(AgoraChatType)messageType
            customMsgType:(customMessageType)customMsgType
               completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;

/*
 send custom message (gift,like,Barrage) (with extended parameters)
 @param text                 Message content
 @param num                  Number of message content
 @param messageType          chat type
 @param customMsgType        custom message type
 @param ext              message extension
 @param aCompletionBlock     send completion callback
*/
- (void)sendCustomMessage:(NSString*)text
                      num:(NSInteger)num
                       to:(NSString*)toUser
              messageType:(AgoraChatType)messageType
            customMsgType:(customMessageType)customMsgType
                      ext:(NSDictionary*)ext
               completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;
```

3、发送用户自定义消息体事件（其他自定义消息体事件）

```
/*
 send user custom message (Other custom message body events)
 
@param event                custom message body event
@param customMsgBodyExt     custom message body event parameters
@param to                   message receiver
@param messageType          chat type
@param aCompletionBlock     send completion callback
*/
- (void)sendUserCustomMessage:(NSString*)event
             customMsgBodyExt:(NSDictionary*)customMsgBodyExt
                           to:(NSString*)toUser
                  messageType:(AgoraChatType)messageType
                   completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;

/*
 send user custom message (Other custom message body events) (extension parameters)
 
@param event                custom message body event
@param customMsgBodyExt     custom message body event parameters
@param to                   message receiver
@param messageType          chat type
@param ext                  message extension
@param aCompletionBlock     send completion callback
*/
- (void)sendUserCustomMessage:(NSString*)event
             customMsgBodyExt:(NSDictionary*)customMsgBodyExt
                           to:(NSString*)toUser
                  messageType:(AgoraChatType)messageType
                          ext:(NSDictionary*)ext
                   completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;
```


4、直播聊天室礼物消息展示

```
//有观众送礼物
- (void)userSendGiftId:(NSString *)giftId
               giftNum:(NSInteger)giftNum
                userId:(NSString *)userId
              backView:(UIView*)backView;
```


