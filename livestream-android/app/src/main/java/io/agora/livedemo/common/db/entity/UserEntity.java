package io.agora.livedemo.common.db.entity;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.Ignore;
import androidx.room.Index;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.agora.chat.ChatClient;
import io.agora.chat.UserInfo;
import io.agora.chat.uikit.models.EaseUser;
import io.agora.livedemo.data.repository.UserRepository;


@Entity(tableName = "users", primaryKeys = {"username"},
        indices = {@Index(value = {"username"}, unique = true)})
public class UserEntity extends EaseUser {
    /**
     * the timestamp when user init
     */
    private long userInitialTimestamp;

    public UserEntity() {
        super();
    }

    public long getUserInitialTimestamp() {
        return userInitialTimestamp;
    }

    public void setUserInitialTimestamp(long userInitialTimestamp) {
        this.userInitialTimestamp = userInitialTimestamp;
    }

    @Ignore
    public UserEntity(@NonNull String username) {
        super(username);
    }

    @Ignore
    public static List<UserEntity> parseList(List<EaseUser> users) {
        List<UserEntity> entities = new ArrayList<>();
        if (users == null || users.isEmpty()) {
            return entities;
        }
        UserEntity entity;
        for (EaseUser user : users) {
            entity = parseParent(user);
            entities.add(entity);
        }
        return entities;
    }

    @Ignore
    public static UserEntity parseParent(EaseUser user) {
        UserEntity entity = new UserEntity();
        entity.setUsername(user.getUsername());
        entity.setNickname(user.getNickname());
        entity.setAvatar(user.getAvatar());
        entity.setInitialLetter(user.getInitialLetter());
        entity.setContact(user.getContact());
        entity.setEmail(user.getEmail());
        entity.setGender(user.getGender());
        entity.setBirth(user.getBirth());
        entity.setPhone(user.getPhone());
        entity.setSign(user.getSign());
        entity.setExt(user.getExt());
        entity.setLastModifyTimestamp(user.getLastModifyTimestamp());
        return entity;
    }

    @Ignore
    public static List<EaseUser> parse(List<String> ids) {
        List<EaseUser> users = new ArrayList<>();
        if (ids == null || ids.isEmpty()) {
            return users;
        }
        for (String id : ids) {
            EaseUser user = UserRepository.getInstance().getUserInfo(id);
            if (user != null) {
                users.add(user);
            }
        }
        return users;
    }

    @Ignore
    public static List<EaseUser> parse(String[] ids) {
        List<EaseUser> users = new ArrayList<>();
        if (ids == null || ids.length == 0) {
            return users;
        }
        for (String id : ids) {
            EaseUser user = UserRepository.getInstance().getUserInfo(id);
            if (user != null) {
                users.add(user);
            }
        }
        return users;
    }

    @Ignore
    public static List<EaseUser> parseUserInfo(Map<String, UserInfo> userInfos) {
        List<EaseUser> users = new ArrayList<>();
        if (userInfos == null || userInfos.isEmpty()) {
            return users;
        }
        EaseUser user;
        Set<String> userSet = userInfos.keySet();
        Iterator<String> it = userSet.iterator();
        while (it.hasNext()) {
            String userId = it.next();
            UserInfo info = userInfos.get(userId);
            user = new EaseUser(info.getUserId());
            user.setNickname(info.getNickName());
            user.setAvatar(info.getAvatarUrl());
            user.setEmail(info.getEmail());
            user.setGender(info.getGender());
            user.setBirth(info.getBirth());
            user.setSign(info.getSignature());
            user.setExt(info.getExt());
            if (!info.getUserId().equals(ChatClient.getInstance().getCurrentUser())) {
                users.add(user);
            }

        }
        return users;
    }

    @NonNull
    @Override
    public String toString() {
        return "UserEntity{" + super.toString() + "," +
                "userInitialTimestamp=" + userInitialTimestamp +
                '}';
    }
}
