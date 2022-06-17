import React, { memo } from 'react'
import { makeStyles } from "@material-ui/core/styles";
import { Box, Typography } from "@material-ui/core";
import i18next from "i18next";
const useStyles = makeStyles((theme) => {
    return {
        root: {
            width: "100%",
            height: "100%",
            display: "flex",
            alignItems: "center",
            justifyContent: "center"
        },
        textStyle: {
            fontFamily: "SF Compact Text",
            fontSize: "18px",
            fontWeight: "600",
            lineHeight: "28px",
            letterSpacing: "0px",
            textAlign: "center",
            color: "#999999"
        }
    }
});

const NoSearch = ({value}) => {
    const classes = useStyles();
    return <Box className={classes.root}>
        <Typography className={classes.textStyle}>{i18next.t(`No Reasult for ${value || "IM"}`)}</Typography>
    </Box>
}

export default memo(NoSearch);