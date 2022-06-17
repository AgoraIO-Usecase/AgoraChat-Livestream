import React, { memo } from 'react'
import { Box, Typography } from "@material-ui/core";
import { makeStyles } from "@material-ui/core/styles";
import i18next from "i18next";
import UserDialog from "./userDialog";
import settingIcon from '../../assets/images/settings.png'

const useStyles = makeStyles((theme) => {
    return {
        root:{
            width: "222px",
            height: "38px",
            background: "#262626",
        },
        settingBox: {
            display: "flex",
            alignItems: "center",
            width: "100%",
            height:"100%",
            cursor: "pointer",
        },
        IconStyle: {
            width: "24px",
            height: "24px"
        },
        textStyle: {
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
const UserSettings = () => {
    const classes = useStyles();
    const [anchorEl, setAnchorEl] = React.useState(null);
    const handleClick = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleClose = () => {
        setAnchorEl(null);
    };

    return (
        <div className={classes.root}>
            <Box className={classes.settingBox} onClick={handleClick}>
                <img src={settingIcon} alt="" className={classes.IconStyle} />
                <Typography className={classes.textStyle}>{i18next.t("Setting")}</Typography>
            </Box>
            <UserDialog open={anchorEl} onClose={handleClose} />
        </div>
    )
}
export default memo(UserSettings);