package io.agora.livedemo.ui.live.viewmodels;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.MediatorLiveData;

import java.util.List;

import io.agora.chat.ChatRoom;
import io.agora.livedemo.common.reponsitories.ClientRepository;
import io.agora.livedemo.common.reponsitories.Resource;

public class UserDetailManageViewModel extends AndroidViewModel {
    private final ClientRepository repository;
    private final MediatorLiveData<Resource<ChatRoom>> whiteObservable;
    private final MediatorLiveData<Resource<ChatRoom>> muteObservable;

    public UserDetailManageViewModel(@NonNull Application application) {
        super(application);
        repository = new ClientRepository();
        whiteObservable = new MediatorLiveData<>();
        muteObservable = new MediatorLiveData<>();
    }

    public MediatorLiveData<Resource<ChatRoom>> getWhiteObservable() {
        return whiteObservable;
    }

    public MediatorLiveData<Resource<ChatRoom>> getMuteObservable() {
        return muteObservable;
    }

    public void addToChatRoomWhiteList(String chatRoomId, List<String> members) {
        whiteObservable.addSource(repository.addToChatRoomWhiteList(chatRoomId, members),
                response -> whiteObservable.postValue(response));
    }


    public void removeFromChatRoomWhiteList(String chatRoomId, List<String> members) {
        whiteObservable.addSource(repository.removeFromChatRoomWhiteList(chatRoomId, members),
                response -> whiteObservable.postValue(response));
    }


    public void muteChatRoomMembers(String chatRoomId, List<String> members, long duration) {
        muteObservable.addSource(repository.MuteChatRoomMembers(chatRoomId, members, duration),
                response -> muteObservable.postValue(response));
    }

    public void unMuteChatRoomMembers(String chatRoomId, List<String> members) {
        muteObservable.addSource(repository.unMuteChatRoomMembers(chatRoomId, members),
                response -> muteObservable.postValue(response));
    }
}
