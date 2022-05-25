package io.agora.livedemo.ui.other;

import android.content.Intent;
import android.net.Uri;
import android.view.View;

import io.agora.chat.ChatClient;
import io.agora.livedemo.R;
import io.agora.livedemo.databinding.ActivityAboutBinding;
import io.agora.livedemo.ui.base.BaseLiveActivity;
import io.agora.livedemo.utils.Utils;

public class AboutActivity extends BaseLiveActivity implements View.OnClickListener {

    private ActivityAboutBinding mBinding;

    @Override
    protected View getContentView() {
        mBinding = ActivityAboutBinding.inflate(getLayoutInflater());
        return mBinding.getRoot();
    }

    @Override
    protected void initView() {
        super.initView();
        mBinding.titlebarTitle.setTypeface(Utils.getRobotoTypeface(this.getApplicationContext()));
    }


    @Override
    protected void initListener() {
        super.initListener();
        mBinding.itemPolicy.setOnClickListener(this);
        mBinding.itemMore.setOnClickListener(this);

        mBinding.titleBar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });

        mBinding.titlebarTitle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
    }

    @Override
    protected void initData() {
        super.initData();
        mBinding.itemSdkVersion.setContent("V" + ChatClient.VERSION);
        mBinding.itemLibVersion.setContent("V" + Utils.getAppVersionName(mContext));
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.item_policy:
                startToWeb("https://www.agora.io/cn/v2?utm_source=baidu&utm_medium=cpc&utm_campaign=brand");
                break;
            case R.id.item_more:
                startToWeb("https://www.agora.io/en");
                break;
        }
    }

    private void startToWeb(String url) {
        Uri uri = Uri.parse(url);
        Intent it = new Intent(Intent.ACTION_VIEW, uri);
        startActivity(it);
    }
}