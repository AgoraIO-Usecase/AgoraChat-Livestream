package io.agora.livedemo.ui;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Pair;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import io.agora.ValueCallBack;
import io.agora.chat.ChatClient;
import io.agora.chat.UserInfo;
import io.agora.cloud.EMHttpClient;
import io.agora.exceptions.ChatException;
import io.agora.livedemo.common.callback.OnResourceParseCallback;
import io.agora.livedemo.common.utils.DemoHelper;
import io.agora.livedemo.common.utils.PreferenceManager;
import io.agora.livedemo.data.model.HeadImageInfo;
import io.agora.livedemo.data.model.User;
import io.agora.livedemo.data.repository.UserRepository;
import io.agora.livedemo.databinding.ActivitySplashBinding;
import io.agora.livedemo.ui.base.BaseLiveActivity;
import io.agora.livedemo.ui.other.viewmodels.LoginViewModel;
import io.agora.util.EMLog;


public class SplashActivity extends BaseLiveActivity {
    private final static String TAG = "lives";
    private LoginViewModel viewModel;
    private ActivitySplashBinding mBinding;
    private boolean mIsSyncUserInfo;
    private String mAvatarBaseUrl = "https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/IMDemo/avatar/";
    private List<HeadImageInfo> mHeadImageList;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        super.onCreate(savedInstanceState);
    }

    @Override
    protected View getContentView() {
        mBinding = ActivitySplashBinding.inflate(getLayoutInflater());
        return mBinding.getRoot();
    }

    @Override
    protected void initView() {
        super.initView();
    }

    @Override
    protected void initData() {
        super.initData();
        PreferenceManager.init(mContext);
        DemoHelper.init();
        UserRepository.getInstance().init(mContext);
        mIsSyncUserInfo = null == UserRepository.getInstance().getCurrentUser();

        mHeadImageList = new ArrayList<>();
        viewModel = new ViewModelProvider(this).get(LoginViewModel.class);

        mHandler.sendEmptyMessageDelayed(0, 1000 * 3);//3s


    }

    private final Handler mHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(@NonNull Message msg) {
            skipToTarget();
            return false;
        }
    });

    private void skipToTarget() {
        if (ChatClient.getInstance().isLoggedInBefore()) {
            startActivity(new Intent(this, MainActivity.class));
            finish();
        } else {
            //not need random user avatar url
//            String srcUrl = mAvatarBaseUrl + "headImage.conf";
//            getHeadImageSrc(srcUrl);
            login();
        }
    }

    private void getHeadImageSrc(String srcUrl) {
        new AsyncTask<String, Void, Pair<Integer, String>>() {
            @Override
            protected Pair<Integer, String> doInBackground(String... str) {
                try {
                    Pair<Integer, String> response = EMHttpClient.getInstance().sendRequestWithToken(srcUrl, null, EMHttpClient.GET);
                    return response;
                } catch (ChatException exception) {
                    exception.printStackTrace();
                }
                return null;
            }

            @Override
            protected void onPostExecute(Pair<Integer, String> response) {
                if (response != null) {
                    EMLog.e(TAG, response.toString());
                    try {
                        int resCode = response.first;
                        if (resCode == 200) {

                            String ImageStr = response.second.replace(" ", "");
                            JSONObject object = new JSONObject(ImageStr);
                            JSONObject headImageObject = object.optJSONObject("headImageList");
                            Iterator it = headImageObject.keys();
                            while (it.hasNext()) {
                                String key = it.next().toString();
                                String url = mAvatarBaseUrl + headImageObject.optString(key);
                                mHeadImageList.add(new HeadImageInfo(url, key));
                            }
                            UserRepository.getInstance().setHeadImageList(mHeadImageList);
                            runOnUiThread(new Runnable() {
                                public void run() {
                                    login();
                                }
                            });
                        } else {
                            EMLog.e(TAG, "get headImageInfo failed resCode:" + resCode);
                            login();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    EMLog.e(TAG, "get headImageInfo response is null");
                }
            }
        }.execute(srcUrl);
    }


    private void login() {
        ProgressDialog pd = new ProgressDialog(mContext);
        pd.setMessage("wait...");
        pd.setCanceledOnTouchOutside(false);

        viewModel.getLoginObservable().observe(mContext, response -> {
            parseResource(response, new OnResourceParseCallback<User>() {
                @Override
                public void onSuccess(User data) {
                    if (mIsSyncUserInfo) {
                        DemoHelper.saveCurrentUser();
                        ChatClient.getInstance().userInfoManager().updateOwnInfoByAttribute(UserInfo.UserInfoType.NICKNAME, data.getNickName(), new ValueCallBack<String>() {
                            @Override
                            public void onSuccess(String value) {
                                EMLog.i(TAG, "sync nick success");
                            }

                            @Override
                            public void onError(int i, String s) {

                            }
                        });

                        ChatClient.getInstance().userInfoManager().updateOwnInfoByAttribute(UserInfo.UserInfoType.AVATAR_URL, data.getAvatarUrl(), new ValueCallBack<String>() {
                            @Override
                            public void onSuccess(String value) {
                                EMLog.i(TAG, "sync avatar url success");
                            }

                            @Override
                            public void onError(int i, String s) {

                            }
                        });

                        ChatClient.getInstance().userInfoManager().updateOwnInfoByAttribute(UserInfo.UserInfoType.BIRTH, data.getBirthday(), new ValueCallBack<String>() {
                            @Override
                            public void onSuccess(String value) {
                                EMLog.i(TAG, "sync birthday success");
                            }

                            @Override
                            public void onError(int i, String s) {

                            }
                        });
                    }
                    skipToTarget();
                }

                @Override
                public void onLoading() {
                    super.onLoading();
                    pd.show();
                }

                @Override
                public void hideLoading() {
                    super.hideLoading();
                    pd.dismiss();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                }
            });
        });

        viewModel.login();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mHandler.removeCallbacksAndMessages(null);
    }
}
