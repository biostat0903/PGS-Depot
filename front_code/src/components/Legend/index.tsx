import React from 'react';
import { InfoCircleOutlined } from '@ant-design/icons';
import style from './style.less';
import { Tooltip } from 'antd';

// @ts-ignore
const Legend = (obj: any) => {
    let config = []
    if (obj.type == 'nonUKBB') {
        config = [
            {
                color: "#DC143C",
                text: "CT",
            }, {
                color: "#228B22",
                text: "DBSLMM",
            }, {
                color: "#556B2F",
                text: "DBSLMM-auto",
            }, {
                color: "#FA8072",
                text: "DBSLMM-lmm",
            }, {
                color: "#4169E1",
                text: "LDpred2-auto",
            }, {
                color: "#87CEEB",
                text: "LDpred2-inf",
            }, {
                color: "#40E0D0",
                text: "LDpred2-nosp",
            }, {
                color: "#EE82EE",
                text: "LDpred2-sp",
            }, {
                color: "#00FF7F",
                text: "PRS-CS",
            }, {
                color: "#4682B4",
                text: "SBLUP",
            }, {
                color: "#FF6347",
                text: "SCT",
            },
        ];
    } else {
        config = [ 
            {
                color: "#556B2F",
                text: "DBSLMM-auto",
            }, {
                color: "#FA8072",
                text: "DBSLMM-lmm",
            }, {
                color: "#4169E1",
                text: "LDpred2-auto",
            }, {
                color: "#87CEEB",
                text: "LDpred2-inf",
            }, {
                color: "#00FF7F",
                text: "PRS-CS",
            }, {
                color: "#4682B4",
                text: "SBLUP",
            },
        ];
    }
    if (obj.methods) {
        // @ts-ignore
        let newConfig = []
        config.forEach(item => {
            if (obj.methods.indexOf(item.text) >= 0) {
                newConfig.push(item)
            }
        })

        // @ts-ignore
        config = newConfig;
    }


    return (
        <div className={style.container}>
            <div className={style.title}>
                <span>PGS Methods </span>
                {/* <Tooltip title="prompt text">
                    <InfoCircleOutlined />
                </Tooltip> */}
            </div>
            <div className={style.content}>
                {
                    config.map(({ color, text }) => (
                        <div className={style.item_wrapper} key={text}>
                            <div className={style.color} style={{ backgroundColor: color}}></div>
                            <div className={style.text} >{text}</div>
                        </div>
                    ))
                }
            </div>
        </div>
    )
}

export default Legend;