package io.agora.livedemo.data.restapi;


import io.agora.exceptions.ChatException;

public class LiveException extends ChatException {
    protected int errorCode = -1;

    public LiveException() {
    }

    public LiveException(int errorCode, String desc) {
        super(desc);
        this.errorCode = errorCode;
    }

    public LiveException(String message) {
        super(message);
    }


    public int getErrorCode() {
        return errorCode;
    }
}
