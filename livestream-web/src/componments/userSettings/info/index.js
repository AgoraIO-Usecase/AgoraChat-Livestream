import React, { memo, useState, createRef } from 'react'
import { useSelector } from 'react-redux'
import { Box, InputBase, Typography, MenuItem, FormControl, Select } from "@material-ui/core";
import { makeStyles } from '@material-ui/core/styles';
import i18next from "i18next";
import { updateUserInfo } from '../../../api/userInfo'
import { genderObj } from '../../common/constant'
import TextField from '@mui/material/TextField';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';

const useStyles = makeStyles((theme) => {
    return {
        root:{
            width:"70%",
            padding:"6px 8px"
        },
        infoBox: {
            width: "100%",
            marginTop: "20px",
            borderRadius: "16px",
            background: "#292929",
        },
        borderBox: {
            marginTop: "20px",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            height: "56px",
            borderRadius: "16px",
            background: "#333333",
            padding: "0 20px"
        },
        nameStyle: {
            height: "24px",
            display: "flex",
            justifyContent: "center"
        },
        nameInputBox: {
            width: "100%",
            display: "flex",
            alignItems: "center"
        },
        userTextStyle: {
            fontFamily: "Roboto",
            fontSize: "16px",
            fontWeight: "600",
            lineHeight: "22px",
            letterSpacing: "0px",
            textAlign: "left",
            color: "#FFFFFF"
        },
        inputStyle: {
            width: "100%",
            margin: "0 15px",
            padding: "0 15px",
            border: (props) => (props.nameEditStatus ? "" : "1px solid #FFFFFF"),
            borderRadius: "16px",
        },
        editStyle: {
            fontFamily: "Roboto",
            fontSize: "16px",
            fontWeight: "600",
            lineHeight: "22px",
            letterSpacing: "0px",
            textAlign: "right",
            color: "#FFFFFF",
            cursor: "pointer"
        },
        doneStyle: {
            fontFamily: "Roboto",
            fontSize: "16px",
            fontWeight: "600",
            lineHeight: "22px",
            letterSpacing: "0px",
            textAlign: "right",
            color: "#FFFFFF",
            cursor: "pointer"
        },
        selectStyle: {
            minWidth: "120px",
            background: "#3D3D3D",
            border: "1px solid #3A3A3A",
            borderRadius: "8px",
            padding: "0 8px"
        },
        brithStyle: {
            height: "40px",
            width: "158px",
            background: "#3D3D3D",
            color: "#FFFFFF",
        }
    };
});
const InfoSetting = () => {
    const userInfo = useSelector(state => state?.userInfo) || {};
    const [userAcatar, setUserAcatar] = useState(userInfo?.avatarurl || "");
    const [nameValue, setNameValue] = useState(userInfo?.nickname || "");
    const [nameEditStatus, setNameEditStatus] = useState(true);
    const [genderValue, setGenderValue] = useState(userInfo?.gender || "Male");
    const [value, setValue] = useState(userInfo.brith || '2008-01-01');
    const inputRef = createRef();

    const handleBriChange = (briValue) => {
        setValue(briValue);
        updateUserInfo(userAcatar, nameValue, genderValue, briValue)

    };
    const classes = useStyles({
        nameEditStatus: nameEditStatus
    });

    const handleEditStatus = () => {
        setNameEditStatus(false)
        inputRef.current.focus();
        inputRef.current.click();
    }

    const handleNameChange = (e) => {
        setNameValue(e.target.value)
    }

    const handleGenderChange = (e) => {
        setGenderValue(e.target.value);
        console.log('handleGenderChange>>>', e.target.value);
        updateUserInfo(userAcatar, nameValue, e.target.value)
    }

    const handleUpdateUserInfo = () => {
        updateUserInfo(userAcatar, nameValue, genderValue)
        setNameEditStatus(true);
    }

    const rendernameEditStatus = () => {
        return <>
            {nameEditStatus ? (
                <Typography
                    className={classes.editStyle}
                    onClick={handleEditStatus}
                >
                    {i18next.t("Edit")}
                </Typography>
            ) : (
                <Typography className={classes.doneStyle}
                    onClick={() => {
                        handleUpdateUserInfo()
                    }}>
                    {i18next.t("Done")}
                </Typography>
            )}
        </>
    }


    return (
        <Box className={classes.root}>
            <Box className={classes.borderBox}>
                <Box className={classes.nameInputBox}>
                    <Typography className={classes.userTextStyle}>
                        {i18next.t("UserName")}
                    </Typography>
                    <InputBase
                        ref={inputRef}
                        type="search"
                        max={12}
                        defaultValue={nameValue}
                        disabled={nameEditStatus}
                        onChange={handleNameChange}
                        className={classes.inputStyle}
                        style={{
                            fontFamily: "Roboto",
                            fontSize: "16px",
                            fontWeight: "600",
                            lineHeight: "22px",
                            color: "#FFFFFF",
                            textAlign:"left"
                        }}
                    />
                </Box>
                <Box>
                    {rendernameEditStatus()}
                </Box>
            </Box>
            <Box className={classes.borderBox}>
                <Typography className={classes.userTextStyle}>
                    {i18next.t("Gender")}
                </Typography>
                <Box className={classes.selectStyle}>
                    <FormControl fullWidth>
                        <Select
                            labelId="demo-simple-select-label"
                            id="demo-simple-select"
                            value={genderValue}
                            onChange={handleGenderChange}
                            style={{ color: "#FFFFFF" }}
                        >
                            {Object.keys(genderObj).map((item, i) => {
                                // let isSelected = genderValue === Number(item);
                                return <MenuItem value={i} style={{ display: "flex", justifyContent: "space-between" }}>
                                    <Typography>{i18next.t(genderObj[item].gender)}</Typography>
                                    {/* {isSelected && <img src={tickIcon} alt="" style={{ color: "red" }} />} */}
                                </MenuItem>
                            })}
                        </Select>
                    </FormControl>
                </Box>
            </Box>
            <Box className={classes.borderBox}>
                {/* <BasicDatePicker /> */}
                <Typography className={classes.userTextStyle}>
                    {i18next.t("Birthday")}
                </Typography>
                <LocalizationProvider dateAdapter={AdapterDateFns} >
                    <DatePicker
                        value={value}
                        onChange={handleBriChange}
                        renderInput={(params) => <TextField {...params} className={classes.brithStyle} />}
                    />
                </LocalizationProvider>
            </Box>
        </Box>
    )
}

export default memo(InfoSetting);