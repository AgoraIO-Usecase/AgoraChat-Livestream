import React, { memo, useState } from 'react'
import { useSelector } from 'react-redux'
import { Box, Avatar, Typography } from "@material-ui/core";
import Popover from '@mui/material/Popover';
import { makeStyles } from "@material-ui/core/styles";
import i18next from "i18next";
import UserSettings from '../userSettings'
import agoraIcon from '../../assets/images/subtractLive@2x.png'
import agoraTitleIcon from '../../assets/images/agoraLiveStream.png'
import defaultAvatarImg from '../../assets/images/defaultAvatar.png'
const useStyles = makeStyles((theme) => {
    return {
        root: {
            height: "64px",
            // width: "100%",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            background: "#393939",
            padding:"0 36px",
        },
        userBox: {
            borderRadius: "0px",
            cursor: "pointer"
        },
        headerStyle: {
            height: "100%",
            display: 'flex',
            alignItems: "center",
        },
        avatarStayle: {
            width: '48px',
            height: "48px",
            background: "red",
            borderRadius: "50%",
            display: "flex",
            alignItems: "center",
            justifyContent: "center"
        },
        avatarStyle: {
            width: "48px",
            height: "48px"
        },
        titleStyle: {
            // height: "28px",
            // width: "auto",
            // fontFamily: "Roboto",
            // fontWeight: "400",
            // fontSize: "24px",
            // lineHeight: "28px",
            // color: "#FFFFFF",
            marginLeft: "8px"
        },
        settingBox: {
            display: "flex",
            alignItems: "center",
            width: "128px",
            background: "#262626",
            cursor: "pointer"
        },
        settingIconStyle: {
            width: "24px",
            height: "24px"
        },
        settingTextStyle: {
            fontFamily: "Roboto",
            fontSize: "14px",
            fontWeight: "500",
            lineHeight: "20px",
            letterSpacing: "0px",
            textAlign: "left",
            color: "#FFFFFF"
        }
    }
});

const Header = () => {
    const classes = useStyles();
    const userInfo = useSelector(state => state?.userInfo) || {};
    let { avatarurl } = userInfo;
    const [anchorEl, setAnchorEl] = useState(null);

    const handleClick = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleClose = () => {
        setAnchorEl(null);
    };
    return (
        <Box className={classes.root}>
            <Box className={classes.headerStyle}>
                <Box className={classes.avatarStayle}>
                    <Avatar src={agoraIcon} className={classes.avatarStyle}></Avatar>
                </Box>
                <img src={agoraTitleIcon} alt="" className={classes.titleStyle}/>
                {/* <Typography className={classes.titleStyle}>{i18next.t('Agora LiveStream')}</Typography> */}
            </Box>
            <Box className={classes.userBox} >
                <Avatar src={avatarurl || defaultAvatarImg} className={classes.avatarStyle} aria-describedby="user-popover" onClick={handleClick}></Avatar>
                <Popover
                    id="user-popover"
                    open={Boolean(anchorEl)}
                    anchorEl={anchorEl}
                    onClose={handleClose}
                    anchorOrigin={{
                        vertical: 'bottom',
                        horizontal: 'left',
                    }}
                >
                    <UserSettings />
                </Popover>
            </Box>
        </Box >
    )
}

export default memo(Header);