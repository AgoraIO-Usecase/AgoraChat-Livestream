package io.agora.livedemo;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Process;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.multidex.MultiDex;

import io.agora.ConnectionListener;
import io.agora.Error;
import io.agora.chat.ChatClient;
import io.agora.chat.ChatOptions;
import io.agora.chat.uikit.EaseUIKit;
import io.agora.live.FastLiveHelper;
import io.agora.livedemo.common.callback.UserActivityLifecycleCallbacks;
import io.agora.livedemo.common.livedata.LiveDataBus;
import io.agora.livedemo.ui.MainActivity;
import io.agora.util.EMLog;


public class DemoApplication extends Application implements Thread.UncaughtExceptionHandler {
    private static final String TAG = DemoApplication.class.getSimpleName();
    private static DemoApplication instance;
    private final UserActivityLifecycleCallbacks mLifecycleCallbacks = new UserActivityLifecycleCallbacks();
    public boolean isSDKInit;

    static {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            AppCompatDelegate.setCompatVectorFromResourcesEnabled(true);
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        registerActivityLifecycleCallbacks();
        registerUncaughtExceptionHandler();
        initChatSdk(this.getApplicationContext());
        initAgora();
    }

    private void initAgora() {
        FastLiveHelper.getInstance().init(this, BuildConfig.AGORA_APP_ID);
        FastLiveHelper.getInstance().getEngineConfig().setLowLatency(false);
    }

    private void registerUncaughtExceptionHandler() {
        Thread.setDefaultUncaughtExceptionHandler(this);
    }

    public static DemoApplication getInstance() {
        return instance;
    }

    private void initChatSdk(Context context) {
        if (initSDK(context)) {
            ChatClient.getInstance().setDebugMode(BuildConfig.DEBUG);

            ChatClient.getInstance().addConnectionListener(new ConnectionListener() {
                @Override
                public void onConnected() {
                    LiveDataBus.get().with(DemoConstants.NETWORK_CONNECTED).postValue(true);
                }

                @Override
                public void onDisconnected(int errorCode) {
                    if (errorCode == Error.USER_LOGIN_ANOTHER_DEVICE) {
                        Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        intent.putExtra("conflict", true);
                        startActivity(intent);
                    }
                }
            });
        }else {
            Toast.makeText(this, "Please set your App key", Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * Initialize Agora Chat SDK
     *
     * @param context
     * @return
     */
    private boolean initSDK(Context context) {
        // Set Chat Options
        Log.d(TAG, "init Agora Chat Options");
        ChatOptions options = new ChatOptions();

        // Configure custom rest server and im server
        //options.setRestServer(BuildConfig.APP_SERVER_DOMAIN);
        //options.setIMServer("106.75.100.247");
        //options.setImPort(6717);
        //options.setUsingHttpsOnly(false);
        // You can set your AppKey by options.setAppKey(appkey)
        if (!checkAgoraChatAppKey(context) && TextUtils.isEmpty(options.getAppKey())) {
            EMLog.e(TAG, "no agora chat app key and return");
            return false;
        }
        options.setAutoLogin(true);
        isSDKInit = EaseUIKit.getInstance().init(context, options);
        return isSDKInit();
    }

    private boolean checkAgoraChatAppKey(Context context) {
        String appPackageName = context.getPackageName();
        ApplicationInfo ai = null;
        try {
            ai = context.getPackageManager().getApplicationInfo(appPackageName, PackageManager.GET_META_DATA);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return false;
        }
        if (ai != null) {
            Bundle metaData = ai.metaData;
            if (metaData == null) {
                return false;
            }
            // read appkey
            String appKeyFromConfig = metaData.getString("EASEMOB_APPKEY");
            return !TextUtils.isEmpty(appKeyFromConfig) && appKeyFromConfig.contains("#");
        }
        return false;
    }

    public boolean isSDKInit() {
        return ChatClient.getInstance().isSdkInited();
    }

    private void registerActivityLifecycleCallbacks() {
        this.registerActivityLifecycleCallbacks(mLifecycleCallbacks);
    }

    public UserActivityLifecycleCallbacks getActivityLifecycle() {
        return mLifecycleCallbacks;
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }

    @Override
    public void uncaughtException(@NonNull Thread t, @NonNull Throwable e) {
        e.printStackTrace();
        System.exit(1);
        Process.killProcess(Process.myPid());
    }
}
