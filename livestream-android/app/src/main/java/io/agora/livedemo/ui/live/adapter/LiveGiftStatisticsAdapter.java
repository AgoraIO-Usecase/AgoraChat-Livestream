package io.agora.livedemo.ui.live.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import io.agora.chat.uikit.adapter.EaseBaseRecyclerViewAdapter;
import io.agora.chat.uikit.widget.EaseImageView;
import io.agora.livedemo.R;
import io.agora.livedemo.common.utils.DemoHelper;
import io.agora.livedemo.common.db.entity.ReceiveGiftEntity;
import io.agora.livedemo.data.model.GiftBean;

public class LiveGiftStatisticsAdapter extends EaseBaseRecyclerViewAdapter<ReceiveGiftEntity> {

    @Override
    public ViewHolder getViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.layout_live_gift_statistics_item, parent, false);
        return new GiftViewHolder(view);
    }

    private class GiftViewHolder extends ViewHolder<ReceiveGiftEntity> {
        private EaseImageView imgAvatar;
        private TextView txtUsernick;
        private TextView tvGiftInfo;
        private ImageView ivGiftIcon;

        public GiftViewHolder(@NonNull View itemView) {
            super(itemView);
        }

        @Override
        public void initView(View itemView) {
            imgAvatar = findViewById(R.id.img_avatar);
            txtUsernick = findViewById(R.id.txt_usernick);
            tvGiftInfo = findViewById(R.id.tv_gift_info);
            ivGiftIcon = findViewById(R.id.iv_gift_icon);
        }

        @Override
        public void setData(ReceiveGiftEntity item, int position) {
            String giftId = item.getGift_id();
            GiftBean giftBean = DemoHelper.getGiftById(giftId);
            if (giftBean != null) {
                ivGiftIcon.setImageResource(giftBean.getResource());
            }
            tvGiftInfo.setText(mContext.getString(R.string.live_gift_gift_info, item.getGift_num()));

            txtUsernick.setText(mContext.getString(R.string.live_gift_sender_info, item.getFrom()));
            //imgAvatar.setImageResource(DemoHelper.getAvatarResource(item.getFrom()));

        }
    }
}
