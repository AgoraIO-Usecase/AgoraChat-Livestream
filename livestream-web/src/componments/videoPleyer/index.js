import React, { useState, useEffect, memo } from 'react'
import { useSelector } from 'react-redux'
import { Box, Avatar, Typography, InputBase } from "@material-ui/core";
import { makeStyles } from "@material-ui/core/styles";
import ReactPlayer from 'react-player'
import WebIM from '../../utils/WebIM'
import store from '../../redux/store'
import { clearGiftMsgAction } from '../../redux/actions'

import defaultAvatar from '../../assets/images/defaultAvatar.png'
const useStyles = makeStyles((theme) => {
    return {
        root: {
            position: "relative",
            border: "1px solid #3D3D3D",
            borderRadius: "12px 0 0 12px"
        },
        videoBox: {
            width: "340px !important",
            // height: "398px !important",
            borderRadius: "12px 0 0 12px"
        },
        giftBox: {
            height: "150px",
            position: "absolute",
            bottom: "40px",
            left: "10px",
            overflowY: "scroll",
            width: "calc(100% - 3x0px)",
        },
        giftMsgStyle: {
            height: "40px",
            borderRadius: "30px",
            display: "flex",
            marginTop: "15px",
            background: "#00000066",
            padding: "3px 12px 3px 0",
            alignItems: "center"
        },
        avatarStyle: {
            height: "32px",
            width: "32px",
            padding: "2px 0 2px 2px"
        },
        userBox: {
            marginLeft: "8px"
        },
        giftUserStyle: {
            fontFamily: "Roboto",
            fontSize: "14px",
            fontWeight: "500",
            lineHeight: "18px",
            letterSpacing: "0.15px",
            textAlign: "left",
            color: "#FFFFFF",
        },
        giftNameStyle: {
            fontFamily: "Roboto",
            fontSize: "12px",
            fontWeight: "400",
            lineHeight: "14px",
            letterSpacing: "0.15px",
            textAlign: "left",
            color: "#FFFFFFBD",
            marginTop: "4px"
        },
        giftImg: {
            width: "36px",
            height: "36px",
            marginLeft: "8px",
        },
        giftNumberStyle: {
            fontFamily: "Roboto",
            fontSize: "24px",
            fontStyle: "italic",
            fontWeight: "900",
            lineHeight: "32px",
            letterSpacing: "0.15px",
            textAlign: "left",
            color: "#FFFFFF",
            marginLeft: "12px"
        }
    }
});
const VideoPlayer = () => {
    const classes = useStyles();
    const liveCdnUrl = useSelector(state => state?.liveCdnUrl);
    const giftMsgs = useSelector(state => state?.giftMsgs) || [];
    const giftAry = useSelector(state => state?.giftAry) || [];
    const roomMemberInfo = useSelector(state => state?.roomMemberInfo);
    const currentLoginUser = WebIM.conn.context.userId;
    let isGiftMsg = giftMsgs.length > 0;
    const [giftObj, setGiftObj] = useState({})
    useEffect(() => {
        let gifts = {};
        giftAry.forEach(item => {
            gifts[item.gift_id] = item
        })
        setGiftObj(gifts)
    }, [giftAry])


    const clearGiftMsg = (id) => {
        let timerId = id;
        timerId = setTimeout(() => {
            store.dispatch(clearGiftMsgAction(id));
            clearTimeout(timerId);
        }, 3000);
    }
    return (
        <Box className={classes.root} >
                <ReactPlayer
                    url={liveCdnUrl}
                    className={classes.videoBox}
                    playing={true}
                    controls
                    width='100%'
                    height='100%'
                    config={{
                        file: {
                            forceHLS:true
                        }
                    }}
                    pip={true}
                />
            <Box className={classes.giftBox}>
                {isGiftMsg && giftMsgs.map((item,i) => {
                    let { id, customExts, from } = item;
                    let { gift_id, gift_num } = customExts;
                    if (!gift_id) return
                    let { gift_img, gift_name } = giftObj[gift_id];
                    let giftSender = from ? from : currentLoginUser;
                    clearGiftMsg(id);
                    return (
                        <Box key={id + i} className={classes.giftMsgStyle}>
                            <Avatar src={roomMemberInfo[giftSender]?.avatarurl || defaultAvatar} className={classes.avatarStyle}></Avatar>
                            <Box className={classes.userBox}>
                                <Typography className={classes.giftUserStyle}>{roomMemberInfo[giftSender]?.nickname || giftSender}</Typography>
                                <Typography className={classes.giftNameStyle}>{`sent ${gift_name}`}</Typography>
                            </Box>
                            <img
                                className={classes.giftImg}
                                src={require(`../../assets/gift/${gift_img || ""}`)}
                                alt=""
                            />
                            <Box>
                                <Typography className={classes.giftNumberStyle}>{`x${gift_num}`}</Typography>
                            </Box>
                        </Box>
                    )
                })}
            </Box>
        </Box>
    )
}

export default memo(VideoPlayer);