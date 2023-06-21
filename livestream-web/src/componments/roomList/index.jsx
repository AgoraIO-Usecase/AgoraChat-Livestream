import React, { memo, useState, useRef } from 'react'
import { useSelector } from 'react-redux'
import { Box, Typography, InputBase } from "@material-ui/core";
import { makeStyles } from "@material-ui/core/styles";
import { EaseApp } from 'chat-uikit-live';
import i18next from "i18next";
import { joinRoom } from '../../api/room'
import { getLiverooms } from '../../api/liveCdn'
import NoSearch from '../common/noSearch'
import liveImg from '../../assets/images/defaultLive.png'
import lrsImg from '../../assets/images/lrs.png'
import leftIcon from '../../assets/images/channels_list_left@2x.png'
import rightIcon from '../../assets/images/channels_list_right@2x.png'
import searchIcon from '../../assets/images/search.png'
import ellipseIcon from '../../assets/images/ellipse.png'
import Img from './img'
const useStyles = makeStyles((theme) => {
    return {
        root: {
            overflow: "hidden",
            // background: "#292929",
            padding: " 0 36px 37px",
            position: "relative"
        },
        titleBox: {
            display: "flex",
            padding: "0 20px",
            alignItems: "center",
            justifyContent: "space-between"
        },
        titleStyle: {
            display: "flex",
            alignItems: "center"
        },
        inputStyle: {
            marginLeft: '10px',
            background: "#3D3D3D",
            borderRadius: "18px",
            padding: "0 30px",
            color: "#FFFFFF"
        },
        roomBox: {
            display: "flex",
            // width: "100%",
            overflowX: "scroll",
            marginTop: "10px",
        },
        itemStyle: {
            position: "relative",
            height: "180px",
            width: "180px",
            margin: "0 6px",
            borderRadius: "12px",
            cursor: "pointer"
            // border: "1px solid"
        },
        numberBox: {
            display: "flex",
            alignItems: "center",
            position: "absolute",
            top: "10px",
            left: "10px",
            width: "37px",
            height: "16px",
            borderRadius: "8px",
            // background: "linear-gradient(97.17deg, #FF0000 5.3 %, #8000FF 97.97 %)"
            background: "linear-gradient(to right, #FF0000 , #8000FF);"
        },
        ellipseIconStyle: {
            paddingLeft: "5px"
        },
        numberTextStyle: {
            fontFamily: "Roboto",
            fontSize: "14px",
            fontWeight: "700",
            lineHeight: "16px",
            letterSpacing: "0.15000000596046448px",
            textAlign: "left",
            color: "#FFFFFF",
            marginLeft: "4px"
        },
        liveImgStyle: {
            width: "180px",
            height: "180px",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            borderRadius: "12px",
            // border: "1px solid",
        },
        textStyle: {
            fontFamily: "Roboto",
            fontSize: "18px",
            fontWeight: "600",
            lineHeight: "24px",
            letterSpacing: "0px",
            textAlign: "left",
            color: "#FFFFFF"
        },
        lrsInfoBox: {
            position: "absolute",
            bottom: "10px",
            left: "10px"
        },
        nameStyle: {
            fontFamily: "Roboto",
            fontSize: "16px",
            fontWeight: "600",
            lineHeight: "20px",
            letterSpacing: "0em",
            textAlign: "left",
            color: "#FFFFFF",
            width: "140px",
            height: "20px",
            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap"
        },
        lrsBox: {
            display: "flex",
            alignItems: "center"
        },
        lrsNameStyle: {
            fontFamily: "Roboto",
            fontSize: "12px",
            fontWeight: "400",
            lineHeight: "16px",
            letterSpacing: "0em",
            textAlign: "left",
            color: "#FFFFFF",
            width: "120px",
            textOverflow: "ellipsis",
            overflow: "hidden",
            whiteSpace: "nowrap",
            marginLeft: "4px"
        },
        iconRightStyle: {
            height: "44px",
            width: "44px",
            borderRadius: "8px",
            background: "#FFFFFF80",
            boxShadow: "0px 4px 16px 0px #00000066",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            position: "absolute",
            right: "50px",
            bottom: "50px",
            cursor: "pointer"
        },
        iconLeftStyle: {
            height: "44px",
            width: "44px",
            borderRadius: "8px",
            background: "#FFFFFF80",
            boxShadow: "0px 4px 16px 0px #00000066",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            position: "absolute",
            left: "50px",
            bottom: "50px",
            cursor: "pointer"
        },
        iconStyle: {
            width: "32px",
            height: "32px"
        },
        noSearchBox: {
            height: "180px",
            width: "100%"
        },
        searchBox: {
            position: "relative",
            display: "flex",
            alignItems: "center",
        },
        searchIconBox: {
            position: "absolute",
            left: "8px"
        },
        refreshStyle: {
            height: "32px",
            width: "82px",
            borderRadius: "30px",
            background: "linear-gradient(to right, red , #e252d3)"
        },
        refreshTextStyle: {
            fontFamily: "Roboto",
            fontSize: "14px",
            fontWeight: "600",
            lineHeight: "32px",
            letterSpacing: "0px",
            textAlign: "center",
            color: "#FFFFFF",
            cursor: "pointer"
        }
    }
});

const RoomList = () => {
    const classes = useStyles();
    const roomList = useSelector(state => state?.rooms) || [];
    const [searchValue, setSearchValue] = useState("")
    const [searchRoomList, setSearchRoomList] = useState([])
    const [leftIconChange, setLeftIconChange] = useState(false)
    let searchValueLength = searchValue.length > 0;
    let exportRoomList = searchValueLength ? searchRoomList : roomList;

    const addSessionItem = (roomId) => {
        let session = {
            conversationType: "chatRoom",
            conversationId: roomId,
        };
        EaseApp.addConversationItem(session);
    };
    const handleJoinRoom = (liveroomId) => {
        joinRoom(liveroomId, addSessionItem);
        // getLiveRoomInfo(liveroomId)
    }

    const handleValueChange = (e) => {
        let { value } = e.target;
        setSearchValue(value)
        setSearchRoomList(roomList.filter((v) => (v.name.toLocaleLowerCase()).includes(value.toLocaleLowerCase())));
    }

    const listRef = useRef();
    const handleLeftChange = (e) => {
        e.preventDefault();
        let toLeft = 0;
        toLeft -= listRef.current.offsetWidth
        listRef.current.scrollTo(toLeft, 0)
        setLeftIconChange(false)
    }
    const handleRightChange = (e) => {
        e.preventDefault();
        let toRight = 0;
        toRight += listRef.current.offsetWidth
        listRef.current.scrollTo(toRight, 0)
        setLeftIconChange(true)
    }

    return (
        <Box className={classes.root}>
            <Box className={classes.titleBox}>
                <Box className={classes.titleStyle}>
                    <Typography className={classes.textStyle}>{i18next.t('Stream Channels')}</Typography>
                    <Box className={classes.searchBox}>
                        <InputBase
                            type="search"
                            placeholder={i18next.t("Search Channel")}
                            className={classes.inputStyle}
                            onChange={handleValueChange}
                        />
                        <img src={searchIcon} alt="" className={classes.searchIconBox} />
                    </Box>
                </Box>
                <Box className={classes.refreshStyle} onClick={() => getLiverooms()}>
                    <Typography className={classes.refreshTextStyle}>{i18next.t('Refresh')}</Typography>
                </Box>
            </Box>
            <Box className={classes.roomBox} ref={listRef}>
                {exportRoomList.length > 0 ? exportRoomList.map((item, i) => {
                    let { cover, id, name, owner, affiliations_count } = item
                    return (
                        <Box key={i}>
                            <Box className={classes.itemStyle} onClick={() => handleJoinRoom(id)}>
                                <Box className={classes.numberBox}>
                                    <img src={ellipseIcon} alt="" className={classes.ellipseIconStyle} />
                                    <Typography className={classes.numberTextStyle}>{affiliations_count}</Typography>
                                </Box>
                                <Img src={cover || liveImg} alt="" className={classes.liveImgStyle}/>
                                <Box className={classes.lrsInfoBox}>
                                    <Typography className={classes.nameStyle}>{name}</Typography>
                                    <Box className={classes.lrsBox}>
                                        <img src={lrsImg} alt="" />
                                        <Typography className={classes.lrsNameStyle}>{owner}</Typography>
                                    </Box>
                                </Box>
                            </Box>
                        </Box>
                    )
                }) : <Box className={classes.noSearchBox}><NoSearch value={searchValue}/></Box>}
            </Box>
            {leftIconChange && <Box className={classes.iconLeftStyle} onClick={handleLeftChange}>
                <img src={leftIcon} alt="" className={classes.iconStyle} />
            </Box>}
            {exportRoomList.length > 0 && <Box className={classes.iconRightStyle} onClick={handleRightChange}>
                <img src={rightIcon} alt="" className={classes.iconStyle} />
            </Box>}
        </Box>
    )
}
export default memo(RoomList);