package io.agora.livedemo.data.model;

import io.agora.chat.ChatMessage;
import io.agora.livedemo.ui.widget.barrage.DataSource;

public class MessageBean implements DataSource {
    private ChatMessage message;
    private int type;

    public ChatMessage getMessage() {
        return message;
    }

    public void setMessage(ChatMessage message) {
        this.message = message;
    }

    public void setType(int type) {
        this.type = type;
    }

    @Override
    public int getType() {
        return type;
    }

    @Override
    public String toString() {
        return "MessageBean{" +
                "message=" + message +
                ", type=" + type +
                '}';
    }
}
