import { useRef, useState } from 'react';
import errorImg from '../../assets/images/defaultLive.png';
import { makeStyles } from "@material-ui/core/styles";

const useStyles = makeStyles((theme) => {
  return {
      img: {
          width: '100%',
          height: '100%',
          borderRadius: '12px'
      }
  }
});

export default function Img(props) {
  const classes = useStyles();
  const {
    style = {},
    src = "",
    alt = "",
    errImg = errorImg,
    loadingImg = `https://img1.baidu.com/it/u=2097753014,2835891615&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=281`,
    className
  } = props;
  const imgRef = useRef(null);
  const [error, setError] = useState(false);
  const [neededSrc, setNeededSrc] = useState(loadingImg || src);
  const [random, setRandom] = useState();

  // 加载失败
  const onError = (obj) => {
    setNeededSrc(errorImg);
  }

  // img加载
  const onLoad = (url) => {
    setError(false);
    // 创建一个img标签
    const imgDom = new Image();
    imgDom.src = url;
    imgDom.onload = function () {
      console.log('onload--');
      setNeededSrc(url);
    }
    imgDom.onerror = () => {
      onError({});
    };
  }

  // 加载成功返回渲染
  return (
    <div ref={imgRef} className={className}>
      <img
        className={classes.img}
        style={style}
        src={neededSrc}
        alt={alt}
        onLoad={() => onLoad(props?.src)}
        onError={() => onError({ url: errImg })}
      />
    </div>
  )
}
