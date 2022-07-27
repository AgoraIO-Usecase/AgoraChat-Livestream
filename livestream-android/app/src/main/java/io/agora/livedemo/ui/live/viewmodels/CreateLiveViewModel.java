package io.agora.livedemo.ui.live.viewmodels;

import android.app.Application;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Transformations;

import io.agora.chat.ChatClient;
import io.agora.livedemo.common.enums.Status;
import io.agora.livedemo.common.livedata.SingleSourceLiveData;
import io.agora.livedemo.common.repository.AppServerRepository;
import io.agora.livedemo.common.repository.ClientRepository;
import io.agora.livedemo.common.repository.Resource;
import io.agora.livedemo.common.utils.DemoHelper;
import io.agora.livedemo.data.model.LiveRoom;
import io.agora.livedemo.data.repository.UserRepository;

public class CreateLiveViewModel extends AndroidViewModel {
    private final AppServerRepository repository;
    private final ClientRepository clientRepository;
    private final SingleSourceLiveData<Resource<LiveRoom>> createObservable;

    public CreateLiveViewModel(@NonNull Application application) {
        super(application);
        repository = new AppServerRepository();
        clientRepository = new ClientRepository();
        createObservable = new SingleSourceLiveData<>();
    }

    public LiveData<Resource<LiveRoom>> getCreateObservable() {
        return createObservable;
    }

    /**
     * create live room
     *
     * @param name
     * @param description
     * @param localPath
     */
    public void createLiveRoom(String name, String description, String localPath) {
        LiveData<Resource<LiveRoom>> liveData = null;
        if (TextUtils.isEmpty(localPath)) {
            LiveRoom liveRoom = getLiveRoom(name, description, null);
            liveData = repository.createLiveRoom(liveRoom);
        } else {
            liveData = Transformations.switchMap(clientRepository.updateRoomCover(localPath), input -> {
                if (input.status == Status.ERROR) {
                    return new MutableLiveData<>(Resource.error(input.errorCode, input.getMessage(), null));
                } else if (input.status == Status.SUCCESS) {
                    LiveRoom liveRoom = getLiveRoom(name, description, input.data);
                    return repository.createLiveRoom(liveRoom);
                } else {
                    return new MutableLiveData<>(Resource.loading(null));
                }
            });
        }
        createObservable.setSource(liveData);
    }

    /**
     * create live room
     *
     * @param name
     * @param description
     * @param localPath
     * @param videoType
     */
    public void createLiveRoom(String name, String description, String localPath, String videoType) {
        LiveData<Resource<LiveRoom>> liveData = null;
        if (TextUtils.isEmpty(localPath)) {
            LiveRoom liveRoom = getLiveRoom(name, description, videoType, UserRepository.getInstance().getUserInfo(DemoHelper.getAgoraId()).getAvatar());
            liveData = repository.createLiveRoom(liveRoom);
        } else {
            liveData = Transformations.switchMap(clientRepository.updateRoomCover(localPath), input -> {
                if (input.status == Status.ERROR) {
                    return new MutableLiveData<>(Resource.error(input.errorCode, input.getMessage(), null));
                } else if (input.status == Status.SUCCESS) {
                    LiveRoom liveRoom = getLiveRoom(name, description, videoType, input.data);
                    return repository.createLiveRoom(liveRoom);
                } else {
                    return new MutableLiveData<>(Resource.loading(null));
                }
            });
        }
        createObservable.setSource(liveData);
    }

    private LiveRoom getLiveRoom(String name, String description, String cover) {
        LiveRoom liveRoom = new LiveRoom();
        liveRoom.setName(name);
        liveRoom.setDescription(description);
        liveRoom.setOwner(ChatClient.getInstance().getCurrentUser());
        liveRoom.setCover(cover);
        liveRoom.setMaxusers(200);
        liveRoom.setPersistent(false);
        return liveRoom;
    }

    private LiveRoom getLiveRoom(String name, String description, String videoType, String cover) {
        LiveRoom liveRoom = new LiveRoom();
        liveRoom.setName(name);
        liveRoom.setDescription(description);
        liveRoom.setOwner(ChatClient.getInstance().getCurrentUser());
        liveRoom.setVideo_type(videoType);
        liveRoom.setCover(cover);
        liveRoom.setMaxusers(200);
        //The live room is persistent by default. If you want the host to leave the room and destroy it after a period of time, you need to actively set it to false
        liveRoom.setPersistent(false);
        return liveRoom;
    }
}
