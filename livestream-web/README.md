# 简介 #
本demo演示了通过环信SDK以及环信appServer实现的直播聊天室

## 怎么使用本demo ##
- 首先将代码 clone 到本地，然后 npm install 或 yarn 安装依赖
- 初次进入app时会自动注册一个UUID游客账号，默认密码 123456，注册成功自动登录，自动登录完成跳转到主页面
- 如需刷新，点击 Refresh 刷新，可拉取新创建的直播聊天室
- 登陆成功后自动加载 Channel List，游客点击直播大厅任一直播间即可进入该直播间观看直播，直播间内目前可以发聊天消息给主播刷礼物，当前直播间聊天室观众均可收到消息动画

## 功能实现 ##


### 创建直播聊天室
**具体演示代码见EaseLiveTVListViewController,ELDPreLivingViewController,ELDPublishLiveViewController,EaseHttpManager**

1、拉取直播聊天室列表
```
/*
 *  拉取直播聊天室列表
 *
 *  @param aRoom           直播聊天室
 */
curl -X GET http://localhost:8080/appserver/liverooms?limit=2&cursor=107776865009666 -H 'Authorization: Bearer $token ' -H 'Content-Type: application/json'
```
2、加入聊天室

```
/*
 *  用户加入直播聊天室
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aChatroomId      聊天室ID
 */
 
  let options = {
    roomId: 'roomId',   // 聊天室id
    message: 'reason'   // 原因（可选参数）
  }
  conn.joinChatRoom(options).then((res) => {
    console.log(res)
  })

```
3、设置消息监听

```
	 conn.addEventHandler("CHATROOM", {
		onCustomMessage: (msg) => {   			// 收到自定义消息
			console.log('onCustomMessage',msg);
		},
		onTextMessage: (msg) => {   			// 收到普通文本消息
			console.log('onTextMessage',msg);
		},
		onChatroomChange: (event) => {
			console.log('onChatroomChange',event); //聊天室通知事件
		}
```
4、发送普通文本消息

```
function sendPrivateText() {
    let option = {
        chatType: 'chatRoom',    // 会话类型，设置为聊天室。
        type: 'txt',               // 消息类型。
        to: 'roomId',              // 消息接收方（用户 ID)。
        msg: 'message content'     // 消息内容。
    }
    let msg = WebIM.message.create(option); 
    connection.send(msg).then(() => {
        console.log('send private text Success');  
    }).catch((e) => {
        console.log("Send private text error");  
    })
}; 
```
5、从appServer获取直播聊天室详情并获取成员列表

```
/*
*  获取直播聊天室详情
*
*  @param aRoom            直播聊天室
*/
curl -X GET http://localhost:8080/appserver/liverooms/107776865009665 -H 'Authorization: Bearer $token' -H 'Content-Type: application/json'
```
6、获取直播聊天室禁言列表

```
/**
 *  \~chinese
 *  将一组成员禁言。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 *
 */
 let option = {
    groupId: "groupId"
};
conn.getGroupMuteList(option).then(res => console.log(res))

```
7、直播聊天室某观众解除禁言

```
/*!
 *  解除禁言，需要Owner / Admin权限
 *
 *  @param aMuteMembers     被解除的列表<NSString>
 *  @param aChatroomId      聊天室ID
 * 
 */
let option = {
    groupId: "groupId",
    username: "user"
};
conn.unmuteGroupMember(option).then(res => console.log(res))
```
8、获取直播聊天室白名单列表

```
/*!
 *  获取聊天室白名单列表
 *
 *  @param aChatroomId      聊天室ID
 *  
 */
let options = {
    groupId: "groupId"
}
conn.getGroupWhitelist(options).then(res => console.log(res));
```
9、直播聊天室从白名单移除成员

```
/*!
 *  移除白名单，需要Owner / Admin权限
 *
 *  @param aMembers         被移除的列表<NSString>
 *  @param aChatroomId      聊天室ID
 */
let option = {
    groupId: "groupId",
    userName: "user"
}
conn.removeGroupWhitelistMember(option).then(res => console.log(res));
```


### 聊天室消息列表
聊天室消息列表及输入框为 UIKit中的功能，详情参考 message 聊天室部分



## 新特性：自定义消息体 ##

- 本demo所实现的‘礼物’功能通过“自定义消息体”构建传输消息

**具体功能演示代码请参见 EaseCustomMessageHelper**

1、实现自定义消息

```
function sendCustomMsg() {
    let option = {
        chatType: 'chatRoom',
        type: 'custom',
        to: 'userID',                        // 接收消息对象（用户 ID）   
        customEvent: 'chatroom_gift',          // 自定义事件。
        customExts: {
            gift_id: "gift_id",
        	gift_num: "gift_num"
        },                      // 消息内容，key/value 需要 string 类型。
        ext:{}                               // 消息扩展。
    }
    let msg = WebIM.message.create(option)
    connection.send(msg).then(() => {
        console.log('success');  // 消息发送成功。
    }).catch((e) => {
        console.log("fail");     // 如禁言或拉黑后消息发送失败。
    });
};
```






