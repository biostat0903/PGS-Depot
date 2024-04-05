import React, { useCallback, useEffect, useRef, useState } from 'react';
import { InputRef, Select } from 'antd';
import { SearchOutlined, DownloadOutlined, FileTextOutlined } from '@ant-design/icons';
import { Button, Input, Space, Table } from 'antd';
import type { ColumnsType, ColumnType } from 'antd/es/table';
import type { FilterConfirmProps } from 'antd/es/table/interface';
import axios from 'axios';
import Legend from '../../components/Legend';
import style from './style.less';
import Echarts from '../../components/Echarts/index';
import TableTools from '../../components/TableTools';
import { API_PREFIX, FTP_PREFIX } from '../../const';
import { get, capitalize } from 'lodash';
import { useSearchParams } from 'react-router-dom';

interface DataType {
  key: string;
  code: string;
  pmid: string;
  trait: string;
  sampleSize: string;
  ncase: string;
  ncontrol: string;
  efo: string;
  ukbb: string;
  traitId: string;
  reportedTrait:string;
  cohort: string;
  methodsImg: string;
}

interface SearchType {
  pageNum?:number;
  pageSize?:number;
  type?:string;
  population?:string;
  keyword?:string;
  orderBy?:string;
  orderDirection?:string;
}

type DataIndex = keyof DataType;

const Home = () => {
  const [data, setData] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [searchData, setSearchData] = useState<SearchType>({});
  const [searchParams] = useSearchParams();

  const columns: ColumnsType<DataType> = [
    {
      title: 'PDID',
      dataIndex: 'traitId',
      key: 'traitId',
      width: '6%',
      render(dom) {
        return (
          <a href={'/#/scores/' + dom}>{dom}</a>
        );
      },
      // sorter: (a, b) => a.code.localeCompare(b.code),
      // sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'Reported Trait',
      dataIndex: 'reportedTrait',
      key: 'reportedTrait',
      width: '20%',
      sorter: true,
      sortDirections: ['descend', 'ascend'],
      render(dom, row) {
        return (
          <span>{capitalize(dom)}</span>
        )
      }
    },
    {
      title: 'EFO ID',
      dataIndex: 'efoId',
      key: 'efoId',
      width: '8%',
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'EFO Ontology Trait',
      dataIndex: 'efoOntologyTrait',
      key: 'efoOntologyTrait',
      width: '15%',
      sorter: true,
      sortDirections: ['descend', 'ascend'],
      render(dom, row) {
        return (
          <span>{capitalize(dom)}</span>
        )
      }
      // sorter: (a, b) => a.trait.localeCompare(b.trait),
      // sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'Sample Size',
      dataIndex: 'sampleSize',
      key: 'sampleSize',
      width: '10%',
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'Num Case',
      dataIndex: 'numCase',
      key: 'numCase',
      width: '6%',
      // sorter: (a, b) => a.ncase.localeCompare(b.ncase),
      // sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'Num Control',
      dataIndex: 'numControl',
      key: 'numControl',
      width: '6%',
      // sorter: (a, b) => a.ncontrol.localeCompare(b.ncontrol),
      // sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'Population',
      dataIndex: 'population',
      key: 'population',
      width: '8%',
    },
    {
      title: 'Cohort',
      dataIndex: 'cohort',
      key: 'cohort',
      width: '10%',
      render(dom) {
        return dom || '-'
      }
    },
    {
      title: 'PGS Methods',
      dataIndex: 'gg',
      key: 'gg',
      width: '8%',
      render(dom, row) {
        let jpg = '/images/gene2.jpeg';
        if (row.cohort == 'nonUKBB') {
          jpg = row.methodsImg
        }
        console.log(jpg)
        return (
              <img style={{width: '100px', height: '30px'}} src={jpg} />
        );
      }
    },
    {
      title: 'PMID',
      dataIndex: 'pmid',
      key: 'pmid',
      width: '8%',
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'GWAS Summary Statistics Download ',
      dataIndex: 'url',
      key: 'url',
      width: '25%',
      render(dom, row) {
        return (
          <FileTextOutlined className={style.file} onClick={() => {
            let path = row.cohort == 'UKBB' ? '/UKBB' : '/nonUKBB';
            path = path + '/' + row.traitId + '/' + row.traitId + '.txt.gz'; 
            window.open(FTP_PREFIX + path);
          }} />
        );
      }
    }
  ];

  const isNonUKBB = window.location.href.indexOf('nonukbb') >= 0;

  useEffect(() => {
    (async () => {
      setLoading(true);
      const params = {};
      if (searchParams.get("cohort")) {
        Object.assign(params, {
          type: searchParams.get("cohort")
        })
      }
      if (searchParams.get("population")) {
        Object.assign(params, {
          population: searchParams.get("population")
        })
      }
      const result = await axios.get(`${API_PREFIX}/api/score/page`, {
        params
      });
      setData(get(result.data.data, 'records', []));
      setTotal(get(result.data.data, 'total', 0));
      setLoading(false);

      if (isNonUKBB) {
        handleSelect1('nonUKBB')
      }
    })();
  }, [window.location.href, searchParams]);
  
  const doSearch = async() => {
    setLoading(true);
    const result = await axios.get(`${API_PREFIX}/api/score/page`, {
      params: searchData
    });
    setSearchData(searchData);
    setData(get(result.data.data, 'records', []));
    setTotal(get(result.data.data, 'total', 0));
    setLoading(false);
  }

  const handleSearch = useCallback(async (value?: string, orderBy?: string, direction?: string) => {
    searchData.keyword = value;
    searchData.orderBy = orderBy;
    searchData.orderDirection = direction;

    setSearchData(searchData)
    doSearch()
  }, []);

  const handleSelect1 = async (value: string) => {
    searchData.type = value === "all" ? undefined : value
    setSearchData(searchData)

    doSearch()
  }
  const handleSelect2 = async (value: string) => {
    searchData.population = value === "all" ? undefined : value
    setSearchData(searchData)

    doSearch();
  }

  const handleTableChange = (pagination: any, filters: any, sorter: any, extra: any) => {
    console.log('params', pagination, filters, sorter, extra);

    if (sorter && sorter.field) {
      searchData.orderBy = sorter.field;
      searchData.orderDirection = sorter.order == 'descend' ? 'desc' : 'asc'
      doSearch()
    }

  };

  const doExport =async () => {
    const keyword = searchData.keyword ? searchData.keyword : ''
    const type = searchData.type ? searchData.type : ''
    const population = searchData.population ? searchData.population : ''
    window.open(`${API_PREFIX}/api/score/export?keyword=${keyword}&type=${type}&population=${population}`, '_blank')
  }

  return (
    <div className={style.container}>
      <div className={style.title}>Polygenic Scores</div>

      <div className={style.legend_wrapper}>
        <div className={style.select_wrapper}>
          <div className={style.title2}>
            <span>Filter PGS</span>
            {/* <Tooltip title="prompt text">
                    <InfoCircleOutlined />
                </Tooltip> */}
          </div>
          <div className={style.select_content_wrapper}>
            {
              !isNonUKBB &&
              <div className={style.select_content}>
                <span>List of cohort includes:</span>
                <Select className={style.select}
                    defaultValue={searchParams.get("cohort") || "all"}
                  onChange={handleSelect1}
                  options={[
                    {
                      label: "All Stages combined[UKBB, NON UKBB]",
                      value: "all",
                    },
                    {
                      label: "UKBB",
                      value: "UKBB",
                    },
                    {
                      label: "NON UKBB",
                      value: "nonUKBB",
                    },
                    {
                      label: "BBJ",
                      value: "BBJ",
                    },
                  ]}></Select>
                </div>
            }
            
            <div className={style.select_content}>
              <span>List of populations includes:</span>
              <Select className={style.select} defaultValue={searchParams.get("population") || "all"} onChange={handleSelect2} options={[
                {
                  label: "--",
                  value: "all",
                },
                {
                  label: "European (EUR)",
                  value: "EUR",
                },
                {
                  label: "East Asian (EAS)",
                  value: "EAS",
                },
                {
                  label: "African (AFR)",
                  value: "AFR",
                },
                {
                  label: "South Asian (SAS)",
                  value: "SAS",
                },
                {
                  label: 'American (AMR)',
                  value: 'AMR'
                }
              ]}></Select>
            </div>
          </div>
        </div>
        <Legend type='nonUKBB' />
      </div>

      <TableTools onSearch={handleSearch} onExport={() => { doExport() }} />

      <Table className={style.table} rowKey="code" columns={columns} dataSource={data} bordered loading={loading} onChange={handleTableChange} pagination={{
        // pageSize: 10,
        total,
        async onChange(page, pageSize) {
          searchData.pageNum = page;
          searchData.pageSize = pageSize;
          setSearchData(searchData)
          doSearch()
        },
      }} />
    </div>
  );
}

export default Home;