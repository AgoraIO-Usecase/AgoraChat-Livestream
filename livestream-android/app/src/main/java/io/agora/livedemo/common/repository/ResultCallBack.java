package io.agora.livedemo.common.repository;


import io.agora.ValueCallBack;

public abstract class ResultCallBack<T> implements ValueCallBack<T> {

    public void onError(int error) {
        onError(error, null);
    }
}
