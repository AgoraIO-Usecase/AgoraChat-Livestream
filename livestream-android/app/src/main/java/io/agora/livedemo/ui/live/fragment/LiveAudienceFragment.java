package io.agora.livedemo.ui.live.fragment;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.bumptech.glide.Glide;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Random;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.Unbinder;
import io.agora.Error;
import io.agora.ValueCallBack;
import io.agora.chat.ChatClient;
import io.agora.chat.ChatMessage;
import io.agora.chat.ChatRoom;
import io.agora.chat.UserInfo;
import io.agora.chat.uikit.lives.EaseLiveMessageHelper;
import io.agora.chat.uikit.lives.OnSendLiveMessageCallBack;
import io.agora.livedemo.DemoConstants;
import io.agora.livedemo.R;
import io.agora.livedemo.common.callback.OnResourceParseCallback;
import io.agora.livedemo.common.inf.OnConfirmClickListener;
import io.agora.livedemo.common.inf.OnUpdateUserInfoListener;
import io.agora.livedemo.common.livedata.LiveDataBus;
import io.agora.livedemo.common.utils.DemoHelper;
import io.agora.livedemo.common.utils.ThreadManager;
import io.agora.livedemo.data.model.GiftBean;
import io.agora.livedemo.data.model.LiveRoom;
import io.agora.livedemo.data.repository.UserRepository;
import io.agora.livedemo.utils.Utils;
import io.agora.util.EMLog;

public class LiveAudienceFragment extends LiveBaseFragment {
    @BindView(R.id.loading_layout)
    RelativeLayout loadingLayout;
    @BindView(R.id.cover_image)
    ImageView coverView;
    @BindView(R.id.group_ui)
    ConstraintLayout groupUi;
    @BindView(R.id.live_stream_end_tip)
    TextView liveStreamEndTip;

    private Unbinder unbinder;
    private OnLiveListener liveListener;
    int praiseCount;
    final int praiseSendDelay = 4 * 1000;
    private Thread sendPraiseThread;
    /**
     * Whether it is an operation of switching the owner, if it is an operation of switching the owner, the logic of exiting the chat room will not be called. Prevent the new page from joining the live broadcast room, and the page being destroyed calls the operation of exiting the live broadcast room, resulting in an exception in the chat room.
     */
    private boolean isSwitchOwner;
    private boolean isAdmin;
    private boolean isInWhiteList;
    private boolean isInMuteList;
    private boolean isAllMute;

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_live_audience;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        unbinder = ButterKnife.bind(this, view);
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        switchCameraView.setVisibility(View.GONE);
        closeIv.setVisibility(View.VISIBLE);
        liveReceiveGift.setVisibility(View.VISIBLE);
        Glide.with(mContext).load(liveRoom.getCover()).placeholder(R.color.placeholder).into(coverView);
    }

    @Override
    protected void initLiveStreamerUser() {
        List<String> memberList = new ArrayList<>(1);
        memberList.add(anchorId);
        UserRepository.getInstance().fetchUserInfo(memberList, new OnUpdateUserInfoListener() {
            @Override
            public void onSuccess(Map<String, UserInfo> userInfoMap) {
                LiveAudienceFragment.this.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mLiveStreamerUser = UserRepository.getInstance().getUserInfo(anchorId);
                        initLiveStreamView();
                    }
                });
            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    @Override
    protected void initListener() {
        super.initListener();
        tvAttention.setOnClickListener(this);
        closeIv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                leaveRoom();
            }
        });
    }

    @Override
    protected void initData() {
        super.initData();
        LiveDataBus.get().with(DemoConstants.EVENT_ANCHOR_FINISH_LIVE, Boolean.class)
                .observe(getViewLifecycleOwner(), response -> {
                    if (liveRoom != null
                            && !TextUtils.isEmpty(liveRoom.getVideo_type())
                            && !DemoHelper.isVod(liveRoom.getVideo_type())) {
                        liveStreamEndTip.setTypeface(Utils.getRobotoRegularTypeface(mContext));
                        liveStreamEndTip.setVisibility(View.VISIBLE);

                        liveReceiveGift.setEnabled(false);
                        liveReceiveGift.setImageResource(R.drawable.live_gift_disable);
                        commentIv.setEnabled(false);
                    }
                });

        getLiveRoomDetail();
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()) {
            case R.id.tv_attention:

                break;
        }
    }

    @OnClick(R.id.img_bt_close)
    void close() {
        mContext.finish();
    }

    @OnClick(R.id.like_image)
    void Praise() {
        periscopeLayout.addHeart();
        synchronized (this) {
            ++praiseCount;
        }
        if (sendPraiseThread == null) {
            sendPraiseThread = new Thread(new Runnable() {
                @Override
                public void run() {
                    while (mContext != null && !mContext.isFinishing()) {
                        int count = 0;
                        synchronized (LiveAudienceFragment.this) {
                            count = praiseCount;
                            praiseCount = 0;
                        }
                        if (count > 0) {
                            presenter.sendPraiseMessage(count);
                        }
                        try {
                            Thread.sleep(praiseSendDelay + new Random().nextInt(2000));
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                            return;
                        }
                    }
                }
            });
            sendPraiseThread.setDaemon(true);
            sendPraiseThread.start();
        }
    }

    @Override
    protected void skipToUserListDialog() {
        super.skipToUserListDialog();
        if (chatroom.getAdminList().contains(ChatClient.getInstance().getCurrentUser())) {
            try {
                showUserList();
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            LiveMemberListDialog dialog = (LiveMemberListDialog) getChildFragmentManager().findFragmentByTag("liveMember");
            if (dialog == null) {
                dialog = LiveMemberListDialog.getNewInstance(chatroomId);
            }
            if (dialog.isAdded()) {
                return;
            }
            dialog.show(getChildFragmentManager(), "liveMember");
        }
    }

    @Override
    protected void anchorClick() {
        super.anchorClick();
        //showUserDetailsDialog(chatroom.getOwner());
    }

    @Override
    protected void onGiftClick() {
        super.onGiftClick();
        showGiftDialog();
    }

    @Override
    protected void showPraise(int count) {
        //The audience does not show animations
    }

    @Override
    public void onChatRoomOwnerChanged(String chatRoomId, String newOwner, String oldOwner) {
        super.onChatRoomOwnerChanged(chatRoomId, newOwner, oldOwner);
        if (TextUtils.equals(liveRoom.getId(), chatRoomId) && TextUtils.equals(newOwner, ChatClient.getInstance().getCurrentUser())) {
            isSwitchOwner = true;
            if (liveListener != null) {
                liveListener.onRoomOwnerChangedToCurrentUser(chatRoomId, newOwner);
            }
        }
    }

    @Override
    public void onAdminAdded(String chatRoomId, String admin) {
        if (!isAdmin && admin.equals(ChatClient.getInstance().getCurrentUser())) {
            showAttention(10, mContext.getString(R.string.live_in_admin_list), false);
        }
        ChatClient.getInstance().chatroomManager().asyncFetchChatRoomFromServer(chatRoomId, new ValueCallBack<ChatRoom>() {
            @Override
            public void onSuccess(ChatRoom chatRoom) {
                LiveAudienceFragment.this.chatroom = chatRoom;
                ThreadManager.getInstance().runOnMainThread(new Runnable() {
                    @Override
                    public void run() {
                        if (null != messageView) {
                            messageView.updateChatRoomInfo();
                        }
                        updateUserState();
                    }
                });
            }

            @Override
            public void onError(int i, String s) {

            }
        });
    }

    @Override
    public void onAdminRemoved(String chatRoomId, String admin) {
        if (isAdmin && admin.equals(ChatClient.getInstance().getCurrentUser())) {
            showAttention(10, mContext.getString(R.string.live_out_admin_list), false);
        }

        ChatClient.getInstance().chatroomManager().asyncFetchChatRoomFromServer(chatRoomId, new ValueCallBack<ChatRoom>() {
            @Override
            public void onSuccess(ChatRoom chatRoom) {
                LiveAudienceFragment.this.chatroom = chatRoom;
                ThreadManager.getInstance().runOnMainThread(new Runnable() {
                    @Override
                    public void run() {
                        if (null != messageView) {
                            messageView.updateChatRoomInfo();
                        }
                        updateUserState();
                    }
                });
            }

            @Override
            public void onError(int i, String s) {

            }
        });
    }

    @Override
    public void onAllMemberMuteStateChanged(String chatRoomId, boolean isMuted) {
        isAllMute = isMuted;
        if (isMuted) {
            showAttention(-1, mContext.getString(R.string.live_anchor_timeout_all_attention_tip), true);
            if (!isInWhiteList) {
                addMute(true);
            }
        } else {
            showAttention(10, mContext.getString(R.string.live_anchor_remove_timeout_all_attention_tip), false);
            removeMute();
        }

    }

    @Override
    public void onMuteListAdded(String chatRoomId, List<String> mutes, long expireTime) {
        if (!isAllMute) {
            if (!isInMuteList && mutes.contains(ChatClient.getInstance().getCurrentUser())) {
                showAttention(10, mContext.getString(R.string.live_in_timed_out_list), true);
                addMute(false);
            }
        }
        updateChatRoomForUserState();
    }

    @Override
    public void onMuteListRemoved(String chatRoomId, List<String> mutes) {
        if (isInMuteList && mutes.contains(ChatClient.getInstance().getCurrentUser())) {
            showAttention(10, mContext.getString(R.string.live_remove_timed_out_list), false);
            removeMute();
        }
        updateChatRoomForUserState();
    }

    private void addMute(boolean isAllMute) {
        ThreadManager.getInstance().runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (null != messageView) {
                    messageView.enableInputView(false);
                    if (isAllMute) {
                        showMessageInputTextHint(R.string.message_list_input_tip_all_timeout, true);
                    } else {
                        showMessageInputTextHint(R.string.message_list_input_tip_timeout, false);
                    }
                }
            }
        });
    }

    private void removeMute() {
        ThreadManager.getInstance().runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (null != messageView) {
                    messageView.enableInputView(true);
                    showMessageInputTextHint(R.string.message_list_input_tip_audience, false);
                }
            }
        });
    }

    private void updateChatRoomForUserState() {
        ChatClient.getInstance().chatroomManager().asyncFetchChatRoomFromServer(chatroomId, new ValueCallBack<ChatRoom>() {
            @Override
            public void onSuccess(ChatRoom chatRoom) {
                LiveAudienceFragment.this.chatroom = chatRoom;
                ThreadManager.getInstance().runOnMainThread(new Runnable() {
                    @Override
                    public void run() {
                        updateUserState();
                    }
                });
            }

            @Override
            public void onError(int i, String s) {

            }
        });
    }

    @Override
    public void onWhiteListAdded(String chatRoomId, List<String> whitelist) {
        if (!isInWhiteList && whitelist.contains(ChatClient.getInstance().getCurrentUser())) {
            showAttention(10, mContext.getString(R.string.live_in_white_list), false);
            if (isAllMute) {
                messageView.enableInputView(true);
                ThreadManager.getInstance().runOnMainThread(new Runnable() {
                    @Override
                    public void run() {
                        showMessageInputTextHint(R.string.message_list_input_tip_audience, false);
                    }
                });
            }
        }
        chatroom = ChatClient.getInstance().chatroomManager().getChatRoom(chatRoomId);
        updateUserState();
    }

    @Override
    public void onWhiteListRemoved(String chatRoomId, List<String> whitelist) {
        if (isInWhiteList && whitelist.contains(ChatClient.getInstance().getCurrentUser())) {
            showAttention(10, mContext.getString(R.string.live_out_white_list), false);
        }

        ChatClient.getInstance().chatroomManager().asyncFetchChatRoomFromServer(chatRoomId, new ValueCallBack<ChatRoom>() {
            @Override
            public void onSuccess(ChatRoom chatRoom) {
                LiveAudienceFragment.this.chatroom = chatRoom;
                ThreadManager.getInstance().runOnMainThread(new Runnable() {
                    @Override
                    public void run() {
                        updateUserState();
                    }
                });
            }

            @Override
            public void onError(int i, String s) {

            }
        });
    }

    private void showGiftDialog() {
        LiveGiftDialog dialog = (LiveGiftDialog) getChildFragmentManager().findFragmentByTag("live_gift");
        if (dialog == null) {
            dialog = LiveGiftDialog.getNewInstance();
        }
        if (dialog.isAdded()) {
            return;
        }
        dialog.show(getChildFragmentManager(), "live_gift");
        dialog.setOnConfirmClickListener(new OnConfirmClickListener() {
            @Override
            public void onConfirmClick(View view, Object bean) {
                if (bean instanceof GiftBean) {
                    presenter.sendGiftMsg((GiftBean) bean, new OnSendLiveMessageCallBack() {

                        @Override
                        public void onSuccess(ChatMessage message) {
                            ThreadManager.getInstance().runOnMainThread(() -> {
                                barrageLayout.showGift((GiftBean) bean);
                            });
                        }

                        @Override
                        public void onError(int code, String error) {
                            mContext.showToast("send gift error:" + error);
                        }
                    });

                }
            }
        });
    }

    private void getLiveRoomDetail() {
        viewModel.getRoomDetailObservable().observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<LiveRoom>() {
                @Override
                public void onSuccess(LiveRoom data) {
                    //If the current user is the host, enter the host room
                    if (DemoHelper.isOwner(data.getOwner())) {
                        isSwitchOwner = true;
                        if (liveListener != null) {
                            liveListener.onRoomOwnerChangedToCurrentUser(data.getChatroomId(), data.getOwner());
                        }
                        return;
                    }
                    LiveAudienceFragment.this.liveRoom = data;
                    if (DemoHelper.isLiving(data.getStatus())) {
                        if (liveListener != null) {
                            liveListener.onLiveOngoing(data);
                        }
                        messageView.getInputView().requestFocus();
                        messageView.getInputView().requestFocusFromTouch();
                        joinChatRoom();

                    } else {
                        mContext.showLongToast("Live stream End");
                        if (liveListener != null) {
                            liveListener.onLiveClosed();
                        }
                    }
                }

                @Override
                public void hideLoading() {
                    super.hideLoading();
                    loadingLayout.setVisibility(View.INVISIBLE);
                }
            });
        });
        viewModel.getLiveRoomDetails(liveRoom.getId());
    }

    private void joinChatRoom() {
        ChatClient.getInstance()
                .chatroomManager()
                .joinChatRoom(chatroomId, new ValueCallBack<ChatRoom>() {
                    @Override
                    public void onSuccess(ChatRoom emChatRoom) {
                        EMLog.d(TAG, "audience join chat room success");
                        ChatClient.getInstance().chatroomManager().asyncFetchChatRoomFromServer(chatroomId, new ValueCallBack<ChatRoom>() {
                            @Override
                            public void onSuccess(ChatRoom chatRoom) {
                                LiveAudienceFragment.this.chatroom = chatRoom;
                                ThreadManager.getInstance().runOnMainThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        addChatRoomChangeListener();
                                        updateUserState();
                                        onMessageListInit();
                                        onWatchedMemberListInit();
                                        startCycleRefresh();
                                    }
                                });
                            }

                            @Override
                            public void onError(int i, String s) {

                            }
                        });

                    }

                    @Override
                    public void onError(int i, String s) {
                        EMLog.d(TAG, "audience join chat room fail message: " + s);
                        if (i == Error.GROUP_PERMISSION_DENIED || i == Error.CHATROOM_PERMISSION_DENIED) {
                            mContext.showLongToast("You do not have permission to join this room");
                            mContext.finish();
                        } else if (i == Error.CHATROOM_MEMBERS_FULL) {
                            mContext.showLongToast("Room is full");
                            mContext.finish();
                        } else {
                            mContext.showLongToast("Failed to join chat room: " + s);
                        }
                    }
                });
    }

    @Override
    public void onResume() {
        super.onResume();
        // register the event listener when enter the foreground
        EaseLiveMessageHelper.getInstance().init(chatroomId);
        EaseLiveMessageHelper.getInstance().addLiveMessageListener(this);
    }

    private void updateUserState() {
        String currentUser = ChatClient.getInstance().getCurrentUser();
        isAdmin = chatroom.getAdminList().contains(currentUser);
        isInWhiteList = chatroom.getWhitelist().contains(currentUser);
        isInMuteList = chatroom.getMuteList().containsKey(currentUser);
        isAllMute = chatroom.isAllMemberMuted();
    }

    private void initUserMuteState() {
        if (isAllMute) {
            showAttention(-1, mContext.getString(R.string.live_anchor_timeout_all_attention_tip), true);
            if (!isInWhiteList) {
                addMute(true);
            }
        } else if (isInMuteList) {
            showAttention(10, mContext.getString(R.string.live_in_timed_out_list), true);
            addMute(false);
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        // unregister this event listener when this activity enters the
        EaseLiveMessageHelper.getInstance().removeLiveMessageListener(this);
        // background
        if (mContext.isFinishing()) {
            LiveDataBus.get().with(DemoConstants.FRESH_LIVE_LIST).setValue(true);
            if (!isSwitchOwner) {
                leaveRoom();
                //postUserChangeEvent(StatisticsType.LEAVE, ChatClient.getInstance().getCurrentUser());
            }
        }
    }

    @Override
    protected void onMessageListInit() {
        ThreadManager.getInstance().runOnMainThread(new Runnable() {
            @Override
            public void run() {
                LiveAudienceFragment.super.onMessageListInit();
                showMessageInputTextHint(R.string.message_list_input_tip_audience, false);
                initUserMuteState();
            }
        });
    }

    private void leaveRoom() {
        Utils.hideKeyboard(messageView);
        ChatClient.getInstance().chatroomManager().leaveChatRoom(chatroomId);
        EMLog.d(TAG, "audience leave chat room");
        mContext.finish();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        unbinder.unbind();
    }

    public void setOnLiveListener(OnLiveListener liveListener) {
        this.liveListener = liveListener;
    }


    public interface OnLiveListener {
        void onLiveOngoing(LiveRoom data);

        void onLiveClosed();

        void onRoomOwnerChangedToCurrentUser(String chatRoomId, String newOwner);
    }
}
