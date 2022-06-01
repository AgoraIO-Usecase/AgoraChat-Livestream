package io.agora.livedemo.ui.live.fragment;

import android.app.AlertDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.text.InputType;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.lifecycle.ViewModelProvider;

import com.jakewharton.rxbinding4.view.RxView;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.agora.chat.ChatClient;
import io.agora.chat.ChatRoom;
import io.agora.chat.ChatRoomManager;
import io.agora.chat.uikit.models.EaseUser;
import io.agora.chat.uikit.utils.EaseUserUtils;
import io.agora.chat.uikit.widget.EaseImageView;
import io.agora.livedemo.DemoConstants;
import io.agora.livedemo.R;
import io.agora.livedemo.common.callback.OnResourceParseCallback;
import io.agora.livedemo.common.inf.OnConfirmClickListener;
import io.agora.livedemo.common.livedata.LiveDataBus;
import io.agora.livedemo.data.model.AttentionBean;
import io.agora.livedemo.data.repository.UserRepository;
import io.agora.livedemo.ui.base.BaseLiveDialogFragment;
import io.agora.livedemo.ui.live.viewmodels.LivingViewModel;
import io.agora.livedemo.ui.live.viewmodels.UserManageViewModel;
import io.agora.livedemo.ui.other.fragment.SimpleDialogFragment;
import io.agora.livedemo.ui.widget.ArrowItemView;
import io.agora.livedemo.ui.widget.SwitchItemView;
import io.agora.livedemo.utils.Utils;
import io.reactivex.rxjava3.functions.Consumer;
import kotlin.Unit;

public class RoomUserDetailDialog extends BaseLiveDialogFragment implements SwitchItemView.OnCheckedChangeListener {
    private EaseImageView userIcon;
    private TextView userNameTv;
    private ConstraintLayout sexLayout;
    private ImageView sexIcon;
    private TextView ageTv;
    private ImageView roleType;
    private SwitchItemView banAll;
    private EaseImageView muteState;
    private ArrowItemView removeFromAllowedListItem;
    private ArrowItemView moveToAllowedListItem;
    private ArrowItemView removeAsModeratorItem;
    private ArrowItemView assignAsModeratorItem;
    private ArrowItemView timeoutItem;
    private ArrowItemView muteItem;
    private ArrowItemView unmuteItem;
    private ArrowItemView banItem;
    private ArrowItemView unbanItem;


    private UserManageViewModel viewModel;
    protected LivingViewModel livingViewModel;
    private String username;
    private String roomId;
    protected ChatRoomManager mChatRoomManager;
    protected ChatRoom mChatRoom;

    public static RoomUserDetailDialog getNewInstance(String chatroomId, String username) {
        RoomUserDetailDialog dialog = new RoomUserDetailDialog();
        Bundle bundle = new Bundle();
        bundle.putString("username", username);
        bundle.putString("chatroomid", chatroomId);
        dialog.setArguments(bundle);
        return dialog;
    }

    @Override
    public int getLayoutId() {
        return R.layout.fragment_dialog_live_manage_user;
    }

    @Override
    public void initArgument() {
        super.initArgument();
        Bundle bundle = getArguments();
        if (bundle != null) {
            username = bundle.getString("username");
            roomId = bundle.getString("chatroomid");
        }
    }

    @Override
    public void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);

        userIcon = findViewById(R.id.user_icon);
        userNameTv = findViewById(R.id.tv_username);
        sexLayout = findViewById(R.id.layout_sex);
        sexIcon = findViewById(R.id.sex_icon);
        ageTv = findViewById(R.id.age_tv);
        roleType = findViewById(R.id.role_type);
        banAll = findViewById(R.id.ban_all);
        muteState = findViewById(R.id.mute_state);
        removeFromAllowedListItem = findViewById(R.id.item_remove_from_allowed_list);
        moveToAllowedListItem = findViewById(R.id.item_move_to_allowed_list);
        removeAsModeratorItem = findViewById(R.id.item_remove_as_moderator);
        assignAsModeratorItem = findViewById(R.id.item_assign_as_moderator);
        timeoutItem = findViewById(R.id.item_timeout);
        muteItem = findViewById(R.id.item_mute);
        unmuteItem = findViewById(R.id.item_unmute);
        banItem = findViewById(R.id.item_ban);
        unbanItem = findViewById(R.id.item_unban);

        EaseUser user = UserRepository.getInstance().getUserInfo(username);

        EaseUserUtils.setUserNick(username, userNameTv);
        EaseUserUtils.setUserAvatar(mContext, username, userIcon);
        int gender = user.getGender();
        if (1 == gender) {
            sexLayout.setBackgroundResource(R.drawable.sex_male_bg_shape);
            sexIcon.setImageResource(R.drawable.sex_male_icon);
        } else if (2 == gender) {
            sexLayout.setBackgroundResource(R.drawable.sex_female_bg_shape);
            sexIcon.setImageResource(R.drawable.sex_female_icon);
        } else if (3 == gender) {
            sexLayout.setBackgroundResource(R.drawable.sex_other_bg_shape);
            sexIcon.setImageResource(R.drawable.sex_other_icon);
        } else {
            sexLayout.setBackgroundResource(R.drawable.sex_secret_bg_shape);
            sexIcon.setImageResource(R.drawable.sex_secret_icon);
        }
        String birth = user.getBirth();
        if (!TextUtils.isEmpty(birth)) {
            ageTv.setText(String.valueOf(Utils.getAgeByBirthday(user.getBirth())));
        }
    }


    private void updateView(boolean initView) {
        if (null == mChatRoom) {
            return;
        }
        if (username.equals(mChatRoom.getOwner())) {
            roleType.setVisibility(View.VISIBLE);
            roleType.setImageResource(R.drawable.live_streamer);
        } else if (mChatRoom.getAdminList().contains(username)) {
            roleType.setVisibility(View.VISIBLE);
            roleType.setImageResource(R.drawable.live_moderator);
        } else {
            roleType.setVisibility(View.INVISIBLE);
        }

        if (!mChatRoom.getMemberList().contains(username) && !mChatRoom.getAdminList().contains(username) && !username.equals(mChatRoom.getOwner()) && !mChatRoom.getBlacklist().contains(username)) {
            return;
        }

        if (mChatRoom.getMuteList().containsKey(username)) {
            muteState.setVisibility(View.VISIBLE);
        } else {
            muteState.setVisibility(View.GONE);
        }

        if (mChatRoom.getOwner().equals(ChatClient.getInstance().getCurrentUser())) {
            if (mChatRoom.getOwner().equals(username)) {
                banAll.getSwitch().setEnabled(mChatRoom.getMemberList().size() != 0 || mChatRoom.getAdminList().size() != 0);
                banAll.setVisibility(View.VISIBLE);
                if (initView) {
                    banAll.setOnCheckedChangeListener(null);
                    banAll.getSwitch().setChecked(mChatRoom.isAllMemberMuted());
                    banAll.setOnCheckedChangeListener(this);
                }
            } else {
                if (mChatRoom.getWhitelist().contains(username)) {
                    removeFromAllowedListItem.setVisibility(View.VISIBLE);
                    moveToAllowedListItem.setVisibility(View.GONE);
                } else {
                    removeFromAllowedListItem.setVisibility(View.GONE);
                    moveToAllowedListItem.setVisibility(View.VISIBLE);
                }

                if (mChatRoom.getMuteList().containsKey(username)) {
                    unmuteItem.setVisibility(View.VISIBLE);
                    timeoutItem.setVisibility(View.GONE);
                    muteItem.setVisibility(View.GONE);
                } else {
                    unmuteItem.setVisibility(View.GONE);
                    timeoutItem.setVisibility(View.VISIBLE);
                    muteItem.setVisibility(View.VISIBLE);
                }

                if (mChatRoom.getBlacklist().contains(username)) {
                    moveToAllowedListItem.setVisibility(View.GONE);
                    removeFromAllowedListItem.setVisibility(View.GONE);
                    assignAsModeratorItem.setVisibility(View.GONE);
                    removeAsModeratorItem.setVisibility(View.GONE);
                    timeoutItem.setVisibility(View.GONE);
                    muteItem.setVisibility(View.GONE);
                    unmuteItem.setVisibility(View.GONE);
                    banItem.setVisibility(View.GONE);
                    unbanItem.setVisibility(View.VISIBLE);
                } else {
                    banItem.setVisibility(View.VISIBLE);
                    unbanItem.setVisibility(View.GONE);
                }

                if (mChatRoom.getAdminList().contains(username)) {
                    removeAsModeratorItem.setVisibility(View.VISIBLE);
                    assignAsModeratorItem.setVisibility(View.GONE);
                    if (mChatRoom.getMuteList().containsKey(username)) {
                        timeoutItem.setVisibility(View.GONE);
                        removeFromAllowedListItem.setVisibility(View.GONE);
                        moveToAllowedListItem.setVisibility(View.GONE);
                    } else {
                        if (mChatRoom.getWhitelist().contains(username)) {
                            timeoutItem.setVisibility(View.GONE);
                            muteItem.setVisibility(View.GONE);
                            unmuteItem.setVisibility(View.GONE);
                            banItem.setVisibility(View.GONE);
                            unbanItem.setVisibility(View.GONE);
                        }
                    }
                } else {
                    removeAsModeratorItem.setVisibility(View.GONE);
                    assignAsModeratorItem.setVisibility(View.VISIBLE);
                }
                if (mChatRoom.getWhitelist().contains(username)) {
                    timeoutItem.setVisibility(View.GONE);
                    muteItem.setVisibility(View.GONE);
                    unmuteItem.setVisibility(View.GONE);
                    banItem.setVisibility(View.GONE);
                    unbanItem.setVisibility(View.GONE);
                }
            }
        } else if (mChatRoom.getAdminList().contains(ChatClient.getInstance().getCurrentUser())) {
            banAll.setVisibility(View.GONE);
            if (mChatRoom.getOwner().equals(username) || ChatClient.getInstance().getCurrentUser().equals(username)) {
                moveToAllowedListItem.setVisibility(View.GONE);
                removeFromAllowedListItem.setVisibility(View.GONE);
                assignAsModeratorItem.setVisibility(View.GONE);
                removeAsModeratorItem.setVisibility(View.GONE);
                timeoutItem.setVisibility(View.GONE);
                muteItem.setVisibility(View.GONE);
                unmuteItem.setVisibility(View.GONE);
                banItem.setVisibility(View.GONE);
                unbanItem.setVisibility(View.GONE);
            } else {
                if (mChatRoom.getWhitelist().contains(username)) {
                    removeFromAllowedListItem.setVisibility(View.VISIBLE);
                    moveToAllowedListItem.setVisibility(View.GONE);
                } else {
                    removeFromAllowedListItem.setVisibility(View.GONE);
                    moveToAllowedListItem.setVisibility(View.VISIBLE);
                }

                if (mChatRoom.getMuteList().containsKey(username)) {
                    unmuteItem.setVisibility(View.VISIBLE);
                    timeoutItem.setVisibility(View.GONE);
                    muteItem.setVisibility(View.GONE);
                } else {
                    unmuteItem.setVisibility(View.GONE);
                    timeoutItem.setVisibility(View.VISIBLE);
                    muteItem.setVisibility(View.VISIBLE);
                }

                if (mChatRoom.getAdminList().contains(username)) {
                    removeAsModeratorItem.setVisibility(View.GONE);
                    assignAsModeratorItem.setVisibility(View.GONE);
                    if (mChatRoom.getMuteList().containsKey(username)) {
                        timeoutItem.setVisibility(View.GONE);
                        removeFromAllowedListItem.setVisibility(View.GONE);
                        moveToAllowedListItem.setVisibility(View.GONE);
                    } else {
                        if (mChatRoom.getWhitelist().contains(username)) {
                            timeoutItem.setVisibility(View.GONE);
                            muteItem.setVisibility(View.GONE);
                            unmuteItem.setVisibility(View.GONE);
                            banItem.setVisibility(View.GONE);
                            unbanItem.setVisibility(View.GONE);
                        }
                    }
                } else {
                    removeAsModeratorItem.setVisibility(View.GONE);
                    assignAsModeratorItem.setVisibility(View.VISIBLE);
                }
                if (mChatRoom.getWhitelist().contains(username)) {
                    timeoutItem.setVisibility(View.GONE);
                    muteItem.setVisibility(View.GONE);
                    unmuteItem.setVisibility(View.GONE);
                    banItem.setVisibility(View.GONE);
                    unbanItem.setVisibility(View.GONE);
                }
            }
        } else {
            banAll.setVisibility(View.GONE);
            moveToAllowedListItem.setVisibility(View.GONE);
            removeFromAllowedListItem.setVisibility(View.GONE);
            assignAsModeratorItem.setVisibility(View.GONE);
            removeAsModeratorItem.setVisibility(View.GONE);
            timeoutItem.setVisibility(View.GONE);
            muteItem.setVisibility(View.GONE);
            unmuteItem.setVisibility(View.GONE);
            banItem.setVisibility(View.GONE);
            unbanItem.setVisibility(View.GONE);
        }
    }

    @Override
    public void initViewModel() {
        super.initViewModel();
        viewModel = new ViewModelProvider(this).get(UserManageViewModel.class);
        livingViewModel = new ViewModelProvider(mContext).get(LivingViewModel.class);

        viewModel.getChatRoomObservable().observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<ChatRoom>() {
                @Override
                public void onSuccess(ChatRoom data) {
                    if (null != RoomUserDetailDialog.this.getActivity()) {
                        RoomUserDetailDialog.this.getActivity().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mChatRoom = data;
                                updateView(false);
                            }
                        });
                    }
                }
            });
        });

        LiveDataBus.get().with(DemoConstants.REFRESH_MEMBER, Boolean.class).observe(getViewLifecycleOwner(), event -> {
            if (event != null && event) {
                updateChatRoom(false);
            }
        });

        LiveDataBus.get().with(DemoConstants.REFRESH_MEMBER_STATE, Boolean.class).observe(getViewLifecycleOwner(), event -> {
            if (event != null && event) {
                updateChatRoom(false);
            }
        });
    }


    @Override
    public void initListener() {
        super.initListener();
        List<String> list = new ArrayList<>(1);
        list.add(username);

        RxView.clicks(moveToAllowedListItem).throttleFirst(3, TimeUnit.SECONDS)
                .subscribe(new Consumer<Unit>() {
                    @Override
                    public void accept(Unit unit) throws Throwable {
                        showToast("move to allowed list");
                        viewModel.addToChatRoomWhiteList(roomId, list);
                    }
                });

        RxView.clicks(removeFromAllowedListItem).throttleFirst(3, TimeUnit.SECONDS)
                .subscribe(new Consumer<Unit>() {
                    @Override
                    public void accept(Unit unit) throws Throwable {
                        showToast("remove from allowed list");
                        viewModel.removeFromChatRoomWhiteList(roomId, list);
                    }
                });


        RxView.clicks(assignAsModeratorItem).throttleFirst(3, TimeUnit.SECONDS)
                .subscribe(new Consumer<Unit>() {
                    @Override
                    public void accept(Unit unit) throws Throwable {
                        showToast("assign as moderator");
                        viewModel.addChatRoomAdmin(roomId, username);
                        viewModel.fetchChatRoom(roomId);
                    }
                });

        RxView.clicks(removeAsModeratorItem).throttleFirst(3, TimeUnit.SECONDS)
                .subscribe(new Consumer<Unit>() {
                    @Override
                    public void accept(Unit unit) throws Throwable {
                        showToast("remove as moderator");
                        viewModel.removeChatRoomAdmin(roomId, username);
                    }
                });

        RxView.clicks(timeoutItem).throttleFirst(3, TimeUnit.SECONDS)
                .subscribe(new Consumer<Unit>() {
                    @Override
                    public void accept(Unit unit) throws Throwable {
                        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
                        final View view = LayoutInflater.from(mContext).inflate(R.layout.modify_info_dialog, null);
                        TextView title = view.findViewById(R.id.title);
                        TextView contentTip = view.findViewById(R.id.content_tip);
                        EditText editContent = view.findViewById(R.id.edit_content);
                        TextView countTip = view.findViewById(R.id.count_tip);
                        Button confirmBtn = view.findViewById(R.id.confirm);
                        Button cancelBtn = view.findViewById(R.id.cancel);

                        title.setText(mContext.getResources().getString(R.string.room_manager_timeout));
                        contentTip.setText(mContext.getString(R.string.room_manager_timeout_tip, username));
                        editContent.setInputType(InputType.TYPE_CLASS_NUMBER);
                        editContent.setSelection(editContent.getText().toString().length());

                        countTip.setVisibility(View.GONE);

                        final Dialog dialog = builder.create();
                        dialog.show();
                        dialog.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
                        dialog.getWindow().setGravity(Gravity.CENTER);
                        dialog.getWindow().setContentView(view);

                        confirmBtn.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if (!TextUtils.isEmpty(editContent.getText().toString())) {
                                    viewModel.muteChatRoomMembers(roomId, list, Integer.parseInt(editContent.getText().toString()));
                                    AttentionBean attention = new AttentionBean();
                                    attention.setShowTime(10);
                                    attention.setShowContent(mContext.getString(R.string.room_manager_timeout_attention_tip, username, editContent.getText().toString()));
                                    LiveDataBus.get().with(DemoConstants.REFRESH_ATTENTION).postValue(attention);
                                    dialog.cancel();
                                }
                            }
                        });
                        cancelBtn.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                dialog.cancel();
                            }
                        });
                    }
                });

        RxView.clicks(muteItem).throttleFirst(3, TimeUnit.SECONDS).subscribe(new Consumer<Unit>() {
            @Override
            public void accept(Unit unit) throws Throwable {
                showToast("mute");
                viewModel.muteChatRoomMembers(roomId, list, Integer.MAX_VALUE);
            }
        });

        RxView.clicks(unmuteItem).throttleFirst(3, TimeUnit.SECONDS)
                .subscribe(new Consumer<Unit>() {
                    @Override
                    public void accept(Unit unit) throws Throwable {
                        showToast("unmute");
                        viewModel.unMuteChatRoomMembers(roomId, list);
                    }
                });

        RxView.clicks(banItem).throttleFirst(3, TimeUnit.SECONDS)
                .subscribe(new Consumer<Unit>() {
                    @Override
                    public void accept(Unit unit) throws Throwable {
                        new SimpleDialogFragment.Builder(mContext)
                                .setTitle(mContext.getString(R.string.room_manager_ban_tip, username))
                                .setConfirmButtonTxt(R.string.ok)
                                .setConfirmColor(R.color.em_color_warning)
                                .setOnConfirmClickListener(new OnConfirmClickListener() {
                                    @Override
                                    public void onConfirmClick(View view, Object bean) {
                                        viewModel.banChatRoomMembers(roomId, list);
                                        AttentionBean attention = new AttentionBean();
                                        attention.setShowTime(10);
                                        attention.setShowContent(mContext.getString(R.string.room_manager_ban_attention_tip, username));
                                        LiveDataBus.get().with(DemoConstants.REFRESH_ATTENTION).postValue(attention);
                                    }
                                })
                                .build()
                                .show(getChildFragmentManager(), "dialog");
                    }
                });


        RxView.clicks(unbanItem).throttleFirst(3, TimeUnit.SECONDS)
                .subscribe(new Consumer<Unit>() {
                    @Override
                    public void accept(Unit unit) throws Throwable {
                        showToast("unban");
                        viewModel.unbanChatRoomMembers(roomId, list);
                    }
                });
    }

    @Override
    public void initData() {
        super.initData();
        mChatRoomManager = ChatClient.getInstance().chatroomManager();
        updateChatRoom(true);
    }

    private void updateChatRoom(boolean initView) {
        mChatRoom = mChatRoomManager.getChatRoom(roomId);
        updateView(initView);
    }

    private void showToast(String msg) {
        Toast.makeText(mContext.getApplicationContext(), msg, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onCheckedChanged(SwitchItemView buttonView, boolean isChecked) {
        if (buttonView.getId() == R.id.ban_all) {
            AttentionBean attention = new AttentionBean();
            if (isChecked) {
                viewModel.muteAllMembers(roomId);
                viewModel.muteChatRoomMembers(roomId, mChatRoom.getMemberList(), Integer.MAX_VALUE);
                attention.setShowTime(-1);
                attention.setShowContent(RoomUserDetailDialog.this.getResources().getString(R.string.attention_ban_all));
            } else {
                viewModel.unMuteAllMembers(roomId);
                viewModel.unMuteChatRoomMembers(roomId, mChatRoom.getMemberList());
                attention.setShowTime(-1);
                attention.setShowContent("");
            }
            LiveDataBus.get().with(DemoConstants.REFRESH_ATTENTION).postValue(attention);
            LiveDataBus.get().with(DemoConstants.REFRESH_MEMBER_STATE).postValue(true);
        }
    }
}
