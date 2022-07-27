package io.agora.livedemo.ui.other.fragment;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import io.agora.chat.uikit.utils.EaseUserUtils;
import io.agora.chat.uikit.widget.EaseImageView;
import io.agora.livedemo.DemoConstants;
import io.agora.livedemo.R;
import io.agora.livedemo.common.utils.DemoHelper;
import io.agora.livedemo.common.livedata.LiveDataBus;
import io.agora.livedemo.ui.base.BaseLiveFragment;
import io.agora.livedemo.ui.other.AboutActivity;
import io.agora.livedemo.ui.widget.ArrowItemView;
import io.agora.livedemo.utils.Utils;
import io.agora.util.EMLog;

public class AboutMeFragment extends BaseLiveFragment {
    private EaseImageView userIcon;
    private TextView username;
    private ArrowItemView itemAbout;

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_about_me;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        userIcon = findViewById(R.id.user_icon);
        username = findViewById(R.id.username);
        itemAbout = findViewById(R.id.item_about);

        EaseUserUtils.setUserAvatar(mContext, DemoHelper.getAgoraId(), userIcon);

        EaseUserUtils.setUserNick(DemoHelper.getAgoraId(), username);

        itemAbout.setContent("V" + Utils.getAppVersionName(mContext));
    }

    @Override
    protected void initListener() {
        super.initListener();
        itemAbout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(mContext, AboutActivity.class);
                startActivity(intent);
            }
        });
    }

    @Override
    protected void initData() {
        super.initData();
        LiveDataBus.get().with(DemoConstants.NICKNAME_CHANGE, String.class)
                .observe(getViewLifecycleOwner(), response -> {
                    if (!TextUtils.isEmpty(response)) {
                        EaseUserUtils.setUserNick(response, username);
                    }
                });
        LiveDataBus.get().with(DemoConstants.AVATAR_CHANGE, Boolean.class)
                .observe(getViewLifecycleOwner(), response -> {
                    EMLog.i("lives","AVATAR_CHANGE");
                    EaseUserUtils.setUserAvatar(mContext, DemoHelper.getAgoraId(), userIcon);
                });
    }
}
