package io.agora.livedemo.ui.fast.presenter;


import io.agora.live.fast.presenter.FastHostPresenter;
import io.agora.livedemo.common.utils.ThreadManager;
import io.agora.livedemo.data.model.AgoraTokenBean;
import io.agora.livedemo.data.restapi.LiveException;
import io.agora.livedemo.data.restapi.LiveManager;
import retrofit2.Response;

public class FastLiveHostPresenterImpl extends FastHostPresenter {
    @Override
    public void onStartCamera() {
        runOnUI(() -> {
            if (isActive()) {
                mView.onStartBroadcast();
            }
        });
    }

    @Override
    public void switchCamera() {
        runOnUI(() -> {
            if (isActive()) {
                mView.switchCamera();
            }
        });
    }

    @Override
    public void leaveChannel() {
        runOnUI(() -> {
            if (isActive()) {
                mView.onLeaveChannel();
            }
        });
    }

    @Override
    public void getFastToken(String hxId, String channel, String hxAppkey, int uid, boolean isRenew) {
        ThreadManager.getInstance().runOnIOThread(() -> {
            try {
                Response<AgoraTokenBean> response = LiveManager.getInstance().getAgoraToken(hxId, channel, hxAppkey, uid);
                runOnUI(() -> {
                    if (isActive()) {
                        mView.onGetTokenSuccess(response.body().getAccessToken(), response.body().getAgoraUserId(), isRenew);
                    }
                });
            } catch (LiveException e) {
                e.printStackTrace();
                runOnUI(() -> {
                    if (isActive()) {
                        mView.onGetTokenFail(e.getDescription());
                    }
                });
            }
        });
    }

    @Override
    public void deleteRoom(String chatroomId) {
        ThreadManager.getInstance().runOnIOThread(() -> {
            LiveManager.getInstance().deleteRoom(chatroomId);
        });
    }
}

