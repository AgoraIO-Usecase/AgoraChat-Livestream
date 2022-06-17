package io.agora.livedemo.ui;

import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;

import io.agora.ValueCallBack;
import io.agora.chat.ChatClient;
import io.agora.chat.UserInfo;
import io.agora.chat.uikit.models.EaseUser;
import io.agora.livedemo.DemoConstants;
import io.agora.livedemo.R;
import io.agora.livedemo.common.callback.OnResourceParseCallback;
import io.agora.livedemo.common.livedata.LiveDataBus;
import io.agora.livedemo.common.repository.Resource;
import io.agora.livedemo.common.utils.DemoHelper;
import io.agora.livedemo.common.utils.PreferenceManager;
import io.agora.livedemo.data.model.User;
import io.agora.livedemo.data.repository.UserRepository;
import io.agora.livedemo.databinding.ActivitySplashBinding;
import io.agora.livedemo.ui.base.BaseLiveActivity;
import io.agora.livedemo.ui.live.viewmodels.UserInfoViewModel;
import io.agora.livedemo.ui.other.viewmodels.LoginViewModel;
import io.agora.util.EMLog;


public class SplashActivity extends BaseLiveActivity {
    private final static String TAG = "lives";
    private LoginViewModel viewModel;
    private ActivitySplashBinding mBinding;
    private boolean mIsSyncUserInfo;
    private UserInfoViewModel mViewModel;
    private ProgressDialog pd;

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
        mViewModel = new ViewModelProvider(this).get(UserInfoViewModel.class);
        pd = new ProgressDialog(mContext);
        PreferenceManager.init(mContext);
        DemoHelper.init();
        UserRepository.getInstance().init(mContext);
        mIsSyncUserInfo = null == UserRepository.getInstance().getCurrentUser();

        viewModel = new ViewModelProvider(this).get(LoginViewModel.class);

        skipToTarget();
    }

    private final Handler mHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(@NonNull Message msg) {
            if (pd.isShowing()) {
                pd.dismiss();
            }
            startActivity(new Intent(SplashActivity.this, MainActivity.class));
            finish();
            return false;
        }
    });

    private void skipToTarget() {
        if (ChatClient.getInstance().isLoggedInBefore()) {
            mHandler.sendEmptyMessageDelayed(0, 1000 * 3);//3s
        } else {
            login();
        }
    }


    private void login() {
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

                        ChatClient.getInstance().userInfoManager().updateOwnInfoByAttribute(UserInfo.UserInfoType.BIRTH, data.getBirthday(), new ValueCallBack<String>() {
                            @Override
                            public void onSuccess(String value) {
                                EMLog.i(TAG, "sync birthday success");
                            }

                            @Override
                            public void onError(int i, String s) {

                            }
                        });

                        ChatClient.getInstance().userInfoManager().updateOwnInfoByAttribute(UserInfo.UserInfoType.GENDER, data.getGender(), new ValueCallBack<String>() {
                            @Override
                            public void onSuccess(String value) {
                                EMLog.i(TAG, "sync gender success");
                            }

                            @Override
                            public void onError(int i, String s) {

                            }
                        });
                        updateUserAvatar();
                    } else {
                        skipToTarget();
                    }
                }

                @Override
                public void onLoading() {
                    super.onLoading();
                    pd.show();
                }

                @Override
                public void hideLoading() {
                    super.hideLoading();

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

    private void updateUserAvatar() {
        mViewModel.getUploadAvatarObservable().observe(mContext, new Observer<Resource<String>>() {
            @Override
            public void onChanged(Resource<String> stringResource) {
                SplashActivity.this.parseResource(stringResource, new OnResourceParseCallback<String>() {
                    @Override
                    public void onSuccess(String data) {
                        EaseUser user = UserRepository.getInstance().getUserInfo(DemoHelper.getAgoraId());
                        user.setAvatar(data);
                        UserRepository.getInstance().saveUserInfoToDb(user);
                        LiveDataBus.get().with(DemoConstants.AVATAR_CHANGE).postValue(true);
                        ChatClient.getInstance().userInfoManager().updateOwnInfoByAttribute(UserInfo.UserInfoType.AVATAR_URL, data, new ValueCallBack<String>() {
                            @Override
                            public void onSuccess(String value) {
                                EMLog.i(TAG, "sync avatar url success");
                                skipToTarget();
                            }

                            @Override
                            public void onError(int i, String s) {
                                EMLog.i("lives", "updateUserAvatar s=" + s);
                            }
                        });
                    }
                });
            }
        });

        BitmapDrawable d = (BitmapDrawable) this.getResources().getDrawable(R.drawable.ease_default_avatar);
        Bitmap img = d.getBitmap();

        String path = this.getFilesDir() + File.separator + "default_avatar.png";
        try {
            OutputStream os = new FileOutputStream(path);
            img.compress(Bitmap.CompressFormat.PNG, 100, os);
            os.close();
            mViewModel.uploadAvatar(path);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
