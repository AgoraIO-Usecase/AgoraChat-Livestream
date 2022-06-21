
let defaultState = {
    userInfo: {},
    rooms: [],
    roomInfo: {},
    roomMemberInfo: {},
    roomMemberInfoObj:{},
    roomAdmins: [],
    roomAllowed: [],
    roomMuted: [],
    roomBans: [],
    isMini: false,
    giftMsgs: [],
    giftAry:[
        {
            id:1,
            gift_id: "gift_1",
            gift_img: "pink_heart@2x.png",
            goldCoins: "gold.png",
            gift_price: 1,
            gift_name: "PinkHeart",
            clickStatus: false
        },
        {
            id:2,
            gift_id: "gift_2",
            gift_img: "plastic_flower@2x.png",
            goldCoins: "gold.png",
            gift_price: 5,
            gift_name: "PlasticFlower",
            clickStatus: false
        },
        {
            id:3,
            gift_id: "gift_3",
            gift_img: "the_push_box@2x.png",
            goldCoins: "gold.png",
            gift_price: 10,
            gift_name: "ThePushBox",
            clickStatus: false
        },
        {
            id:4,
            gift_id: "gift_4",
            gift_img: "big_ace@2x.png",
            goldCoins: "gold.png",
            gift_price: 20,
            gift_name: "BigAce",
            clickStatus: false
        },
        {
            id:5,
            gift_id: "gift_5",
            gift_img: "star.png",
            goldCoins: "gold.png",
            gift_price: 50,
            gift_name: "Star",
            clickStatus: false
        },
        {
            id:6,
            gift_id: "gift_6",
            gift_img: "lollipop@2x.png",
            goldCoins: "gold.png",
            gift_price: 100,
            gift_name: "Lollipop",
            clickStatus: false
        },
        {
            id:7,
            gift_id: "gift_7",
            gift_img: "diamond@2x.png",
            goldCoins: "gold.png",
            gift_price: 500,
            gift_name: "Diamond",
            clickStatus: false
        },
        {
            id:8,
            gift_id: "gift_8",
            gift_img: "crown@2x.png",
            goldCoins: "gold.png",
            gift_price: 1000,
            gift_name: "Crown",
            clickStatus: false
        }
    ],
    liveCdnUrl: "",
    isDisabledInput: true
};

const reducer = (state = defaultState, action) => {
    const { type, data, option } = action;
    switch (type) {
        case "USER_INFO_ACTION":
            return {
                ...state,
                userInfo: data
            };
        case "ROOMS_ACTION":
            return {
                ...state,
                rooms: data
            };
        case "ROOM_INFO_ACTION":
            return {
                ...state,
                roomInfo: data
            };
        case "ROOM_MEMBER_INFO_ACTION":
            return {
                ...state,
                roomMemberInfo: data
            };
        case "NEW_ROOM_MEMBER_INFO_ACTION":
            return {
                ...state,
                roomMemberInfoObj: data
            };
        case "ROOM_ADMINS_ACTION":
            return {
                ...state,
                roomAdmins: data
            };
        case "ROOM_ALLOWED_ACTION":
            return {
                ...state,
                roomAllowed: data
            };
        case "ROOM_MUTED_ACTION":
            let newData = [];
            if (option?.type === "add") {
                newData = newData.concat(data);
            } else if (option?.type === "remove"){
                newData = (state?.roomMuted).filter(item => item !== data);
            }else{
                newData = data
            }
            return {
                ...state,
                roomMuted: newData
            };
        case "ROOM_BAN_ACTION":
            return {
                ...state,
                roomBans: state.roomBans.concat(data)
            };
        case "MINI_ROOM_INFO_ACTION":
            return {
                ...state,
                isMini: data
            };
        case "GIFT_MSG_ACTION":
            let giftMsgsAry = state.giftMsgs.concat(data)
            return {
                ...state,
                giftMsgs: giftMsgsAry
            };
        case "CLEAR_GIFT_MSG_ACTION":
            let newGiftMsgs = (state?.giftMsgs).filter(item => item.id !== data);
            return {
                ...state,
                giftMsgs: newGiftMsgs
            };
        case "GET_LIVE_CDN_URL_ACTION":
            return {
                ...state,
                liveCdnUrl: data
            };
        case "UPDATE_GIFT_STATUS_ACTION":
            let { giftAry } = state;
            const giftAryCp = [...giftAry]
            giftAryCp.forEach((item) => {
                if (item.gift_id === data.gift_id){
                    item = data
                }
            })
            return{
                ...state,
                giftAry: giftAryCp
            }
        case "UIKIR_DISABLED_INPUT_ACTION":
            return {
                ...state,
                isDisabledInput: data
            }
        default:
            break;
    }
}

export default reducer;

