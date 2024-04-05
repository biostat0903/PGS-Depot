import React from 'react';
import ReactECharts from 'echarts-for-react';
import style from './style.less';
import { Anchor } from 'antd';

let timer: any;

const Help = () => {
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
      <Anchor
        className={style.anchor}
        items={[
          {
            key: 'How-to-search-for-PGS-Depot',
            href: '/#/about#How to search for PGS-Depot',
            title: 'How to search for PGS-Depot',
          },
          {
            key: 'How-to-use-PGS-Depot',
            href: '/#/about#How to use PGS-Depot',
            title: 'How to use PGS-Depot',
          },
          {
            key: 'How-to-update-PGS-Depot',
            href: '/#/about#How to update PGS-Depot',
            title: 'How to update PGS-Depot',
          },
        ]}
        onClick={handleClick}
      />
      <div>
        <div className={style.section} id="How-to-search-for-PGS-Depot">
          <div className={style.title}>How to search for PGS-Depot</div>
          <div className={style.text}>
            PGS-Depot provides four pages to search for trait. In the PGS and Non UKBB PGS pages, we provided information for ten different properties: PDID, reported trait, experimental factor ontology (EFO) ID, EFO ontology trait, sample size, number of controls, number of cases, population, cohort, PGS methods, and PMID. Specifically, we indicated the suitable methods for constructing PGS. In the Traits page, we listed PDID, reported trait, trait label, trait ontology ID, trait ID, population, and sample size for each trait. We also provided a pie chart to show the proportion of 26 categories. In the Publications page, we presented the PDID, PMCID, title, first author, journal, year and DOI of each publication. These four pages organize PGS according to different aspects, and not only provide searching and sorting functions, but also allow downloading of the summary information for all PGSs.
          </div>
        </div>
        <div className={style.section} id="How-to-use-PGS-Depot">
          <div className={style.title}>How to use PGS-Depot</div>
          <div className={style.text}>
            To find PGS result, users can search from different pages with different querying methods. The presentation of a PGS differs between the non-UKBB cohort and UKBB/BBJ cohort. For the non-UKBB cohort, we provided the following information: (i) summary information for the summary statistics, including report trait, EFO trait, population, sample size, PMID, number of case, number of control, and publication link; (ii) the EFO ID and EFO ontology; (iii) the top 100 significant SNPs; (iv) three boxplots to show the in- and cross-ancestry prediction performance for the 11 PGS models. For the UKBB/BBJ cohort, we provided the first three information. Users can download the SNP effect sizes estimated by 11 methods, scores for EUR, AFR, and EAS populations from 11 methods, and the corresponding summary statistics. The SNP effect size file contains three necessary information: SNP ID, effective allele and effect size, which can be directly used for PLINK.
          </div>
        </div>
        <img className={style.figure} src='/images/help1.jpg' />
        <div className={style.section} id="How-to-update-PGS-Depot">
          <div className={style.title}>How to update PGS-Depot</div>
          <div className={style.text}>
            We provide two ways to update PGS-Depot:
            a) Our group will update PGS-Depot bimonthly. 
            b) If the user would like to submit user’s own summary statistics, user can submit in the Submit page. We required to provide email address, trait, sample size, and summary statistics information (i.e., SNP name, effect allele, non-effect allele, beta, and P-value).
          </div>
        </div>
        <br />
      </div>
    </div>
  );
};

export default Help;