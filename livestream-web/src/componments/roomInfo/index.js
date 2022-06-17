import React, { useState, useEffect, memo } from 'react'
import { useSelector } from 'react-redux'
import { Box, Typography, InputBase } from "@material-ui/core";
import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';
import { TabPanel, a11yProps } from '../common/tab'
import { makeStyles } from "@material-ui/core/styles";
import i18next from "i18next";
import Members from './members'
import Moderators from './moderators'
import Allowed from './allowed'
import Ban from './ban'
import Muted from './muted'
import store from '../../redux/store'
import { miniRoomInfoAction, newRoomMemberInfoAction } from '../../redux/actions'
import { isChatroomAdmin } from '../common/contants'
import WebIM from '../../utils/WebIM'

import searchIcon from '../../assets/images/search.png'
import closeIcon from '../../assets/images/close.png'

const useStyles = makeStyles((theme) => {
    return ({
        root: {
            width: "340px",
            height: "560px",
            borderRadius: "16px",
            border: "1px solid #3D3D3D",
        },
        titleBox: {
            width: "calc(100% - 20px)",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            height: "60px",
            background: "#3D3D3D",
            padding: "0 10px",
            borderRadius: "12px 12px 0 0"
        },
        titleText: {
            height: "24px",
            fontFamily: "Roboto",
            fontSize: "18px",
            fontWeight: "600",
            lineHeight: "24px",
            letterSpacing: "0px",
            color: "#FFFFFF",
            fontStyle: "normal",
            left: "16px"
        },
        tabStyle: {
            // height:"60px",
            color: "#FFFFFF",
            background:"#2E2E2E",
            display:"flex",
            alignItems:"center"
        },
        menusBox: {
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: '100%',
            cursor: 'pointer',
        },
        textStyle: {
            textTransform: "none",
            fontFamily: "Roboto",
            fontSize: "16px",
            fontWeight: "600",
            lineHeight: "22px",
            letterSpacing: "0px",
            color: "#FFFFFF40",
        },
        iconBox: {
            display: "flex",
            alignItems: "center",
        },
        iconStyle: {
            width: "32px",
            height: "32px",
            cursor: "pointer"
        },
        searchBox: {
            width: "320px",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            height: "30px",
            padding: "0 !important",
            position: "relative"
        },
        searchStyle:{
            position: "absolute",
        },
        inputStyle: {
            borderRadius: "16px",
            width: "100%",
            // border: "1px solid #FFFFFF",
            padding: "0 15px 0 30px",
            marginRight: "4px",
            color: "#FFFFFF",
            background: "#5C5C5C"
        },
        cancelStyle: {
            textTransform: "none",
            fontFamily: "Roboto",
            fontSize: "16px",
            fontWeight: "600",
            lineHeight: "20px",
            textAlign: "center",
            color: "#FFFFFF",
            cursor: "pointer",
            marginLeft:"10px"
        }
    })
});




const RoomInfo = () => {
    const classes = useStyles();
    const [value, setValue] = useState(0);
    const [showSearch, setShowSearch] = useState(false);
    const [searchValue, setSearchValue] = useState("");
    const [roomMembers, setRoomMembers] = useState({});
    const [searchMembers, setSearchMembers] = useState([]);
    const isOwner = useSelector(state => state?.roomInfo?.owner);
    const roomId = useSelector(state => state?.roomInfo?.id);
    const roomList = useSelector(state => state?.rooms) || [];
    const memberList = useSelector(state => state?.roomInfo?.affiliations);
    const roomAdmins = useSelector(state => state?.roomAdmins);
    const roomMuted = useSelector(state => state?.roomMuted);
    const roomMemberInfo = useSelector(state => state?.roomMemberInfo);
    let memberLength = memberList?.length > 0 ? memberList?.length : "";
    let searchMembersLength = searchValue.length > 0;
    let exportMembers = searchMembersLength ? searchMembers : roomMembers;
    let isAdmins = isChatroomAdmin(WebIM.conn.context.userId) || isOwner === WebIM.conn.context.userId;
    useEffect(() => {
        let membersAry = {};
        let roomMutedAry = [];
        let showidNumber = '';
        if (roomMuted?.length > 0) {
            roomMuted.forEach(item => {
               if (item?.user) {
                   roomMutedAry.push(item.user)
               }else {
                   roomMutedAry.push(item)
               }
            })
        }
        if (roomList.length > 0 ) {
            roomList.forEach(item => {
                if (item.id === roomId) {
                    showidNumber = item.showid
                }
            })
        }
        if (memberList) {
            memberList.length > 0 && memberList.forEach((item) => {
                let { owner, member } = item;
                if (owner) {
                    membersAry[owner] = {
                        id: owner,
                        isStreamer: true,
                        isAdmin: roomAdmins.includes(owner),
                        isMuted: roomMutedAry.includes(owner),
                        nickname: roomMemberInfo[owner]?.nickname || '',
                        avatar: roomMemberInfo[owner]?.avatarurl || '',
                        showidNumber,
                    }
                } else {
                    membersAry[member] = {
                        id: member,
                        isStreamer: false,
                        isAdmin: roomAdmins.includes(member),
                        isMuted: roomMutedAry.includes(member),
                        nickname: roomMemberInfo[member]?.nickname || '',
                        avatar: roomMemberInfo[member]?.avatarurl || '',
                        showidNumber
                    }
                }
            });
            setRoomMembers(membersAry);
            store.dispatch(newRoomMemberInfoAction(membersAry))
        }else{
            setRoomMembers({})
        }
    }, [memberList, roomAdmins, roomMuted])

    const roomTabs = {
        all: () => {
            return (
                <Box className={classes.menusBox}>
                    <Typography className={classes.textStyle}>{i18next.t('All')}</Typography>
                </Box>
            )
        },
        moderators: () => {
            return (
                <Box className={classes.menusBox}>
                    <Typography className={classes.textStyle}>{i18next.t('Moderators')}</Typography>
                </Box>
            )
        },
        allowed: () => {
            return (
                <Box className={classes.menusBox}>
                    <Typography className={classes.textStyle}>{i18next.t('Allowed')}</Typography>
                </Box>
            )
        },
        muted: () => {
            return (
                <Box className={classes.menusBox}>
                    <Typography className={classes.textStyle}>{i18next.t('Muted')}</Typography>
                </Box>
            )
        },
        ban: () => {
            return (
                <Box className={classes.menusBox}>
                    <Typography className={classes.textStyle}>{i18next.t('Ban')}</Typography>
                </Box>
            )
        },

    }

    const handleChange = (event, newValue) => {
        setValue(newValue);
    };

    const handleChengeValue = (e) => {
        let searchObj = {}
        setSearchValue(e.target.value);
        Object.keys(roomMemberInfo).forEach((item) => {
            let isIncludes = roomMemberInfo[item].nickname && (roomMemberInfo[item].nickname).includes(e.target.value);
            if (isIncludes) {
                searchObj[item] = roomMemberInfo[item]
            }
        })
        setSearchMembers(searchObj)
    };

    const handleSearch = () => {
        setShowSearch(true);
    };

    const handleClosrSearch = () => {
        setShowSearch(false);
        setSearchValue("")
    };

    const handleCloseInfoChange = () => {
        store.dispatch(miniRoomInfoAction(true))
    }


    return (
        <Box className={classes.root}>
            <Box className={classes.titleBox}>
                {!showSearch && <Typography className={classes.titleText} >{memberLength > 0 ? `${i18next.t("Viewers")} (${memberLength})` : i18next.t("Viewers") }</Typography>}
                <Box className={classes.iconBox}>
                    {!showSearch && <img src={searchIcon} alt="" className={classes.iconStyle} onClick={handleSearch} />}
                    {showSearch && (
                        <Box className={classes.searchBox}>
                            <InputBase
                                type="search"
                                placeholder={i18next.t('Search Members')}
                                className={classes.inputStyle}
                                onChange={handleChengeValue}
                            />
                            <Typography
                                onClick={handleClosrSearch}
                                className={classes.cancelStyle}
                            >
                                {i18next.t("Cancel")}
                            </Typography>
                            <img src={searchIcon} alt="" className={classes.searchStyle}/>
                        </Box>
                    )}
                    {!showSearch && <img src={closeIcon} alt="" className={classes.iconStyle} onClick={() => handleCloseInfoChange()} />}
                </Box>

            </Box>
            {isAdmins ? <Box className={classes.tabsBox}>
                <Tabs
                    value={value}
                    onChange={handleChange}
                    variant="scrollable"
                    scrollButtons
                    // allowScrollButtonsMobile
                    aria-label="scrollable force tabs example"
                    className={classes.tabStyle}
                >
                    <Tab label={roomTabs.all()} {...a11yProps(0)} />
                    <Tab label={roomTabs.moderators()} {...a11yProps(1)} />
                    <Tab label={roomTabs.allowed()} {...a11yProps(2)} />
                    <Tab label={roomTabs.muted()} {...a11yProps(3)} />
                    <Tab label={roomTabs.ban()} {...a11yProps(4)} />

                </Tabs>
                <TabPanel value={value} index={0} >
                    <Members roomMembers={exportMembers} searchValue={searchValue} />
                </TabPanel>
                <TabPanel value={value} index={1} >
                    <Moderators />
                </TabPanel>
                <TabPanel value={value} index={2} >
                    <Allowed />
                </TabPanel>
                <TabPanel value={value} index={3} >
                    <Muted />
                </TabPanel>
                <TabPanel value={value} index={4} >
                    <Ban />
                </TabPanel>
            </Box> : <Members roomMembers={exportMembers} searchValue={searchValue} />}
        </Box>

    );
}

export default memo(RoomInfo)