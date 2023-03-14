import WebIM from "./WebIM";
import i18next from "i18next";
import { updateUserInfo } from '../api/userInfo'
import { getLiverooms } from '../api/liveCdn'
import { getRoomInfo,getRoomAdmins, getRoomMuteList, getRoomWriteList, leaveRoom } from '../api/room'
import store from '../redux/store'
import { giftMsgAction, roomInfoAction, roomBanAction, roomMutedAction } from '../redux/actions'
import { isChatroomAdmin } from '../componments/common/constant'
import {message} from '../componments/common/alert'
const initListen = () => {
	WebIM.conn.listen({
		onOpened: () => {
			console.log('login succes>>>');
			updateUserInfo();
			getLiverooms();
		},
		onClosed: () => {
		},
		onError: (err) => {
			console.log("onError>>>", err);
		},
		onPresence: (event) => {
			console.log("onPresence>>>", event);
		},
		onContactInvited: (msg) => {
			console.log("onContactInvited", msg);
		},

		onCustomMessage: (msg) => {
			console.log('onCustomMessage>>>',msg);
			store.dispatch(giftMsgAction(msg))
		},
		onTokenWillExpire: () => {
			
		},
	});

	WebIM.conn.addEventHandler("REQUESTS", {
		onContactInvited: (msg) => {
			console.log("onContactInvited", msg);	
		},
		onGroupChange: (msg) => {
			console.log("onGroupChange", msg);
		},
		onChatroomChange: (event) => {
			console.log('onChatroomChange',event);
			let { type,gid,to } = event;
			let currentLoginUser = WebIM.conn.context.userId;
			switch (type) {
				case "memberJoinChatRoomSuccess":
					getRoomInfo(gid)
					break;
				case "addAdmin":
					message.info(i18next.t("You have been added as Moderator! "))
					getRoomAdmins(gid);
					break;
				case "removeAdmin":
					message.info(i18next.t("You have been removed as Moderator! "))
					getRoomAdmins(gid);
					break;
				case "addMute":
					isChatroomAdmin(to) && getRoomMuteList(gid);
					if (to === currentLoginUser){
						message.error(i18next.t("You're under a gag order! "))
						store.dispatch(roomMutedAction(currentLoginUser, { type: "add" }))
					}
					break;     
				case "removeMute":
					isChatroomAdmin(to) && getRoomMuteList(gid);
					if (to === currentLoginUser) {
						message.info(i18next.t("Your gag order has been lifted! "))
						store.dispatch(roomMutedAction(currentLoginUser,{type: "remove"}))
					}
					break;
				case "muteChatRoom":
					message.error(i18next.t("The Streamer has been gagged by all!"))
					break;
				case "rmChatRoomMute":
					message.error(i18next.t("The Streamer has lifted the gag order!"))
					break;
				case "addUserToChatRoomWhiteList":
					isChatroomAdmin(to) && getRoomWriteList(gid);
					break;
				case "rmUserFromChatRoomWhiteList":
					isChatroomAdmin(to) && getRoomWriteList(gid);
					break;
				case "removedFromGroup":
					getLiverooms();
					store.dispatch(roomBanAction(to))
					store.dispatch(roomMutedAction([]))
					break;
				case "deleteGroupChat":
					getLiverooms();
					store.dispatch(roomInfoAction({}))
					store.dispatch(roomMutedAction([]))
					break;
				default:
					break;
			}
		}
	});

	WebIM.conn.addEventHandler("TOKENSTATUS", {
		onTokenWillExpire: (token) => {
		},
		onTokenExpired: () => {
			console.error("onTokenExpired");
		},
		onConnected: () => {
			console.log("onConnected");
		},
		onDisconnected: () => {
			console.log("onDisconnected");
		},
	});
};

export default initListen;
