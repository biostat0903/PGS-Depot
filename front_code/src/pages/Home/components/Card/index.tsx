import React, { FC } from 'react';
import style from "./style.less";

interface Props {
    label: string;
    count: number;
}
const Card: FC<Props> = ({ label, count }) => {
    return (
        <div className={style.container}>
            <div className={style.label}>{label}</div>
            <div className={style.value}>{`${count}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}</div>
        </div>
    );
}

export default Card;