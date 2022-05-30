package io.agora.livedemo.ui.live.adapter;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.bumptech.glide.Glide;

import io.agora.chat.uikit.adapter.EaseBaseRecyclerViewAdapter;
import io.agora.chat.uikit.utils.EaseUserUtils;
import io.agora.livedemo.DemoConstants;
import io.agora.livedemo.R;
import io.agora.livedemo.data.model.LiveRoom;
import io.agora.livedemo.utils.NumberUtils;
import io.agora.livedemo.utils.Utils;

public class LiveListAdapter extends EaseBaseRecyclerViewAdapter<LiveRoom> {
    private String status;
    private boolean isOngoing;

    @Override
    public PhotoViewHolder getViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).
                inflate(R.layout.layout_livelist_item, parent, false);
        return new PhotoViewHolder(view);
    }

    public void setStatus(String status) {
        this.status = status;
        isOngoing = !TextUtils.isEmpty(status) && TextUtils.equals(status, DemoConstants.LIVE_ONGOING);
    }

    private class PhotoViewHolder extends ViewHolder<LiveRoom> {
        private ImageView photo;
        private TextView tvLivingAudienceNum;
        private TextView author;
        private TextView liveRoomName;

        public PhotoViewHolder(@NonNull View itemView) {
            super(itemView);
        }

        @Override
        public void initView(View itemView) {
            photo = findViewById(R.id.photo);
            tvLivingAudienceNum = findViewById(R.id.tv_living_audience_num);
            author = findViewById(R.id.author);
            liveRoomName = findViewById(R.id.live_room_name);

            tvLivingAudienceNum.setTypeface(Utils.getRobotoTypeface(mContext.getApplicationContext()));
        }

        @Override
        public void setData(LiveRoom liveRoom, int position) {
            Glide.with(mContext)
                    .load(liveRoom.getCover())
                    .placeholder(R.drawable.live_default_bg)
                    .into(photo);

            tvLivingAudienceNum.setText(NumberUtils.amountConversion(liveRoom.getAudienceNum()));
            liveRoomName.setText(liveRoom.getName());
            EaseUserUtils.setUserNick(liveRoom.getOwner(), author);
        }
    }
}
