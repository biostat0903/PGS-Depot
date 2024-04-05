import React from 'react';
import ReactECharts from 'echarts-for-react';
import style from './style.less';
import { Anchor } from 'antd';
import {styled, css} from 'styled-components';

let timer: any;

const MyAnchor = styled(Anchor)`
     font-size: 31px;
`;

const About = () => {
  const option = {
    tooltip: {
      trigger: 'item'
    },
    legend: {
      type: 'scroll',
      orient: 'vertical',
      left: 340,
      top: 20,
      bottom: 20,
      selectedMode: false,
      //   data: data.legendData
    },
    series: [
      {
        name: 'Access From',
        type: 'pie',
        radius: [60, 120],
        avoidLabelOverlap: false,
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: false,
            fontSize: 40,
            fontWeight: 'bold'
          }
        },
        left: "-660",
        top: "-80",
        labelLine: {
          show: false
        },
        data: [
          { value: 1803, name: 'disease' },
          { value: 336, name: 'biological process' },
          { value: 209, name: 'experimental process' },
          { value: 762, name: 'other traits' },
          { value: 161, name: 'hematological measurement' },
          { value: 101, name: 'measurement' },
          { value: 240, name: 'anthropometric measurement' },
          { value: 475, name: 'phenotype' },
          { value: 67, name: 'protein measurement' },
          { value: 47, name: 'anatomy basic component' },
          { value: 51, name: 'anatomical entity' },
          { value: 280, name: 'ATC Classification System' },
          { value: 37, name: 'response to stimulus' },
          { value: 43, name: 'protein' },
          { value: 78, name: 'mental or behavioural disorder biomarker' },
          { value: 84, name: 'temporal measurement' },
          { value: 149, name: 'self-reported trait' },
          { value: 58, name: 'bone measurement' },
          { value: 96, name: 'environmental exposure measurement' },
          { value: 62, name: 'organic heterocyclic compound' },
          { value: 63, name: 'chemical entity' },
          { value: 153, name: 'lipid or lipoprotein measurement' },
          { value: 78, name: 'cardiovascular measurement' },
          { value: 64, name: 'vital signs' },
          { value: 33, name: 'behavior' },
          { value: 34, name: 'acid' },
        ]
      }
    ],
  };

  const options1 = {
    grid: { top: 8, right: 8, bottom: 50, left: 60 },
    xAxis: {
      type: 'category',
      name: "Year",
      nameLocation: 'middle',
      nameGap: 25,
      data: ['2007', '2009', '2011', '2013', '2015', '2017', '2019', '2021', '2023'],
    },
    yAxis: {
      type: 'value',
      name: "Number of GWAS Summary Statistics",
      nameLocation: 'middle',
      nameGap: 50,
      nameRotate: 90,
    },
    series: [
      {
        data: [1, 5, 15, 57, 85, 223, 2711, 3128, 5585],
        type: 'line',
      },
    ],
    tooltip: {
      trigger: 'axis',
    },
  };

  const handleClick = (e: any, link: any) => {
    e.preventDefault();
    const t = document.querySelector(`#${(link.title as string).replace(/\s/g, '-')}`) as HTMLElement;
    t.scrollIntoView({ block: 'start', behavior: "smooth" });
    // @ts-ignore
    // clearTimeout(timer as any);
    // ((n: HTMLElement) => {
    //   timer = setTimeout(() => {
    //     n.click();
    //   }, 10);
    // })(e.target as HTMLElement)
  }

  return (
    <div className={style.container}>
      <MyAnchor
        className={style.anchor}
        style={{
          fontSize: '101px'
        }}
        items={[
          {
            key: 'About-PGS-Depot',
            href: '/#/about#About PGS-Depot',
            title: 'About PGS-Depot',
          },
          {
            key: 'Overview-of-the-PGS-Depot-Project',
            href: '/#/about#Overview of the PGS-Depot Project',
            title: 'Overview of the PGS-Depot Project',
          },
          {
            key: 'PGS-Depot',
            href: '/#/about#PGS-Depot',
            title: 'PGS-Depot',
          },
          {
            key: 'Data-Statistics',
            href: '/#/about#Data Statistics',
            title: 'Data Statistics',
          },
          {
            key: 'Distribution-of-Trait-Type',
            href: '/#/about#Distribution of Trait Type',
            title: 'Distribution of Trait Type',
          },
          {
            key: 'Citation',
            href: '/#/about#Citation',
            title: 'Citation',
          },
          {
            key: 'PGS-Depot-Methods',
            href: '/#/about#PGS-Depot-Methods',
            title: 'PGS-Depot Methods',
          },
        ]}
        onClick={handleClick}
      />
      <div>
        <div className={style.section} id="About-PGS-Depot">
          <div className={style.title}>About PGS-Depot</div>
          <div className={style.text}>
            This page introduces basic information about PGS-Depot.
          </div>
          <img className={style.figure} src='/images/document1.jpg' />
        </div>
        <div className={style.section} id="Overview-of-the-PGS-Depot-Project">
          <div className={style.title}>Overview of the PGS-Depot Project</div>
          <div className={style.text}>
            Polygenic Score
            In its simplest form, Polygenic score (PGS) is a weighted summation of the estimated genetic effects of genome-wide single nucleotide polymorphisms (SNPs) on a particular trait or disease. The accurate genetic prediction of complex traits also requires constructing PGSs from genome-wide SNPs.
          </div>
        </div>
        <div className={style.section} id="PGS-Depot">
          <div className={style.title}>PGS-Depot</div>
          <div className={style.text}>
            PGS-Depot is an open database for the published summary statistics, re-estimated effect sizes, and in and cross-ancestry prediction performance evaluation of 11 PGS methods. PGS-Depot collects data for 1,564 traits, including 483 quantitative and 1,081 binary traits, among European and East Asian populations. For traits studied in European populations excluding UK Biobank (UKB) individuals, PGS-Depot uses 50,000 individuals in UKB as the validation set to evaluate the prediction performance of each PGS method. The evaluation replicates the source studies for these traits using the corresponding covariates from UKB. For traits studied in European populations including UK Biobank (UKB) individuals or traits studied using the Biobank of Japan (BBJ), PGS-Depot only re-estimates the effect size using the corresponding reference panel from the 1000 Genomes Project.
          </div>
          <img className={style.figure} src='/images/document2.jpg' />
        </div>

        <div className={style.section} id="PGS-Depot-Methods">
          <div className={style.title}>PGS-Depot Methods</div>
          <div className={style.text}>
            All the code for PGS-Depot is freely available on Github . In this project, we implement 11 PGS methods: DBSLMM-auto, DBSLMM-LMM, LDpred2-auto, LDpred2-inf, PRS-CS, SBLUP, CT, DBSLMM, LDpred2-nosp, LDpred2-sp, and SCT. We apply the first six methods to all summary statistics and provide download links for the SNP effect sizes estimated by these joint models, which can be directly applied to other datasets. Note that each method has different assumptions on the distribution of SNP effect sizes. As a result, different model assumptions result in different prediction performance for different traits. Following (Yang & Zhou, 2022), we classify the summary statistic-based methods into three categories:
            <br />  a) Polygenic assumption: normally distributed effects with a common variance shared across SNPs (e.g. SBLUP and LDpred2), or normally distributed effects with SNP-specific variance (e.g. DBSLMM and PRS-CS).
            <br />  b) Sparse assumption: LDpred2-sp.
            <br />  c) No-model assumption: CT and SCT.
            <br />
            PGS-Depot also evaluates the performance of these methods for estimating cross-ancestry PGS.
          </div>
        </div>

        <div className={style.chart_wrap} id="Data-Statistics">
          <div className={style.title}>Data Statistics</div>
          <ReactECharts
            className={style.echart}
            option={options1}
            onEvents={{
              legendselectchanged(params: any) {
                console.log(params);
                return false;
              }
            }}
            style={{ height: 366, width: 900 }}
          />
        </div>

        <div className={style.section} id="Distribution-of-Trait-Type">
          <div className={style.title}>Distribution of Trait Type</div>
          <div className={style.text}>
            <div className={style.chart_wrap}>
              <ReactECharts
                className={style.echart}
                option={option}
                onEvents={{
                  legendselectchanged(params: any) {
                    console.log(params);
                    return false;
                  }
                }}
                style={{ height: 366, width: 900 }}
              />
            </div>
          </div>
        </div>

        <div className={style.section} id="Citation">
          <div className={style.title}>Citation</div>
          <div className={style.text}>
            PGS-Depot: a comprehensive resource for polygenic score constructed by summary statistics based methods
          </div>
        </div>

        <br />
      </div>
    </div>
  );
};

export default About;