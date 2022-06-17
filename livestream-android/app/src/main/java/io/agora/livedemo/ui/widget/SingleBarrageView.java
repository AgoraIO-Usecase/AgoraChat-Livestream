package io.agora.livedemo.ui.widget;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import io.agora.chat.ChatClient;
import io.agora.chat.ChatMessage;
import io.agora.chat.Conversation;
import io.agora.livedemo.R;
import io.agora.livedemo.common.utils.DemoMsgHelper;
import io.agora.livedemo.data.model.MessageBean;
import io.agora.livedemo.ui.widget.barrage.BarrageAdapter;
import io.agora.livedemo.ui.widget.barrage.BarrageView;

public class SingleBarrageView extends BarrageView {
    private BarrageAdapter<MessageBean> mAdapter;
    private Conversation conversation;
    private String chatId;

    public SingleBarrageView(Context context) {
        super(context);
    }

    public SingleBarrageView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public SingleBarrageView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }


    public void initBarrage() {
        Options options = new Options()
                .setGravity(BarrageView.GRAVITY_TOP)
                .setInterval(100)
                .setSpeed(200, 29)
                .setModel(BarrageView.MODEL_COLLISION_DETECTION)
                .setRepeat(1)
                .setClick(false);
        setOptions(options);

        mAdapter = new BarrageAdapter<MessageBean>(null, getContext()) {
            @Override
            protected BarrageViewHolder<MessageBean> onCreateViewHolder(View root, int type) {
                return new ViewHolder(root);
            }

            @Override
            public int getItemLayout(MessageBean messageBean) {
                return R.layout.barrage_item;
            }
        };

        setAdapter(mAdapter);
    }

    /**
     * refresh
     */
    public void refresh() {
        if (!TextUtils.isEmpty(chatId)) {
            setData(chatId);
        }
    }

    public void addData(ChatMessage message) {
        MessageBean bean = new MessageBean();
        bean.setMessage(message);
        bean.setType(message.getType().ordinal());
        mAdapter.add(bean);
    }

    public void setData(String id) {
        this.chatId = id;
        conversation = ChatClient.getInstance().chatManager().getConversation(id, Conversation.ConversationType.ChatRoom, true);
        List<ChatMessage> messages = conversation.getAllMessages();
        setData(messages);
    }

    public void setData(List<ChatMessage> messages) {
        if (messages != null && !messages.isEmpty()) {
            List<MessageBean> list = new ArrayList<>();
            MessageBean bean;
            for (ChatMessage message : messages) {
                bean = new MessageBean();
                bean.setMessage(message);
                bean.setType(message.getType().ordinal());
                list.add(bean);
            }
            mAdapter.addList(list);
        }
    }

    public class ViewHolder extends BarrageAdapter.BarrageViewHolder<MessageBean> {
        private ImageView mHeadView;
        private TextView mContent;

        public ViewHolder(View itemView) {
            super(itemView);

            mHeadView = itemView.findViewById(R.id.image);
            mContent = itemView.findViewById(R.id.content);
        }

        @Override
        protected void onBind(MessageBean data) {
            String barrageTxt = DemoMsgHelper.getInstance().getMsgBarrageTxt(data.getMessage());
            if (!TextUtils.isEmpty(barrageTxt)) {
                mContent.setText(barrageTxt);
            }
        }
    }
}
