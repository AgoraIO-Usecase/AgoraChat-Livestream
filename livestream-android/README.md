# Introduction to Agora Live Chat Room

## Introduction

**Agora Live Chat Room (hereinafter referred to as Agora Chat Room) demonstrates the ability of Agora SDK to provide live chat rooms. In addition to providing basic chat, it also provides custom messages for gift giving, and developers can add new custom messages according to their actual needs. **

**Introduction to core classes:**

- CdnLiveAudienceActivity: Audience live room page</br>
- CdnLiveHostActivity: host live page</br>
- LiveAudienceFragment: Integrate audience chat room related logic</br>
- LiveAnchorFragment: Integrate the logic related to the chat room on the anchor side</br>

**Other side open source address:**

- iOS:    https://github.com/winskyan/AgoraChat-Livestream/tree/main/livestream-ios
- Web:    https://github.com/winskyan/AgoraChat-Livestream/tree/main/livestream-web
- App Server:     https://github.com/winskyan/AgoraChat-Livestream/tree/main/backend

## Integrate Agora Chat SDK

### Development Environment Requirements

- Android Studio 3.2 or higher. </br>
- SDK targetVersion is at least 26.

### Add remote dependencies

```
implementation 'io.agora.rtc:chat-sdk:1.0.6'
implementation 'io.agora.rtc:chat-uikit:1.0.6'
```

**Integration Documentation:**</br>

- [Android SDK integrated](https://docs-preprod.agora.io/cn/agora-chat/enable_agora_chat?platform=Android);</br>
- [Android UIKit integrated](https://github.com/AgoraIO-Usecase/AgoraChat-UIKit-android);

## use AgoraChat-UIKit

**In order to facilitate developers to use custom messages, Agora chat room encapsulates the logic related to custom messages into the AgoraChat-UIKit-android library. **

Developers can make changes to this UIKit library according to their needs.

### Core class introduction

- EaseChatRoomMessagesView: Live chat room message UI, users can customize related properties to set UI display. </br>
- EaseLiveMessageHelper: used to monitor and receive custom messages and send custom messages. </br>
- EaseLiveMessageType: The user defines the custom message type (gift message) used in the demo. </br>
- OnLiveMessageListener: Listen to chat room messages to receive related events.

### Specific usage

#### 1. After the chat room is loaded, initialize it and set the room information.

```Java
EaseLiveMessageHelper.getInstance().init(chatroomId);
```

#### 2. add and remove chat room custom message monitoring

```Java
EaseLiveMessageHelper.getInstance().addLiveMessageListener(new OnLiveMessageListener() {
    @Override
    public void onGiftMessageReceived(ChatMessage message) {

    }
});
EaseLiveMessageHelper.getInstance().removeLiveMessageListener(this);
```

#### 3. To send a chat room message, you can call the following method

```Java
public void sendTxtMsg(String content, OnSendLiveMessageCallBack callBack);                                                       //text message

public void sendGiftMsg(String chatRoomId, String giftId, int num, OnSendLiveMessageCallBack callBack);                           //gift message

public void sendCustomMsg(String chatRoomId, String event, Map<String, String> params, final OnSendLiveMessageCallBack callBack); //custom message
```

#### 4. Parse message related parameters</br>

(1) If the sent custom parameters are the same as those in UIKit, you can directly call the following method to get the transmitted data

```Java
//Get the id of the gift in the gift message
public String getMsgGiftId(ChatMessage msg);
// Get the number of gifts in the gift message
public int getMsgGiftNum(ChatMessage msg);
```

(2) If the custom message parameters are different from those in UIKit, you can call the following method to get the parameters in the message

```Java
public Map<String, String> getCustomMsgParams(ChatMessage message);
```

#### 5. UIKit also provides a method to determine the type of custom message

```Java
public boolean isGiftMsg(ChatMessage msg);    // gift message judgment
```

## Agora Live Chat Room Architecture Introduction

![](https://developer.android.google.cn/topic/libraries/architecture/images/final-architecture.png)</br>
There are two repositories in Agora chat room, ClientRepository and AppServerRepository. Where ClientRepository user handles Agora SDK provides
For related requests, the AppServerRepository user handles the interface provided by the app server. Each page has a corresponding ViewModel to store and manage in a life cycle manner
Manage UI-related data. LiveData is an observable data retention class with lifecycle awareness, generally located in ViewModel, for observing data changes. </br>

## Integrate Agora Live Video SDK

Agora chat room provides Agora CDN live streaming capability (https://docs.agora.io/cn/live-streaming/landing-page?platform=Android).


## Documentation

- [iOS open source address](https://github.com/winskyan/AgoraChat-Livestream/tree/main/livestream-ios)
- [Web open source address](https://github.com/winskyan/AgoraChat-Livestream/tree/main/livestream-web)
- [App Server open source address](https://github.com/winskyan/AgoraChat-Livestream/tree/main/backend)
- [Android SDK integrated](https://docs-preprod.agora.io/cn/agora-chat/enable_agora_chat?platform=Android);</br>
- [Android UIKit integrated](https://github.com/AgoraIO-Usecase/AgoraChat-UIKit-android);

## For non-AndroidX builds ##

### 1. Running the demo without AndroidX builds, the following work can be done:

#### 1. Comment out the following settings in gradle.properties in the demo:

````Java
#android.enableJetifier=true //Android plugin will automatically migrate existing third-party libraries to use AndroidX by rewriting their binaries
#android.useAndroidX=true //Android plugin will use the corresponding AndroidX library instead of the support library
````

#### 2. Replace AndroidX build artifacts with old build artifacts

```Java
dependencies {
        ...
        implementation "com.jakewharton:butterknife:$butterknife_version"
        annotationProcessor "com.jakewharton:butterknife-compiler:$butterknife_version"
        implementation 'com.google.android.material:material:1.1.0'
        implementation 'androidx.constraintlayout:constraintlayout:1.1.3'
        implementation "androidx.lifecycle:lifecycle-livedata:$ax_lifecycle_version"
        implementation "androidx.lifecycle:lifecycle-viewmodel:$ax_lifecycle_version"
        implementation "androidx.lifecycle:lifecycle-extensions:$ax_lifecycle_version"
        implementation "androidx.room:room-runtime:$ax_room_version"
        annotationProcessor "androidx.room:room-compiler:$ax_room_version"
        implementation 'androidx.legacy:legacy-support-v4:1.0.0'
        ...
        }
```

change into:

```Java
dependencies {
        ...
        implementation "com.jakewharton:butterknife:9.0.0"
        annotationProcessor "com.jakewharton:butterknife-compiler:9.0.0"
        implementation 'com.android.support:design:28.0.0'
        implementation 'com.android.support.constraint:constraint-layout:1.1.3'
        implementation "android.arch.lifecycle:livedata:$ax_lifecycle_version"
        implementation "android.arch.lifecycle:viewmodel:$ax_lifecycle_version"
        implementation "android.arch.lifecycle:extensions:$ax_lifecycle_version"
        implementation "android.arch.persistence.room:runtime:$ax_room_version"
        annotationProcessor "android.arch.persistence.room:compiler:$ax_room_version"
        implementation 'com.android.support:support-v4:28.0.0'
        ...
        }
```

Note:

- Butterknife needs to be downgraded to 9.0.0 because it supports androidX above 10.0.0.
- The version number of ax_lifecycle_version, etc., can be searched through Add Library Dependency of Android Stuido. File ->Project Structure ->
  app ->Dependencies ->Click Add + in the upper right corner ->Library dependency ->Enter the name of the remote library to be searched, such as design.

If you encounter migration-related issues, please refer to these tables to determine the correct mapping from support libraries to corresponding AndroidX artifacts and classes:</br>

- [Maven Artifact Mappings](https://developer.android.google.cn/jetpack/androidx/migrate/artifact-mappings)</br>
- [Class Mappings](https://developer.android.google.cn/jetpack/androidx/migrate/class-mappings)</br>

#### 3. Globally replace the reference path of the control under androidX and the control path in xml, such as androidx.recyclerview.widget.RecyclerView -> android.support.v7.widget.RecyclerView. </br>

#### 4. Replace ViewPager2 with ViewPager, refer to: [Migrate from ViewPager to ViewPager2](https://developer.android.google.cn/training/animation/vp2-migration?hl=zh_cn)</br>

#### 5. Other matters not mentioned. </br>

### Second, only use the core classes in the demo

> If you only plan to use the core classes of the demo, it is recommended that you focus on the related classes in the io.agora.livedemo.ui.cdn directory. The core classes are CdnLiveHostActivity and CdnLiveAudienceActivity, and their corresponding fragments. Then start from these two activities, and gradually replace the androidX-related controls in the required classes.
