package io.agora.livedemo.ui.other.viewmodels;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.arch.core.util.Function;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Transformations;

import io.agora.livedemo.common.enums.Status;
import io.agora.livedemo.common.reponsitories.ClientRepository;
import io.agora.livedemo.common.reponsitories.ErrorCode;
import io.agora.livedemo.common.reponsitories.Resource;
import io.agora.livedemo.data.repository.UserRepository;
import io.agora.livedemo.data.model.User;

public class LoginViewModel extends AndroidViewModel {
    private final ClientRepository repository;
    private final MediatorLiveData<Resource<User>> loginObservable;

    public LoginViewModel(@NonNull Application application) {
        super(application);
        repository = new ClientRepository();
        loginObservable = new MediatorLiveData<>();
    }

    public LiveData<Resource<User>> getLoginObservable() {
        return loginObservable;
    }


    public void login() {
        User user = UserRepository.getInstance().getCurrentUser();
        if (null == user) {
            user = UserRepository.getInstance().getRandomUser();
        }
        User finalUser = user;
        LiveData<Resource<User>> livedata = Transformations.switchMap(repository.login(user), new Function<Resource<User>, LiveData<Resource<User>>>() {
            @Override
            public LiveData<Resource<User>> apply(Resource<User> input) {
                if (input.status == Status.SUCCESS) {
                    return new MutableLiveData<>(input);
                } else if (input.status == Status.ERROR) {
                    int errorCode = input.errorCode;
                    if (errorCode == ErrorCode.USER_NOT_FOUND) {
                        return Transformations.switchMap(repository.register(finalUser), input2 -> {
                            if (input2.status == Status.SUCCESS) {
                                return repository.login(input2.data);
                            } else if (input2.status == Status.ERROR) {
                                return new MutableLiveData<>(Resource.error(input2.errorCode, input2.getMessage(), null));
                            } else {
                                return new MutableLiveData<>(Resource.loading(null));
                            }
                        });
                    } else {
                        return new MutableLiveData<>(Resource.error(input.errorCode, input.getMessage(), null));
                    }
                } else {
                    return new MutableLiveData<>(Resource.loading(null));
                }
            }
        });
        loginObservable.addSource(livedata, response -> loginObservable.postValue(response));
    }
}
