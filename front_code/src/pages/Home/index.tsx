import React, { useCallback, useState } from 'react';
import { Input, Select, Button } from 'antd';
import { useNavigate } from 'react-router-dom';
import Card from "./components/Card";
import Description from "./components/Description";
import style from './style.less';
import { trim } from 'lodash';
import { debounce, get } from 'lodash';
import axios from 'axios';
import { API_PREFIX } from '../../const';
import {FileSearchOutlined} from '@ant-design/icons'

const Home = () => {
    const navigate = useNavigate();
    const handleSearch = useCallback((value: string) => {
        if (trim(value)) {
            navigate(`/traits?traits=${value}`);
        }
    }, []);

    const [data1, setData1] = useState<any[]>([]);
    const [keyword, setKeyword] = useState<string>('');
    const handleChange = useCallback((value: string) => {
        
    }, []);
    const onSearch1 = debounce(async (value: string) => {
        const result = await axios.get(`${API_PREFIX}/api/efo/page`, {
          params: {
            keyword: value
          }
        });
        const tmp = (get(result, 'data.data.records', []) as any[]).map(item => {
          return {
            label: get(item, 'traitLabel'),
            value: get(item, 'traitLabel'),
          }
        });
        setData1(tmp);
      }, 300);
    const handleSelect = useCallback((value: string) => {
        setKeyword(value)
    }, [])

    return (
        <div className={style.container}>
            <div className={style.part_1}>
                <div className={style.title}>The Polygenic Score (PGS) Depot</div>
                <div className={style.subtitle}>A comprehensive database for polygenic score from 11 methods and the prediction performance evaluation.</div>
                <div className={style.search_wrapper}>
                    {/* <Input.Search className={style.search} placeholder="Search the PGS Depot" onSearch={handleSearch} enterButton /> */}
                    <Select
                        className={style.search}
                        onChange={handleChange}
                        showSearch
                        onSelect={handleSelect}
                        placeholder='Search the PGS Depot'
                        options={data1}
                        onSearch={onSearch1}
                    />
                    <Button icon={<FileSearchOutlined />} onClick={e => handleSearch(keyword)} />
                </div>
            </div>

            <div className={style.part_2}>
                <div className={style.title}>Data Summary</div>
                <div className={style.subtitle}>In the latest version of PGS-Depot, you can download and obtain the best performance methods through the following categories:</div>
                <div className={style.card_wrapper}>
                    <a href="/#/scores/all" style={{'color': 'black'}}><Card label='Polygenic Scores' count={34510} /></a>
                    <a href="/#/traits"  style={{'color': 'black'}}><Card label='Traits' count={1564} /></a>
                    <a href="/#/scores/all"  style={{'color': 'black'}}><Card label='Summary Statistics' count={5585} /></a>
                    <a href="/#/scores/all"  style={{'color': 'black'}}><Card label='PGS Methods' count={11} /></a>
                </div>
            </div>

            <div className={style.part_3}>
                <Description
                    title='What is a PGS?'
                    descrition={(
                        <span>
                            The polygenic score (PGS) for a phenotype, in its simplest form, is a <b>weighted summation of the estimated genetic effect sizes</b> across genome-wide single nucleotide polymorphisms (SNPs).
                            <br />
                            PGS are becoming widely applied in research settings for <b>disease risk stratification</b> and are also being adapted in <b>precision medicine</b> to inform clinical decisions for many common diseases and disease-related complex traits.
                        </span>
                    )}
                />
                <Description
                    title='Why we use PGS-Depot?'
                    descrition={(
                        <span>
                            PGS-Depot collects <b>5,585</b> GWAS summary statistics for three ancestries and four categories. 
                            <br />
                            PGS-Depot selects/re-estimates the effect size using <b>11 PGS construction methods in eight popular models</b> on the UK Biobank data (Application Number: 67665) or 503 European individuals from the 1000 Genomes Project. Supported models include CT, DBSLMM, DBSLMM-auto, DBSLMM-LMM, LDpred2-nosp, LDpred2-nosp, LDpred2-sp, LDpred2-nosp, PRS-CS, SBLUP, and SCT.
                            <br />
                            PGS-Depot evaluates the performance of the eight models for 5,385 GWAS summary statistics for <b>both in-ancestry and cross-ancestry</b> applications, based on the UK Biobank data.
                        </span>
                    )}
                />
                <Description
                    title='Download data from PGS-Depot'
                    descrition={(
                        <span>
                            PGS-Depot provides links for users to download summary statistics and the significant loci. 
                            <br />
                            PGS-Depot provides links for users to download results for the 11 PGS methods and their prediction performance using boxplot.
                            <br />
                            PGS-Depot provides the file format consistent with PLINK software (--score function).
                            <br />
                            PGS-Depot uses the FTP to guarantee the large file downloading easily and at speed.
                        </span>
                    )}
                />
                <Description
                    title='Q & A'
                    descrition={(
                        <span>
                            If you have any issues or wish to submit your summary statistics, please contact the PGS-Depot team at Nanjing Medical University (yangsheng@njmu.edu.cn).
                            <br />
                            Related Links: <a href='http://www.pgs-server.com'>PGS-Server</a>: This website includes 12 PGS models and external validation. [PMID: 35193147].
                        </span>
                    )}
                />
            </div>
        </div>
    );
}

export default Home;