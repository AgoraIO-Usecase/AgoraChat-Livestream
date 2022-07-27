import WebIM from '../utils/WebIM'


const getUserId = () => {
    return 'xxxx-xxxx-4xxx-xxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0,
            v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

const registerUserId = (user) => {
    let pwd = "123456"
    var options = {
        username: user,
        password: pwd,
        appKey: WebIM.config.appkey,
        success: function (res) { 
            console.log('register user success >>>', res);
            let user = res.entities[0].username;
            loginIM(user)
        },
        error: function (err) {
            console.log('register user fail >>>', err);
        },
    };
    WebIM.conn.registerUser(options);
}

const loginIM = (user,) => {
    let pwd = "123456"
    let options = {
        user,
        pwd,
        appKey: WebIM.config.appkey
    };
    WebIM.conn.open(options).then((res) => {
        let { accessToken } = res;
        let { user, pwd } = options;
        sessionStorage.setItem('webim_auth', JSON.stringify({ user, pwd, accessToken }))
    }).catch((err) => {
        console.log('loginIM fail>>>', err);
        let errorMsg = JSON.parse(err.data?.data);
        if (errorMsg.error_description === "user not found") {
            registerUserId(user)
        }
    });
}

export const openIM = () => {
    let webimAuth = sessionStorage.getItem('webim_auth') || {}
    if (Object.keys(webimAuth).length > 0) {
        let { user } = JSON.parse(webimAuth);
        loginIM(user)
    } else {
        let user = getUserId().split('-').join('');
        registerUserId(user)
    }
};


export const closeIM = () => {
    WebIM.conn.close()
}


