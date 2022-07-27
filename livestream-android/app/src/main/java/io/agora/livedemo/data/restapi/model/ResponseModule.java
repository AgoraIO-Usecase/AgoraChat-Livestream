package io.agora.livedemo.data.restapi.model;

import com.google.gson.annotations.SerializedName;

import io.agora.livedemo.data.model.BaseBean;

public class ResponseModule<T> extends BaseBean {
    @SerializedName("entities")
    public T data;
    public int count;
    public String cursor;
}
