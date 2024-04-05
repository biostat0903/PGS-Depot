// @ts-nocheck

import {useState, useCallback} from 'react';
import { InfoCircleOutlined } from '@ant-design/icons';
import { Checkbox, Row, Col, Button, message } from 'antd';
import style from './style.less';
import { Tooltip } from 'antd';
import {styled, css} from 'styled-components';
import axios from 'axios';
import { API_PREFIX, FTP_PREFIX } from '../../const';
import { get, capitalize } from 'lodash';

interface CheckboxProps {
    backgroundColor: string;
}

interface Props {
    pdid?: string;
    type?: string;
    cohort?:string;
    category: string;
    methods?:any[];
}

const CustomCheckbox = styled(Checkbox)<CheckboxProps>`
  ${props =>
    {
        return props.backgroundColor &&
        css`&  .ant-checkbox-checked .ant-checkbox-inner {
            border-color: ${props.backgroundColor};
          }
          .ant-checkbox .ant-checkbox-inner {
            border-color: ${props.backgroundColor};
          }
          .ant-checkbox-wrapper {
            background-color: inherit;
          }
        `
        
    }
}
`;

const PGSDownload = (obj: Props) => {
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

    const methodOptions = ['CT', 'DBSLMM', 'DBSLMM-auto', 'DBSLMM-lmm', 'LDPred2-auto', 'LDpred2-inf', 'LDpred2-nosp', 'LDpred2-sp', 'PRS-CS', 'SBLUP', 'SCT'];
    const populationOptions = ['EUR', 'EAS', 'AFR', 'SAS', 'AMR'];

    const [populations, setPopulations] = useState<any[]>([]);
    const [methods, setMethods] = useState<any[]>([]);
    const [isSelectAll, setIsSelectAll] = useState<any>(false);

    const handleDownload = useCallback(async (type: string) => {
        const result = await axios.post(`${API_PREFIX}/api/ftp/generateFile/check`, {
            type,
              pdid: obj.pdid,
              populations: populations,
              methods: methods,
              cohort: obj.cohort
        });

        if (!result.data.data) {
            message.warning('No file to download')
            return
        }

        const fileResult = await axios.post(`${API_PREFIX}/api/ftp/generateFile`, {
            type,
              pdid: obj.pdid,
              populations: populations,
              methods: methods,
              cohort: obj.cohort
          });

          if (fileResult.data.data) {
            window.open(`${API_PREFIX}/api/ftp/generateFile/${fileResult.data.data}/download`, '_blank')
          } else {
            message.error('No file to download')
          }
      }, [populations, methods]);

    const handleSelectAll = useCallback(async (type?: string) => {
        const methodList = config.map(item => item.text)
        const val = !isSelectAll
        if (val) {
            setPopulations(populationOptions)
            setMethods(methodList)
        } else {
            setPopulations([])
            setMethods([])
        }
        setIsSelectAll(val)
    }, [isSelectAll, config]);

    const handleChange = useCallback(async (type?: string) => {
        // debugger
    });

    return (
        <div className={style.container}>

            {obj.category == 'score' && 
            <Row>
                <Col md={5}>
                    <b>Population</b>
                </Col>
                <Col md={19}>
                    <Checkbox.Group value={populations} onChange={vals => {setPopulations(vals)}} >
                        <Row>
                            <Col span={8} >
                                <CustomCheckbox value="EUR" backgroundColor='blue' >EUR</CustomCheckbox>
                            </Col>
                            <Col span={8} >
                                <CustomCheckbox value="EAS" backgroundColor='red' >EAS</CustomCheckbox>
                            </Col>
                            <Col span={8} >
                                <CustomCheckbox value="AFR" backgroundColor='purple' >AFR</CustomCheckbox>
                            </Col>
                        </Row>
                    </Checkbox.Group>
                </Col>
            </Row>}
            <br />

            <Row>
                <Col md={5}>
                    <b>PGS Methods</b>
                </Col>
                <Col md={19}>
                    <Checkbox.Group value={methods} onChange={vals => setMethods(vals)} >
                        <Row>
                            {
                                config.map(item => {
                                    return <Col span={12}>
                                        <CustomCheckbox key={item.text} value={item.text} onChange={handleChange} backgroundColor={item.color}>{item.text}</CustomCheckbox>
                                    </Col>
                                })
                            }
                        </Row>
                    </Checkbox.Group>
                </Col>
            </Row>
            <br />

            <Button type="primary" style={{backgroundColor: '#398A96', marginBottom: '10px'}} onClick={e => handleDownload(obj.category)}>Download</Button>
            <Button type="primary" style={{backgroundColor: 'rgb(164 164 164)', color: 'black', marginLeft: '10px',}} size='middle' onClick={e => handleSelectAll(obj.type)}>Select all</Button>
        </div>
    )
}

export default PGSDownload;