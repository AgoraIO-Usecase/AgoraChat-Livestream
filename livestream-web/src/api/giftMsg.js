import WebIM from '../utils/WebIM'
import store from '../redux/store'
import { giftMsgAction, updateGiftStatusAction, clearGiftMsgAction } from '../redux/actions'

export const sendGiftsMsg = (selectGift, inputValue) => {
    const currentLoginUser = WebIM.conn.context.userId;
    let roomId = store.getState().roomInfo?.id
    var id = WebIM.conn.getUniqueId();         
    var msg = new WebIM.message('custom', id);   
    var customEvent = "chatroom_gift";     
    var customExts = {
        gift_id: selectGift.gift_id,
        gift_num: inputValue.toString()
    };                          
    msg.set({
        to: roomId,                        
        customEvent,
        form: currentLoginUser, 
        customExts,                               
        chatType: 'chatRoom',               
        success: function (id, serverMsgId) {
            msg.body.id = serverMsgId;
            store.dispatch(giftMsgAction(msg.body));
            selectGift.clickStatus = true;
            store.dispatch(updateGiftStatusAction(selectGift))
            setTimeout(() => {
                selectGift.clickStatus = false;
                store.dispatch(updateGiftStatusAction(selectGift))
            }, 3000);
        },
        fail: function (e) { }
    });
    WebIM.conn.send(msg.body);
}