# Introduction #
This demo demonstrates the live chat room implemented by Huanxin SDK and Huanxin appServer

## How to use this demo ##
- First, execute pod install under the EaseMobLiveDemo folder, and integrate Huanxin SDK
- When you enter the app for the first time, a UUID guest account will be automatically registered, the default password is 000000, the registration is successful and the automatic login is completed, and the automatic login is completed and jumps to the main page
- Click the red button at the bottom of the homepage to create a live broadcast room. After entering the cover image and the theme of this live broadcast, click "Start Live" to start a live broadcast. The live broadcast room will appear in the "Live Broadcast Lobby" list. "Live Lobby" to enter the live room
- Visitors can click on any live broadcast room in the live broadcast hall to enter the live broadcast room to watch the live broadcast. In the live broadcast room, chat messages can currently be sent to the host to swipe gifts, and the current live broadcast room chat room viewers can receive message animations

## Function implementation ##


### Create live chat room
**For the specific demo code, see EaseLiveTVListViewController, ELDPreLivingViewController, ELDPublishLiveViewController, EaseHttpManager**

#### 1. Create a live chat room

````
/*
 * Create live chat rooms
 *
 * @param aRoom live chat room
 * @param aCompletion completed callback block
 */
- (void)createLiveRoomWithRoom:(EaseLiveRoom*)aRoom
                    completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
````

#### 2. After the creation is successful, set the current live chat room to be live broadcast to "ongoing" live broadcast status


````
/*
* Update the live room status to ongoing
*
* @param aRoom live room
* @param aCompletion completed callback block
*/
- (void)modifyLiveroomStatusWithOngoing:(EaseLiveRoom *)room
                             completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
````

#### 3.Join the chat room

````
/*
 * User joins live chat room
 *
 * @param aRoomId Live chat room ID
 * @param aChatroomId chat room ID
 * @param aIsCount whether to count
 * @param aCompletion completed callback block
 */
- (void)joinLiveRoomWithRoomId:(NSString*)aRoomId
                    chatroomId:(NSString*)aChatroomId
                       isCount:(BOOL)aIsCount
                       completion:(void (^)(BOOL success))aCompletion;
````

#### 4. Set up message monitoring

````
[[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];

- (void)messagesDidReceive:(NSArray *)aMessages
{
// receive normal message
}

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
{
//Receive cmd message
}
````

#### 5. Send a message

````
EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"Send content"];
NSString *from = [[EMClient sharedClient] currentUsername];
EMMessage *message = [[EMMessage alloc] initWithConversationID:aChatroomId from:from to:aChatroomId body:body ext:nil];
message.chatType = EMChatTypeChatRoom;
[[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
if (!error) {
// message sent successfully
}
}];
````


#### 6. Get the details of the live chat room from appServer and get the member list

````
/*
* Get live chat room details
*
* @param aRoom live chat room
* @param aCompletion completed callback block
*/
- (void)fetchLiveroomDetail:(NSString *)roomId completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
````

#### 7. Get the banned list of live chat rooms

````
/**
 * \~chinese
 * Mute a group of members.
 *
 * Only chat room owners and admins can call this method.
 *
 * Asynchronous method.
 *
 * @param aMuteMembers List of members to mute.
 * @param aMuteMilliseconds Mute duration
 * @param aChatroomId The chat room ID.
 * @param aCompletionBlock The callback for the method completion call. If the method call fails, the reason for the call failure is included.
 *
 * \~english
 * Mutes chatroom members.
 *
 * Only the chatroom owner or admin can call this method.
 *
 * This is an asynchronous method.
 *
 * @param aMuteMembers The list of mutes.
 * @param aMuteMilliseconds Muted time duration in millisecond
 * @param aChatroomId The chatroom ID.
 * @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)muteMembers:(NSArray<NSString *> *_Nonnull)aMuteMembers
   muteMilliseconds: (NSInteger) aMuteMilliseconds
       fromChatroom:(NSString *_Nonnull)aChatroomId
         completion:(void (^_Nullable )(AgoraChatroom *_Nullable aChatroom, AgoraChatError *_Nullable aError))aCompletionBlock;
````

#### 8. A viewer in the live chat room lifts the ban

````
/*!
 * Unmute, requires Owner / Admin privileges
 *
 * @param aMuteMembers List of dismissed <NSString>
 * @param aChatroomId chat room ID
 * @param aCompletionBlock completion callback
 */
- (void)unmuteMembers:(NSArray *)aMembers
                 fromChatroom:(NSString *)aChatroomId
                 completion:(void (^)(EMChatroom *aChatroom, EMError *aError))aCompletionBlock;
````

#### 9. Get the whitelist list of live chat rooms

````
/*!
 * Get chat room whitelist list
 *
 * @param aChatroomId chat room ID
 * @param aCompletionBlock completion callback
 */
- (void)getChatroomWhiteListFromServerWithId:(NSString *)aChatroomId
        completion:(void (^)(NSArray *aList, EMError *aError))aCompletionBlock;
````

#### 10. Remove members from the whitelist in the live chat room

````
/*!
 * Remove the whitelist, requires Owner / Admin permissions
 *
 * @param aMembers List of removed <NSString>
 * @param aChatroomId chat room ID
 * @param aCompletionBlock completion callback
 */
- (void)removeWhiteListMembers:(NSArray *)aMembers
                  fromChatroom:(NSString *)aChatroomId
                  completion:(void (^)(EMChatroom *aChatroom, EMError *aError))aCompletionBlock;
````

#### 11. All live chat rooms are banned

````
/*!
 * To set all members to mute, requires Owner / Admin privileges
 *
 * @param aChatroomId chat room ID
 * @param aCompletionBlock completion callback
 */
- (void)muteAllMembersFromChatroom:(NSString *)aChatroomId
                  completion:(void(^)(EMChatroom *aChatroom, EMError *aError))aCompletionBlock;
````


#### 12. Remove all bans in the live chat room

````
/*!
 * To lift the ban on all members, Owner / Admin permissions are required
 *
 * Synchronous method, will block the current thread
 *
 * @param aChatroomId chat room ID
 * @param pError error message
 *
 * @result chat room instance
 */
- (EMChatroom *)unmuteAllMembersFromChatroom:(NSString *)aChatroomId
                  error:(EMError **)pError;
````
- All bans in the live chat room are not directly related to the audience ban list and do not affect each other


#### 13. Leave the chat room and set the current live chat room to "Offline" and end the live broadcast

````
/*
 * User leaves live chat room
 *
 * @param aRoomId Live chat room ID
 * @param aChatroomId chat room ID
 * @param aIsCount whether to count
 * @param aCompletion completed callback block
 */
- (void)leaveLiveRoomWithRoomId:(NSString*)aRoomId
                     chatroomId:(NSString*)aChatroomId
                        isCount:(BOOL)aIsCount
                        completion:(void (^)(BOOL success))aCompletion;
                        
- Update live chat room status to Offline
/*
* Update the live room status to offline
*
* @param aRoom live room
* @param aCompletion completed callback block
*/
- (void)modifyLiveroomStatusWithOffline:(EaseLiveRoom *)room
                             completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
````

### Watch live
**Refer to demo EaseLiveViewController, ELDLiveListViewController for specific code**

1. Get the list of live chat rooms currently being broadcast (including on-demand rooms and live rooms)

````
/*
 * Get the list of live chat rooms
 *
 * @param aCursor cursor
 * @param aLimit the expected number of records to get
 * @video_type live room type (vod: on-demand live: live broadcast)
 * @param aCompletion completed callback block
 */
- (void)fetchLiveRoomsOngoingWithCursor:(NSString*)aCursor
                                  limit:(NSInteger)aLimit
                             video_type:(NSString*)video_type
                             completion:(void (^)(EMCursorResult *result, BOOL success))aCompletion;
````
- Enter a live room to join the chat room and set up message monitoring to receive message notifications and watch the live broadcast

### Chat room message list
The chat room message list and input box are functions in UIKit. For details, please refer to the chat room section of chat-uikit

## New feature: custom message body ##

- The "gift" function implemented by this demo uses "custom message body" to construct transmission messages

**For specific function demonstration code, please refer to EaseCustomMessageHelper**

1. Implement the custom message helper class interface protocol and then create an instance of this class

````
@protocol EaseCustomMessageHelperDelegate <NSObject>

@optional

// Viewer likes the message
- (void)didReceivePraiseMessage:(AgoraChatMessage *)message;

// barrage message
- (void)didSelectedBarrageSwitch:(AgoraChatMessage*)msg;

// Spectator brushes gifts
- (void)steamerReceiveGiftId:(NSString *)giftId giftNum:(NSInteger )giftNum fromUser:(NSString *)userId ;

@end


- create instance
/// create a EaseCustomMessageHelper Instance
/// @param customMsgImp a delegate which implment EaseCustomMessageHelperDelegate
/// @param chatId a chatroom Id
- (instancetype)initWithCustomMsgImp:(id<EaseCustomMessageHelperDelegate>)customMsgImp chatId:(NSString*)chatId;
````


2. Send a message containing a custom message body

````
/*
 send custom message (gift,like,Barrage)
 @param text Message content
 @param num Number of message content
 @param messageType chat type
 @param customMsgType custom message type
 @param aCompletionBlock send completion callback
*/
- (void)sendCustomMessage:(NSString*)text
                      num:(NSInteger)num
                       to:(NSString*)toUser
              messageType:(AgoraChatType)messageType
            customMsgType:(customMessageType)customMsgType
               completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;

/*
 send custom message (gift,like,Barrage) (with extended parameters)
 @param text Message content
 @param num Number of message content
 @param messageType chat type
 @param customMsgType custom message type
 @param ext message extension
 @param aCompletionBlock send completion callback
*/
- (void)sendCustomMessage:(NSString*)text
                      num:(NSInteger)num
                       to:(NSString*)toUser
              messageType:(AgoraChatType)messageType
            customMsgType:(customMessageType)customMsgType
                      ext:(NSDictionary*)ext
               completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;
````


3. Send user-defined message body events (other custom message body events)

````
/*
 send user custom message (Other custom message body events)
 
@param event custom message body event
@param customMsgBodyExt custom message body event parameters
@param to message receiver
@param messageType chat type
@param aCompletionBlock send completion callback
*/
- (void)sendUserCustomMessage:(NSString*)event
             customMsgBodyExt:(NSDictionary*)customMsgBodyExt
                           to:(NSString*)toUser
                  messageType:(AgoraChatType)messageType
                   completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;

/*
 send user custom message (Other custom message body events) (extension parameters)
 
@param event custom message body event
@param customMsgBodyExt custom message body event parameters
@param to message receiver
@param messageType chat type
@param ext message extension
@param aCompletionBlock send completion callback
*/
- (void)sendUserCustomMessage:(NSString*)event
             customMsgBodyExt:(NSDictionary*)customMsgBodyExt
                           to:(NSString*)toUser
                  messageType:(AgoraChatType)messageType
                          ext:(NSDictionary*)ext
                   completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;
````

3、Receive gift callback

```
// Occured when receive a gift from someone
- (void)userSendGiftId:(NSString *)giftId
               giftNum:(NSInteger)giftNum
                userId:(NSString *)userId
              backView:(UIView*)backView;
```


