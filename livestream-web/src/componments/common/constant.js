import store from '../../redux/store'

export const isChatroomAdmin = (userId) => {
    let adminAry = store.getState()?.roomAdmins || []
    return adminAry.includes(userId);
}

export const appConfig = {
    apiurl: (window.location.protocol === 'https:' ? 'https:' : 'http:') + "//a1.easemob.com",
    orgName: "easemob-demo",
    appName: "chatdemoui"
}

export const liveStreamConfig = {
    domain: (window.location.protocol === 'https:' ? 'https:' : 'http:') + "//a1.easemob.com",
    protocol: "hls",  // hls  flv  rtmp
    liveDomian: "ws-rtmp-pull.easemob.com",
    pushPoint: "live"
}

export const genderObj = {
    0: {
        id:"1",
        gender: "Male" 
    },
    1: {
        id: "2",
        gender: "Female"
    },
    2: {
        id: "3",
        gender: "Other"
    },
    3: {
        id: "4",
        gender: "Secret"
    },
}


export const roomTabs = ['All', 'Moderators', 'Allowed', 'Muted', 'ban']


