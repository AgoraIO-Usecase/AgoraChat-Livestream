package io.agora.livedemo.ui.fast.presenter;

import io.agora.live.fast.presenter.FastAudiencePresenter;
import io.agora.livedemo.common.utils.ThreadManager;
import io.agora.livedemo.data.model.AgoraTokenBean;
import io.agora.livedemo.data.restapi.LiveException;
import io.agora.livedemo.data.restapi.LiveManager;
import retrofit2.Response;

public class FastLiveAudiencePresenterImpl extends FastAudiencePresenter {
    @Override
    public void onLiveClosed() {
        runOnUI(() -> {
            if (isActive()) {
                mView.onLiveClosed();
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
}

