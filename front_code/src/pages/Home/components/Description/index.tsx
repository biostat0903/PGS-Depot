import React, { FC, ReactNode } from 'react';
import style from "./style.less";

interface Props {
    title: string;
    descrition: ReactNode;
}
const Card: FC<Props> = ({ title, descrition }) => {
    return (
        <div className={style.container}>
            <div className={style.title}>{title}</div>
            <div className={style.descrition}>
                {descrition}
            </div>
        </div>
    );
}

export default Card;