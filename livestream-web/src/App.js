import React, { useEffect,useRef } from 'react'
import { useSelector } from 'react-redux'
import initListen from './utils/WebIMListen'
import { openIM } from './api/layout'
import Box from '@mui/material/Box';
import Header from './componments/header'
import VideoPlayer from './componments/videoPleyer'
import { EaseLivestream } from 'chat-uikit-live';
import Gift from './componments/gift'
import RoomInfo from './componments/roomInfo'
import RoomList from './componments/roomList'
import Footer from './componments/footer'
import { makeStyles } from "@material-ui/core/styles";
import store from './redux/store'
import { miniRoomInfoAction, uikitDisabledInputAction } from './redux/actions'
import unionIcon from './assets/images/union.png'
import './i18n'

import './App.css'
const useStyles = makeStyles((theme) => {
	return {
		root: {
			backgroundColor: "#292929",
			overflow: "hidden",
			height: (props) => (props.isAdapter ? "100vh" : "100%"),
		},
		bodyBox:{
			display: "flex", 
			justifyContent: "space-between", 
			padding: "24px 36px 28px" ,
			height: (props) => (props.isAdapter ? "calc(100% - 466px)" : "720px")
		},
		iconBox: {
			height: "44px",
			width: "44px",
			display: "flex",
			alignItems: "center",
			justifyContent: "center",
			background:" #3D3D3D",
			cursor:"pointer",
			borderRadius:"12px"
		},
		chatBox:{
			display: "flex", 
			width: "100%", 
			height: "calc(100% - 162px)",
			// height:"396px",
			marginBottom: "4px"
		},
		uikitBox:{
			width: "100%",
			borderRadius: "0 12px 12px 0",
			border: "1px solid #3D3D3D",
			overflow: "hidden"
		},
		footerBox:{
			position: (props) =>  (props.isAdapter ? "absolute" : "none" ),
			bottom: "0px",
			width: "100%"
		}
	}
});
const App = () => {
	const roomMemberInfoObj = useSelector(state => state?.roomMemberInfoObj) || {};
	const isDisabledInput = useSelector(state => state?.isDisabledInput);
	const bodyRef = useRef();
	const isAdapter = bodyRef?.current?.offsetHeight > 1174;
	console.log('isAdapter>>>', isAdapter);
	const classes = useStyles({
		isAdapter
	});
	useEffect(() => {
		initListen()
		openIM()
		store.dispatch(uikitDisabledInputAction(true))
	}, [])
	const isMini = useSelector(state => state?.isMini);
	const openRoomInfo = () => {
		store.dispatch(miniRoomInfoAction(false));
	}
	return (
		<Box className={classes.root} ref={bodyRef}>
			<Header />
			<Box className={classes.bodyBox}>
				<Box style={{ width: "100%", marginRight: "10px" }}>
					<Box className={classes.chatBox}>
						<VideoPlayer />
						<Box className={classes.uikitBox}>
							<EaseLivestream 
								roomUserInfo={roomMemberInfoObj} 
								disabledInput={isDisabledInput}
								easeInputMenu="onlyInput"
							/>
						</Box>
					</Box>
					<Gift />
				</Box>
				{isMini ? <Box onClick={() => openRoomInfo()} className={classes.iconBox}>
					<img src={unionIcon} alt="" /></Box> : <RoomInfo />}
			</Box>
			<Box className={classes.footerBox}>
				<RoomList />
				<Footer />
			</Box>
		</Box>
	);
}

export default App;
