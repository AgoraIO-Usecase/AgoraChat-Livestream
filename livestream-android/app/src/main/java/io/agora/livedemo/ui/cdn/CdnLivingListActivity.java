package io.agora.livedemo.ui.cdn;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import io.agora.chat.uikit.widget.EaseTitleBar;
import io.agora.livedemo.R;
import io.agora.livedemo.ui.base.BaseLiveActivity;
import io.agora.livedemo.ui.cdn.fragment.CdnLivingListFragment;
import io.agora.livedemo.ui.other.CreateLiveRoomActivity;

public class CdnLivingListActivity extends BaseLiveActivity implements EaseTitleBar.OnBackPressListener, EaseTitleBar.OnRightClickListener {
    private EaseTitleBar titleBar;

    public static void actionStart(Context context) {
        Intent intent = new Intent(context, CdnLivingListActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_living;
    }

    @Override
    protected void initView() {
        super.initView();
        titleBar = findViewById(R.id.title_bar);
        titleBar.setTitle(getString(R.string.live_type_normal_title));
    }

    @Override
    protected void initListener() {
        super.initListener();
        titleBar.setOnBackPressListener(this);
        titleBar.setOnRightClickListener(this);
    }

    @Override
    protected void initData() {
        super.initData();
        CdnLivingListFragment fragment = new CdnLivingListFragment();
        Bundle bundle = new Bundle();
        bundle.putString("status", "ongoing");
        fragment.setArguments(bundle);
        getSupportFragmentManager().beginTransaction().replace(R.id.fl_fragment, fragment).commit();
    }

    @Override
    public void onBackPress(View view) {
        onBackPressed();
    }

    @Override
    public void onRightClick(View view) {
        CreateLiveRoomActivity.actionStart(mContext);
    }
}

