package io.agora.livedemo.common.db;

import androidx.room.Database;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;

import io.agora.livedemo.common.db.converter.DateConverter;
import io.agora.livedemo.common.db.dao.ReceiveGiftDao;
import io.agora.livedemo.common.db.dao.UserDao;
import io.agora.livedemo.common.db.entity.ReceiveGiftEntity;
import io.agora.livedemo.common.db.entity.UserEntity;

@Database(entities = {ReceiveGiftEntity.class, UserEntity.class}, version = 4, exportSchema = false)
@TypeConverters(DateConverter.class)
public abstract class AppDatabase extends RoomDatabase {

    public abstract ReceiveGiftDao receiveGiftDao();

    public abstract UserDao userDao();

}
