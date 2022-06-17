package io.agora.livedemo.common.repository;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import io.agora.chat.ChatClient;
import io.agora.chat.ChatManager;
import io.agora.chat.ChatRoomManager;
import io.agora.livedemo.common.utils.ThreadManager;

public class BaseEMRepository {

    /**
     * return a new liveData
     *
     * @param item
     * @param <T>
     * @return
     */
    public <T> LiveData<T> createLiveData(T item) {
        return new MutableLiveData<>(item);
    }

    /**
     * login before
     *
     * @return
     */
    public boolean isLoggedIn() {
        return ChatClient.getInstance().isLoggedInBefore();
    }

    /**
     * get current user
     *
     * @return
     */
    public String getCurrentUser() {
        return ChatClient.getInstance().getCurrentUser();
    }

    /**
     * EMChatManager
     *
     * @return
     */
    public ChatManager getChatManager() {
        return ChatClient.getInstance().chatManager();
    }

    /**
     * EMChatRoomManager
     *
     * @return
     */
    public ChatRoomManager getChatRoomManager() {
        return ChatClient.getInstance().chatroomManager();
    }

    public void runOnMainThread(Runnable runnable) {
        ThreadManager.getInstance().runOnMainThread(runnable);
    }

    public void runOnIOThread(Runnable runnable) {
        ThreadManager.getInstance().runOnIOThread(runnable);
    }

}
