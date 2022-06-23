
import WebIM from '../utils/WebIM'
import store from '../redux/store'
import { userInfoAction, roomMemberInfoAction } from '../redux/actions'
import axios from 'axios';
import { appConfig } from '../componments/common/constant'

export const uploadAvatar = (couterRef) => {
    let webimAuth = sessionStorage.getItem('webim_auth') || {}
    let { accessToken } = JSON.parse(webimAuth);
    let file = couterRef.current.files[0]
    let param = new FormData();
    param.append('file',file,file.name)
    let config = {
        method: 'post',
        url: `${appConfig.apiurl}/${appConfig.orgName}/${appConfig.appName}/chatfiles`,
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': `Bearer ${accessToken} ` 
        },
        data: param
    }
    return axios(config)
}


export const updateUserInfo = (avatarUrl, nickName, gender, Birthday) => {
    let options = {
        nickname: nickName,
        avatarurl: avatarUrl || '',
        gender: gender,
        birth: Birthday
    }
    WebIM.conn.updateOwnUserInfo(options).then((res) => {
        store.dispatch(userInfoAction(res.data))
    })
}


export const getUserInfo = async (member) => {
    let count = 0;
    while (member.length > count) {
        let curmembers = member.slice(count, count + 100);
        await WebIM.conn.fetchUserInfoById(curmembers).then((res) => {
            store.dispatch(roomMemberInfoAction(res.data));
        });
        count += 100;
    }
};


