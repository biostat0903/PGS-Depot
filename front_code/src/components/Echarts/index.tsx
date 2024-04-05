import React from 'react';
import ReactECharts from 'echarts-for-react';
import style from './style.less';
import { Tooltip } from 'antd';


const Echarts = () => {
    const option = {
        series: [
            {
                type: 'pie',
                label: {
                    show: true,
                    position: 'center'
                },
                emphasis: {
                    disabled: true
                },
                data: [
                    {
                        value: 335,
                        name: 'A'
                    },
                    {
                        value: 234,
                        name: 'B'
                    },
                    {
                        value: 1548,
                        name: 'C'
                    }
                ],
                radius: ['40%', '70%']
            }
        ]
    };
    return (
        <div className={style.container}>
            <ReactECharts
                className={style.echart}
                option={option}
                style={{ height: 40, width: 40 }}
            />
            <Tooltip title={(
                <div className={style.tooltip_inner}>
                    <div className={style.title}>E - PGS Evaluation</div>
                    <div className={style.legend}>
                        {/* TODO: 传入颜色参数 */}
                        <div>European: 100%</div>
                        <div>European: 100%</div>
                        <div>European: 100%</div>
                    </div>
                    <span className={style.sample}>4 Sample Sets (100%)</span>
                </div>
            )}>
                <span className={style.placeholder}></span>
            </Tooltip>
        </div>
    )
}

export default Echarts;