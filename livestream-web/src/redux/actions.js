
export const userInfoAction = (data) => {
    return { type: 'USER_INFO_ACTION', data };
}

export const roomsAction = (data) => {
    return { type: 'ROOMS_ACTION', data };
};

export const roomInfoAction = (data) => {
    return { type: 'ROOM_INFO_ACTION', data };
};

export const roomMemberInfoAction = (data) => {
    return { type: 'ROOM_MEMBER_INFO_ACTION', data };
};

export const newRoomMemberInfoAction = (data) => {
    return { type: 'NEW_ROOM_MEMBER_INFO_ACTION', data };
}

export const roomAdminsAction = (data) => {
    return { type: 'ROOM_ADMINS_ACTION', data };
};

export const roomAllowedAction = (data) => {
    return { type: 'ROOM_ALLOWED_ACTION', data };
};

export const roomMutedAction = (data, option) => {
    return { type: 'ROOM_MUTED_ACTION', data, option };
}

export const roomBanAction = (data) => {
    return { type: 'ROOM_BAN_ACTION', data };
}

export const miniRoomInfoAction = (data) => {
    return { type: 'MINI_ROOM_INFO_ACTION', data };
}

export const giftMsgAction = (data) => {
    return { type: 'GIFT_MSG_ACTION', data };
}

export const getLiveCdnUrlAction = (data) => {
    return { type: 'GET_LIVE_CDN_URL_ACTION', data };
}

export const clearGiftMsgAction = (data) => {
    return { type: 'CLEAR_GIFT_MSG_ACTION', data };
}

export const updateGiftStatusAction = (data) => {
    return { type: 'UPDATE_GIFT_STATUS_ACTION', data };
}

export const uikitDisabledInputAction = (data) => {
    return { type: 'UIKIR_DISABLED_INPUT_ACTION', data };

}