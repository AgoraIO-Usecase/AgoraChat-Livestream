# Introduction

This demo demonstrates the live chat room implemented by Huanxin SDK and Huanxin appServer.

## How to use this demo

- First, Clone the code locally, and then NPM install or YARN install the dependencies.
- When you enter the app for the first time, a UUID guest account will be automatically registered, the default password is 123456, the registration is successful and the automatic login is completed, and the automatic login is completed and jumps to the main page.
- To Refresh, click Refresh to pull up the newly created live chat room.
- After successful login, the Channel List will be automatically loaded. Visitors can click any broadcasting room in the broadcasting hall to enter the broadcasting room to watch the broadcasting. Chat messages can be sent to the anchors in the broadcasting room, and the audience in the current chat room can receive the message animation.

## Function implementation

### Join the chat room

1. Pull up a list of live chat rooms.

```javascript
/**
 *  Pull up a list of live chat rooms
 */
curl -X GET http://localhost:8080/appserver/liverooms?limit=2&cursor=107776865009666 -H 'Authorization: Bearer $token ' -H 'Content-Type: application/json'
```

2. Join the chat room.

```javascript
/**
 *  Join the chat room
 *
 *  @param options
 *  @param roomId The chat room ID
 */

let options = {
  roomId: "roomId",
};
conn.joinChatRoom(options).then((res) => {
  console.log(res);
});
```

3. Listen for messages.

```javascript
conn.addEventHandler("CHATROOM", {
	onCustomMessage: (msg) => {   			// A custom message was received.
		console.log('onCustomMessage',msg);
	},
	onTextMessage: (msg) => {   			// A text message was received.
		console.log('onTextMessage',msg);
	},
	onChatroomChange: (event) => {
		console.log('onChatroomChange',event); // The chat room notification event was received.
	}
)
```

4. Send a text message.

```javascript
function sendPrivateText() {
  let option = {
    chatType: "chatRoom", // Session type, set to chat room.
    type: "txt", // Message type.
    to: "roomId", // Message receiver (user ID).
    msg: "message content", // Message content.
  };
  let msg = WebIM.message.create(option);
  connection
    .send(msg)
    .then(() => {
      console.log("send private text Success");
    })
    .catch((e) => {
      console.log("Send private text error");
    });
}
```

5. Get the live chat room details from the appServer and get the membership list.

```
/**
 * Get the live chat room details
 */
curl -X GET http://localhost:8080/appserver/liverooms/107776865009665 -H 'Authorization: Bearer $token' -H 'Content-Type: application/json'
```

6. Get a mute list of live chat room.

```javascript
/**
 * Gets all muted members in the chat room.
 */

conn.getChatRoomMutelist({ chatRoomId: "chatRoomId" });
```

7. Unmutes a live chat room audience.

```javascript
/**
 * Unmutes the chat room member. Only the chat room owner can call this method.
 */

conn.unmuteChatRoomMember({ chatRoomId: "chatRoomId", username: "user1" });
```

8. get the allow list of the live chat room.

```javascript
/**
 * Gets the allow list of the chat room.
 *
 * Only the chat room owner or admin can call this method.
 */
conn.getChatRoomWhitelist({ chatRoomId: "chatRoomId" });
```

9. Remove the audience from the allow list.

```javascript
/**
 * Removes members from the allow list of the chat room. Only the chat room owner or admin can call this method.
 */
conn.removeChatRoomAllowlistMember({
  chatRoomId: "chatRoomId",
  userName: "user1",
});
```

### Chat room message list

The chat room message list and input box are functions in UIKit. For details, please refer to the chat room section of chat-uikit

## New feature: custom message body

The "gift" function implemented by this demo uses "custom message body" to construct transmission messages

```javascript
function sendCustomMsg() {
  let option = {
    chatType: "chatRoom",
    type: "custom",
    to: "userID",
    customEvent: "chatroom_gift", // Custom Events
    customExts: {
      gift_id: "gift_id",
      gift_num: "gift_num",
    },
  };
  let msg = WebIM.message.create(option);
  connection
    .send(msg)
    .then(() => {
      console.log("success");
    })
    .catch((e) => {
      console.log("fail");
    });
}
```
