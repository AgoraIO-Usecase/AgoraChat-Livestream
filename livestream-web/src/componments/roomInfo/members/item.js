import React, { useState, memo } from 'react'
import { useSelector } from 'react-redux'
import { makeStyles } from "@material-ui/core/styles";
import { Box, Avatar, Button, Typography, List, Popover } from "@material-ui/core";
import ListItemButton from '@mui/material/ListItemButton';
import WebIM from '../../../utils/WebIM'
import { addRoomWhiteUser, addRoomMuted, addRoomBlock } from '../../../api/room'
import i18next from "i18next";
import acaratImg from '../../../assets/images/defaultAvatar.png'
import ellipsisIcon from '../../../assets/images/ellipsis.png'
import streamerIcon from '../../../assets/images/streamer.png'
import moderatorIcon from '../../../assets/images/moderator.png'
import mutedIcon from '../../../assets/images/mute.png'
import allowIcon from '../../../assets/images/allowed@2x.png'
import timeoutIcon from '../../../assets/images/timeout.png'
import blockIcon from '../../../assets/images/blocked@2x.png'
import closeIcon from '../../../assets/images/close.png'


const useStyles = makeStyles((theme) => {
    return {
        listItemStyle: {
            height: "54px",
            width: "calc(100% - 10px)",
            borderRadius: "12px",
            padding: "0 10px",
            background: (props) => (props.hideMenus ? "#393939" : ""),
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            marginTop: "4px",
            position: "relative"
        },
        memberStyle: {
            display: "flex",
            alignItems: "center",
            width: "100%"
        },
        memberTextStyle: {
            fontFamily: "Roboto",
            fontSize: "14px",
            fontWeight: "500",
            lineHeight: "18px",
            letterSpacing: "0px",
            color: "#FFFFFF",
            maxWidth: "180px",
            textOverflow: "ellipsis",
            overflow: "hidden",
            whiteSpace: "nowrap",
            textAlign: "left",
            textTransform: "none",
            marginRight: "4px"
        },
        menuStyle: {
            cursor: "pointer",
            position: "absolute",
            right: "40px",
            display: "flex"
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
        root: {
            background: "#1A1A1A"
        },
        itemStyle: {
            background: "#393939",
            borderRadius: "12px",
            height:"36px",
            padding:"8px"
        },
        iconStyle: {
            width: "20px",
            height: "20px",
        },
        textStyle: {
            fontFamily: "Roboto",
            fontSize: "14px",
            fontWeight: "500",
            lineHeight: "20px",
            letterSpacing: "0px",
            textAlign: "left",
            color: "#FFFFFF",
            marginLeft: "10px"
        },
        popoverBox: {
            height: "180px",
            width: "420px",
            borderRadius: "12px",
            background: "#1A1A1A",
            position: "relative",
            display: "flex",
            paddingLeft: "10px"
        },
        closeStyle: {
            position: "absolute",
            right: "21px",
            top: "23px",
            width: "24px",
            height: "24px",
            cursor: "pointer"
        },
        renderTextStyle: {
            fontFamily:"Roboto",
            fontWeight:"400",
            display: "flex",
            alignItems: "center",
            color: "#FFFFFF",
            margin: "0 20px"
        },
        userTextStyle:{
            margin: "8px",
            fontWeight: "800",
            maxWidth: "180px",
            overflow: "hidden",
            textOverflow: "ellipsis"
        },
        btnBox: {
            position: "absolute",
            bottom: "10px",
            right: "10px"
        },
        cancelBtnStyle: {
            background: "#393939",
            borderRadius: "26px",
            width: "84px",
            height: "36px",
            textTransform: "none",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color:"#FFFFFF"
        },
        okayBtnStyle: {
            background: "#114EFF",
            borderRadius: "26px",
            width: "84px",
            height: "36px",
            textTransform: "none",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: "#FFFFFF"
        }
    }
});

const MemberItem = ({ member, roomMembers, key }) => {
    const [hideMenus, setHideMenus] = useState(false)
    const [anchorEl, setAnchorEl] = useState(null);
    const [confirmAnchorEl, setConfirmAnchorEl] = useState(null);
    const [clickType, setClickType] = useState("")
    const [clickUser, setClickUser] = useState("")
    const classes = useStyles(
        hideMenus,
    );
    const roomId = useSelector(state => state?.roomInfo.id);
    const roomMemberInfo = useSelector(state => state?.roomMemberInfoObj) || {};
    const roomOwner = useSelector(state => state?.roomInfo?.owner) || "";
    const roomAdmin = useSelector(state => state?.roomAdmins) || [];
    const currentLoginUser = WebIM.conn.context.userId;
    let isOwner = roomOwner === member;
    let isAdmin = roomAdmin.includes(currentLoginUser)
    let isMyself = member === currentLoginUser;
    const handleMenus = (e) => {
        console.log('>>>>>', e);
        e.preventDefault();
        e.stopPropagation()
        setAnchorEl(e.currentTarget);
    }
    const handleMenusClose = () => {
        setAnchorEl(null);
    };

    const handleHover = () => {
        setHideMenus(true)
    }

    const handleRemove = () => {
        setHideMenus(false);
        setAnchorEl(null);
        setConfirmAnchorEl(null)
    }
    const handleConfirmChange = (e, user, type) => {
        setConfirmAnchorEl(e.currentTarget);
        setClickType(type);
        setClickUser(user);
    }

    const handleConfirmClose = () => {
        setConfirmAnchorEl(null);
    }

    const handleClick = (type, user) => {
        switch (type) {
            case "allow":
                addRoomWhiteUser(roomId, user, handleMenusClose)
                break;
            case "timeout":
                addRoomMuted(roomId, user, handleMenusClose)
                break;
            case "ban":
                addRoomBlock(roomId, user, handleMenusClose)
                break;
            default:
                break;
        }
    }
    const renderComfirmModel = () => {
        return <Popover
            open={Boolean(confirmAnchorEl)}
            anchorEl={confirmAnchorEl}
            onClose={handleConfirmClose}
            anchorOrigin={{
                vertical: 'top',
                horizontal: 'left',
            }}
            transformOrigin={{
                vertical: 'bottom',
                horizontal: 'left',
            }}
        >
            <Box className={classes.popoverBox}>
                <img src={closeIcon} alt="close popover" className={classes.closeStyle} onClick={() => handleConfirmClose()} ></img>
                <Typography className={classes.renderTextStyle}>
                    {`Want to ${clickType}`} 
                    <span className={classes.userTextStyle}>{roomMemberInfo[clickUser]?.nickname || clickUser}</span>
                    {"?"}
                </Typography>
                <Box className={classes.btnBox}>
                    <Button>
                        <Typography
                            className={classes.cancelBtnStyle}
                            onClick={() => { handleConfirmClose() }}>
                            {i18next.t("Cancel")}
                        </Typography>
                    </Button>
                    <Button>
                        <Typography
                            className={classes.okayBtnStyle}
                            onClick={() => { handleClick(clickType, clickUser) }}>
                            {i18next.t("Okay")}
                        </Typography>
                    </Button>
                </Box>
            </Box>
        </Popover>
    }
    return <>
        <Button className={classes.listItemStyle} key={key} onMouseOver={() => { handleHover() }}
            onMouseLeave={() => { handleRemove() }}>
            <Box className={classes.memberStyle} >
                <Avatar src={roomMemberInfo[member]?.avatar || acaratImg}></Avatar>
                <Box className={classes.userInfoBox}>
                    <Box className={classes.roleStyle}>
                        <Typography className={classes.memberTextStyle} >{roomMemberInfo[member]?.nickname || member}</Typography>
                        {roomMembers[member]?.isMuted && <img src={mutedIcon} alt="" />}
                    </Box>
                    <Box className={classes.roleStyle}>
                        {roomMembers[member]?.isStreamer && <img src={streamerIcon} alt="" className={classes.iconRoleStyle} />}
                        {roomMembers[member]?.isAdmin && <img src={moderatorIcon} alt="" />}
                    </Box>
                </Box>
            </Box>
            {hideMenus && !isOwner && isAdmin && !isMyself && <Box className={classes.menuStyle} onClick={handleMenus}>
                <img src={ellipsisIcon} alt="" />
            </Box>}
            <Popover
                open={Boolean(anchorEl)}
                anchorEl={anchorEl}
                onClose={handleMenusClose}
                anchorOrigin={{
                    vertical: 'bottom',
                    horizontal: 'left',
                }}
                transformOrigin={{
                    vertical: 'top',
                    horizontal: 'left',
                }}
            >
                <List component="nav" aria-label="main mailbox folders" className={classes.root}>
                    <ListItemButton
                        className={classes.itemStyle}
                        onClick={(e) => handleConfirmChange(e, member, 'allow')}>
                        <img
                            src={allowIcon}
                            alt=""
                            className={classes.iconStyle}
                        />
                        <Typography className={classes.textStyle}>
                            {i18next.t("Move to Allowed List")}
                        </Typography>
                    </ListItemButton>
                    <ListItemButton
                        className={classes.itemStyle}
                        onClick={(e) => handleConfirmChange(e, member, 'timeout')}
                    >
                        <img src={timeoutIcon} alt="" className={classes.iconStyle} />
                        <Typography className={classes.textStyle}>
                            {i18next.t("Timeout")}
                        </Typography>
                    </ListItemButton>
                    <ListItemButton
                        className={classes.itemStyle}
                        onClick={(e) => handleConfirmChange(e, member, 'ban')}
                    >
                        <img src={blockIcon} alt="" className={classes.iconStyle} />
                        <Typography className={classes.textStyle}>
                            {i18next.t("Ban")}
                        </Typography>
                    </ListItemButton>
                </List>
                {renderComfirmModel()}
            </Popover>
        </Button>
        {/* <Menus open={anchorEl} onClose={handleMenusClose} selectUserId={member} /> */}
    </>
}

export default memo(MemberItem);
