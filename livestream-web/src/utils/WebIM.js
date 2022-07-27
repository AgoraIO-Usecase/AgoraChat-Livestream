
import { EaseApp } from "chat-uikit-live";
import { appConfig } from '../componments/common/contants'

// 41117440#383391      71117440#417715
const WebIM = EaseApp.getSdk({ appkey: `${appConfig.orgName}#${appConfig.appName}` });

export default WebIM;

