
import React, { useState, useRef } from 'react'
import { useSelector } from 'react-redux'
import i18next from "i18next";
import CommonDialog from '../common/dialog'
import { Box, Tabs, Tab, Button, Avatar, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { TabPanel, a11yProps } from "../common/tab";
import InfoSetting from './info'
import { uploadAvatar, updateUserInfo } from '../../api/userInfo'
import WebIM from '../../utils/WebIM'
import defaultAvatarUrlImg from '../../assets/images/defaultAvatar.png'
import infoIcon from '../../assets/images/info.png'
import editIcon from '../../assets/images/edit.png'
const useStyles = makeStyles((theme) => {
    return ({
        root: {
            background: "red",
            color: "red"
        },
        userBox: {
            width: "880px",
            height: "680px",
            display: "flex",
            overflow: "hidden",
            background: "#393939"
        },
        infoBox:{
            width: "100%",
            display:"flex",
            justifyContent: "flex-start",
            background: "#393939",
            borderRadius: "8px"
        },
        acatarBox: {
            display: "flex",
            justifyContent: "center",
            padding: "20px 40px",
            position: "relative"
        },
        avatarStyle: {
            height: "100px",
            width: "100px",
            borderRadius: "50px",
            opacity: ".4"
        },
        tabStyle:{
            padding: "0 10px"
        },
        nameTextStyle: {
            fontFamily: "Roboto",
            fontSize: "16px",
            fontWeight: "400",
            lineHeight: "24px",
            letterSpacing: "0.15px",
            textAlign: "center",
            color: "#FFFFFF",
            marginBottom: "30px",
            width: "100%",
            overflow: "hidden",
            textOverflow: "ellipsis"
        },
        editBox:{
            position: "absolute",
            top: "58px",
            left: "120px",
            cursor: "pointer"
        },
        editAvatarStyle:{
            width: "24px",
        },
        menusText: {
            fontFamily: "Roboto",
            fontSize: "1px",
            fontWeight: "500",
            lineHeight: "20px",
            letterSpacing: "0px",
            textAlign: "left",
            textTransform: "none",
            color:"#FFFFFF",
            marginLeft:"12px"
        },
        iconStyle:{
            width:"24px",
            height:"24px"
        },
        contentStyle:{
            width:"70%",
            height:"100%",
            background:"#292929"
        }
    })
});

const UserDialog = ({ open, onClose }) => {
    const classes = useStyles();
    const userInfo = useSelector(state => state?.userInfo) || {};
    const [value, setValue] = useState(0);
    // const userAvatar = useState(userInfo.avatarurl)
    let currentLoginUser = WebIM.conn.context.userId;
    const couterRef = useRef();
    const handleAvatarChange = () => {
        couterRef.current.focus();
        couterRef.current.click();
    };

    const handleuploadAvatar = () => {
        uploadAvatar(couterRef).then(function (response) {
            console.log('AAA>>>>>', response);
            let { uri,entities } = response.data;
            let updateUrl = uri + '/' + entities[0].uuid
            updateUserInfo(updateUrl);
            couterRef.current.value = null;
        }).catch(function (error) {
                console.log(error);
            });
    }

    const handleChange = (event, newValue) => {
        setValue(newValue);
    };
   

    const infoLabel = () => {
        return (
            <Button className={classes.infoBox}>
                <img
                    src={infoIcon}
                    alt="info"
                    className={classes.iconStyle}
                ></img>
                <Typography className={classes.menusText}>
                    {i18next.t("Info")}
                </Typography>
            </Button>
        );
    };

    const renderDialog = () => {
        return (
            <Box className={classes.userBox}>
                <Box style={{ width: "30%", background:"#1E1E1E" }}>
                    <Box>
                        <Box className={classes.acatarBox} onClick={handleAvatarChange}>
                            <Avatar src={userInfo.avatarurl || defaultAvatarUrlImg} className={classes.avatarStyle}>
                            </Avatar>
                            <Box className={classes.editBox}>
                                <img src={editIcon} alt="" className={classes.editAvatarStyle} />
                                <input
                                    id="uploadImage"
                                    type="file"
                                    ref={couterRef}
                                    style={{
                                        display: 'none',
                                    }}
                                    onChange={handleuploadAvatar}
                                />
                            </Box>
                        </Box>
                        <Box>
                            <Typography className={classes.nameTextStyle}>{userInfo?.nickname || currentLoginUser}</Typography>
                        </Box>
                    </Box>
                    {/* <Tabs
                        orientation="vertical"
                        value={value}
                        onChange={handleChange}
                        aria-label="Vertical tabs example"
                    >
                        <Tab label={infoLabel()} {...a11yProps(0)} className={classes.menus} />
                    </Tabs> */}
                    <Box className={classes.tabStyle}>
                        <Button className={classes.infoBox}>
                            <img
                                src={infoIcon}
                                alt="info"
                                className={classes.iconStyle}
                            ></img>
                            <Typography className={classes.menusText}>
                                {i18next.t("Info")}
                            </Typography>
                        </Button>
                    </Box>
                </Box>
                {/* <TabPanel value={value} index={0} className={classes.contentStyle}> */}
                    <InfoSetting />
                {/* </TabPanel> */}
            </Box>
        )
    }

    return (
        <CommonDialog
            open={Boolean(open)}
            onClose={onClose}
            title={i18next.t('Setting')}
            content={renderDialog()}
            maxWidth={880}
            style={{background:"#292929"}}
            // className={classes.root}
        ></CommonDialog>
    )
}

export default UserDialog;