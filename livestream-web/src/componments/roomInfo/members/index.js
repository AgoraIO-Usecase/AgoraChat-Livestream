import React, { useState, useEffect, memo } from 'react'
import { useSelector } from 'react-redux'
import { makeStyles } from "@material-ui/core/styles";
import { Box, List } from "@material-ui/core";
import MemberItem from './item'
import NoSearch from '../../common/noSearch'
import WebIM from '../../../utils/WebIM'
const useStyles = makeStyles((theme) => {
    return {
        root: {
            overflow: "hidden",
            width: (props) => (props.isAdmin ? "292px" : "340px"),
            // height: "calc(100% - 60px)"
            height: "708px"
        },
        listBox: {
            overflowY: "auto",
            overflowX: "hidden",
            height: "100%",
            padding: "0"
        },
    }
});
const Members = ({ roomMembers, searchValue }) => {
    let currentLoginUser = WebIM.conn.context.userId;
    const roomAdmins = useSelector(state => state?.roomAdmins) || [];
    let isAdmin = roomAdmins.includes(currentLoginUser);
    const classes = useStyles({
        isAdmin,
    });
    let roomMembersObj = Object.keys(roomMembers);

    return (
        <Box className={classes.root}>
            <List className={classes.listBox}>
                {roomMembersObj.length > 0 ? roomMembersObj.map((item, i) => {
                    return <MemberItem member={item} roomMembers={roomMembers} key={i} />
                }) : <NoSearch value={searchValue} />}
            </List>
        </Box>
    )
}
export default memo(Members);
