import React, { memo } from 'react'
import { useSelector } from 'react-redux'
import { makeStyles } from "@material-ui/core/styles";
import { Box, List, ListItem, ListItemText, Avatar, Button, Typography } from "@material-ui/core";
import acaratImg from '../../../assets/images/defaultAvatar.png'
import streamerIcon from '../../../assets/images/streamer.png'
import moderatorIcon from '../../../assets/images/moderator.png'
import blockedIcon from '../../../assets/images/blocked@2x.png'


const useStyles = makeStyles((theme) => {
    return {
        root: {
            overflow: "hidden",
            height: "426px"
        },
        acaratStyle: {
            width: "24px",
            height: "24px"
        },
        listBox: {
            overflowY: "scroll",
            overflowX: "hidden",
            height: "100%",
            cursor: "pointer"
        },
        listItem: {
            height: "54px",
            width: "100%",
            borderRadius: "12px",
            background: (props) => (props.hideMenus ? "#393939" : ""),
            display: "flex",
            justifyContent: "space-between",
        },
        memberStyle: {
            display: "flex",
            alignItems: "center"
        },
        memberTextStyle: {
            fontFamily: "Roboto",
            fontSize: "14px",
            fontWeight: "500",
            lineHeight: "18px",
            letterSpacing: "0px",
            color: "#FFFFFF",
            width: "180px",
            textOverflow: "ellipsis",
            overflow: "hidden",
            whiteSpace: "nowrap",
            textAlign: "left",
            textTransform: "none"
        },
        menuStyle: {
            cursor: "pointer"
        },
        userInfoBox: {
            marginLeft: "10px"
        },
        roleStyle: {
            display: "flex",
            marginTop: "4px"
        },
        iconRoleStyle: {
            width: "61px",
            height: "16px"
        },
    }
});
const Allowed = () => {
    const classes = useStyles();
    const memberList = useSelector(state => state?.roomAllowed) || [];
    const roomMemberInfo = useSelector(state => state?.roomMemberInfoObj) || {};
    return (
        <Box className={classes.root}>
            {
                memberList.length > 0 && memberList.map((item,i)=> {
                    return <Button className={classes.listItem} key={i}>
                        <Box className={classes.memberStyle}>
                            <Avatar src={roomMemberInfo[item]?.avatarurl || acaratImg} ></Avatar>
                            <Box className={classes.userInfoBox}>
                                <Box className={classes.roleStyle}>
                                    <Typography className={classes.memberTextStyle} >{roomMemberInfo[item]?.nickname || item}</Typography>
                                    {roomMemberInfo[item]?.isMuted && <img src={blockedIcon} alt="" />}
                                </Box>
                                <Box className={classes.roleStyle}>
                                    {roomMemberInfo[item]?.isStreamer && <img src={streamerIcon} alt="" className={classes.iconRoleStyle} />}
                                    {roomMemberInfo[item]?.isAdmin && <img src={moderatorIcon} alt="" />}
                                </Box>
                            </Box>
                        </Box>
                    </Button>
                })
            }
        </Box>
    )
}
export default memo(Allowed);