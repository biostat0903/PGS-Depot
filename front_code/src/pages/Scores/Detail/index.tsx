import React, { useCallback, useEffect, useRef, useState } from 'react';
import style from './style.less';
import Legend from '../../../components/Legend';
import PGSDownlod from '../../../components/PGSDownlod';
import TableTools from '../../../components/TableTools';
import { Table, Row, Col } from 'antd';
import { ColumnsType } from 'antd/es/table';
import Echarts from '../../../components/Echarts';
import { DownCircleFilled, DownloadOutlined, FileMarkdownOutlined, FileTextOutlined } from '@ant-design/icons';
import axios from 'axios';
import { API_PREFIX, FTP_PREFIX } from '../../../const';
import { get, capitalize } from 'lodash';
import { useParams } from 'react-router-dom';


interface DataType {
  key: string;
  name: string;
  age: number;
  address: string;
}

interface HeaderType {
  title?: string;
  dataIndex?: string;
  key?: string;
  width?: string;
}

interface FormType {
  efoCode: string;
  efoOntologyTrait?: string;
  traitDesc?: string;
  synonym?: string;
  type?: string;
  cohort?:string;
  traitId?:string;
  population?:string;
  sampleSize?:string;
  pmid?:string;
  reportedTrait?:string;
  numCase?:string;
  numControl?:string;
  methodList?:any[];
}

interface ExtendFile {
  imageList?: any[];
  esteffList?:any[];
  headerList?:any[];
}

const data: DataType[] = [
  {
    key: '1',
    name: 'John Brown',
    age: 32,
    address: 'New York No. 1 Lake Park',
  },
  {
    key: '2',
    name: 'Joe Black',
    age: 42,
    address: 'London No. 1 Lake Park',
  },
  {
    key: '3',
    name: 'Jim Green',
    age: 32,
    address: 'Sydney No. 1 Lake Park',
  },
  {
    key: '4',
    name: 'Jim Red',
    age: 32,
    address: 'London No. 2 Lake Park',
  },
];

const Detail = () => {
  const [form, setForm] = useState<FormType>({efoCode: ''});
  const [extendInfo, setExtendInfo] = useState<ExtendFile>({});
  const {scoreId} = useParams();
  const [data, setData] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [extendTotal, setExtendTotal] = useState(0);
  const [extendPageSize, setExtendPageSize] = useState(10);
  const [loading, setLoading] = useState(false);
  const [extendColumns, setExtendColumns] = useState<any[]>([])

  const columns: ColumnsType<FormType> = [
    {
      title: 'PDID',
      dataIndex: 'traitId',
      key: 'traitId',
      width: '10%',
    },
    {
      title: 'PMID',
      dataIndex: 'pmid',
      key: 'pmid',
      width: '10%',
    },
    {
      title: 'Reported Trait',
      dataIndex: 'reportedTrait',
      key: 'reportedTrait',
      width: '20%',
      render(dom, row) {
        return (
          <span>{capitalize(dom)}</span>
        )
      }
    },
    {
      title: 'Mapped Trait',
      dataIndex: 'mappedTrait',
      key: 'mappedTrait',
      width: '20%',
      render(dom, row) {
        return (
          <span>{capitalize(dom)}</span>
        )
      }
    },
    {
      title: 'EFO Code',
      dataIndex: 'efoId',
      key: 'efoId',
      width: '10%',
    },
    // {
    //   title: 'Ancestry distribution',
    //   dataIndex: 'age',
    //   key: 'age',
    //   width: '20%',
    //   render() {
    //     return (
    //       <div className={style.charts_wrapper}>
    //         <Echarts />
    //         <Echarts />
    //         <Echarts />
    //       </div>

    //     );
    //   }
    // },
    {
      title: 'FTP PGS',
      dataIndex: 'age',
      key: 'age',
      width: '10%',
      render(dom, row) {
        return (
          <FileTextOutlined className={style.file} onClick={() => {
            let path = row.cohort == 'UKBB' ? '/UKBB' : '/nonUKBB';
            path = path + '/' + row.traitId;
            window.open(FTP_PREFIX + path);
          }} />
        );
      }
    },
    {
      title: 'GWAS Summary Statistics Download ',
      dataIndex: 'url',
      key: 'url',
      width: '25%',
      render(dom, row) {
        return (
          <DownloadOutlined className={style.file} onClick={() => {
            let path = row.cohort == 'UKBB' ? '/UKBB' : '/nonUKBB';
            path = path + '/' + row.traitId + '/' + row.traitId + '.txt.gz'; 
            window.open(FTP_PREFIX + path);
          }} />
        );
      }
    }
  ];

  const handleSearch = useCallback(async (value: string) => {
    setLoading(true);
    const result = await axios.get(`${API_PREFIX}/api/score/${scoreId}/detail/page`, {
      params: {
        keyword: value
      }
    });
    setData(get(result.data.data, 'records', []));
    setTotal(get(result.data.data, 'total', 0));
    setLoading(false);
  }, []);

  useEffect(() => {
    (async () => {
      const result = await axios.get(`${API_PREFIX}/api/score/${scoreId}`);
      setForm(get(result.data, 'data', {}));

      handleSearch('')

      const ftpRes = await axios.get(`${API_PREFIX}/api/ftp/${scoreId}/list`);

      const ftpData = ftpRes.data.data;
      if (ftpData && ftpData.headerList && ftpData.headerList.length > 0) {
        const headers: HeaderType[] = [];
        ftpData.headerList.forEach((head: any) => {
          const obj: HeaderType = {
            title: head,
            dataIndex: head,
            key: head,
            width: '10%',
          }
          return headers.push(obj)
        })

        setExtendColumns(headers)
        setExtendTotal(ftpData.esteffList.length)
      }

      setExtendInfo(ftpRes.data.data);
    })();
  }, []);

  let spanSize = 4;
  if (extendInfo.imageList && extendInfo.imageList.length > 0) {
    spanSize = 24/extendInfo.imageList.length;
  }

  // http://localhost:3000/detail?from=Trait&value=10101 路由这样设计
  return (
    <div className={style.container}>
      <div className={style.title}><span>Trait:</span> {form.efoOntologyTrait}</div>
      <Row>
        <Col span={8}>
          <div className={style.information}>
          <table className="table table-bordered table_pgs_h mt-6">
            <tbody>
              <tr>
                <td className="table_title table_title_c" colSpan={2}>
                GWAS Summary Statistics Info
                </td>
              </tr>
              <tr>
                <td>Report Trait</td>
                <td><b><a href="http://www.ebi.ac.uk/efo/EFO_0004329" target="_blank" className="external-link">{capitalize(form.reportedTrait)}</a></b></td>
              </tr>
              <tr>
                <td>EFO Ontology Trait</td>
                <td><b>{capitalize(form.efoOntologyTrait)}</b></td>
              </tr>
              <tr>
                <td>Population</td>
                <td>
                    <span className="more"
                      style={{
                        maxWidth: "100 %",
                        wordBreak: "break-word"
                      }}
                    >{form.population}</span>
                </td>
              </tr>
              <tr><td>Sample Size</td>
                <td className="trait_categories">
                  <div>
                    <span className="trait_colour" ></span>
                    <b>{form.sampleSize}</b>
                  </div>
                </td>
              </tr>
              <tr>
                <td>PMID</td>
                <td>
                  {form.pmid}
                </td>
              </tr>
              <tr>
                <td>Num of Cases</td>
                <td>
                  {form.numCase}
                </td>
              </tr>
              <tr>
                <td>Num of Controls</td>
                <td>
                  {form.numControl}
                </td>
              </tr>
              <tr>
                <td>Publication Links to: </td>
                <td>
                  <a href={'https://pubmed.ncbi.nlm.nih.gov/' + form.pmid}>NCBI</a>
                </td>
              </tr>
              {/* <tr>
                <td>Mapped terms</td>
                <td>
                  <a className="toggle_btn pgs_btn_plus" data-toggle="tooltip" data-placement="right" data-delay="500" id="trait_mapped_terms" title="" data-original-title="Click to show/hide the list of mapped terms"><b>2</b> mapped terms</a>
                  <div className="toggle_list" id="list_trait_mapped_terms">
                    <ul>
                      <li>MeSH:D000428</li>
                      <li>NCIt:C16273</li>
                    </ul>
                  </div>
                </td>
              </tr> */}
            </tbody>
          </table>
        </div>
        </Col>
        <Col span={16}>
        <div className={style.information}>
            <table className="table table-bordered table_pgs_h mt-6" style={{ width: '100%' }}>
          <tbody style={{width: '100%'}}>
            <tr>
              <td className="table_title table_title_c" colSpan={2}>
                Experimental Factor Ontology (EFO) Information
              </td>
            </tr>
            <tr>
              <td>Identifier</td>
              <td><b><a href="http://www.ebi.ac.uk/efo/EFO_0004329" target="_blank" className="external-link">{form.efoCode}</a></b></td>
            </tr>
            <tr>
              <td>Description</td>
              <td>
                    <span
                      className="more"
                      style={{
                        maxWidth: "100 %",
                        wordBreak: "break-word"
                      }}
                    >{form.traitDesc}</span>
              </td>
            </tr>
            <tr><td>Trait category</td>
              <td className="trait_categories">
                    <div style={{
                      maxWidth: "100 %",
                      wordBreak: "break-word"
                    }}>
                  <span className="trait_colour" ></span>
                  <b>{form.type}</b>
                </div>
              </td>
            </tr>
            <tr>
              <td>Synonym</td>
              <td>
                {form.synonym}
              </td>
            </tr>
            <tr>
              <td>Trait Links to: </td>
              <td>
                <a href={form.efoCode.indexOf('EFO:') >= 0 ? 'http://www.ebi.ac.uk/efo/' + form.efoCode.replaceAll(':', '_') : 'http://purl.obolibrary.org/obo/' + form.efoCode.replaceAll(':', '_')}>EFO Trait</a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
        </Col>
      </Row>

      <div className={style.legend_wrapper}>
        <Legend  type={form.cohort} methods={form.methodList} />
        <div className={style.btn_wrap}>
          {
            form.cohort != 'nonUKBB' &&
            <div className={style.download}>
              <a style={{color: 'white'}} href={FTP_PREFIX + '/' + form.cohort + '/' + form.traitId + '/Scores'} target='_blank'>
                <FileTextOutlined className={style.file} onClick={() => {
                // let path = form.cohort + '/' + form.traitId + '/Scores';
                // window.open(FTP_PREFIX + path);
              }}></FileTextOutlined >
              <span>FTP PGS Scores</span>
            </a>
          </div>
          }
          <div className={style.directory}>
            <a style={{color: 'white'}} href={FTP_PREFIX + '/' + form.cohort + '/' + form.traitId + '/Estimated_Effect_Sizes'}  target='_blank'>
              <FileTextOutlined className={style.file} onClick={() => {
                
              }}></FileTextOutlined>
              <span>FTP Estimated Effects</span>
            </a>
          </div>
        </div>
      </div>

      <TableTools onSearch={handleSearch} onExport={() => { }} />

      <Table className={style.table} columns={columns} dataSource={data} bordered loading={loading} pagination={{
        // pageSize: 10,
        total,
        async onChange(page, pageSize) {
          const result = await axios.get(`${API_PREFIX}/api/score/${scoreId}/detail/page`, {
            params: {
              pageNum: page,
              pageSize: pageSize
            }
          });
          setData(get(result.data.data, 'records', []));
          setTotal(get(result.data.data, 'total', 0));
          setLoading(false);
        },
      }}/>

      <div>
          <p style={{fontSize: '18px'}}><b>PGS Download(Choose Population and PGS Methods then click Download)</b></p>
          <PGSDownlod cohort={form.cohort} pdid={scoreId} category='score' type={form.cohort}  methods={form.methodList}/>
      </div>

      <div>
        <p style={{fontSize: '18px'}}><b>Effect Sizes Download(Choose PGS Methods then click Download)</b></p>
        <PGSDownlod cohort={form.cohort} pdid={scoreId} category='effect' type={form.cohort}  methods={form.methodList}/>
      </div>

      <br />

      {
        form.cohort == 'nonUKBB' && extendInfo.imageList && extendInfo.imageList.length > 0 &&
        <Row gutter={4} style={{marginBottom: '20px'}}>
          {
            extendInfo.imageList.map(item => {
              return <Col span={spanSize}>
                <p style={{fontWeight: 'bold', fontSize: '16px'}}>{item.split('.jpeg')[0].replaceAll('_', ' ').replaceAll('boxplot', '').replaceAll('cross', 'Cross').replaceAll('ethnic', 'Ancestry').replace('ASA', 'EAS').replace('in', 'In')}</p>
                <img style={{width: '100%'}} src={FTP_PREFIX + '/nonUKBB/' + form.traitId + '/' + item} />
              </Col>
            })
          }
        </Row>
      }

      {
          extendInfo.esteffList && extendInfo.esteffList.length > 0 &&
          <div>
            <p><b style={{fontSize: '18px'}}>Summary for top significant SNPs across PGS methods</b> <a target='_blank' href={FTP_PREFIX + '/' + form.cohort + '/' + form.traitId + '/' + form.traitId + '_top.esteff'}>Download</a></p>
            <Table className={style.table} columns={extendColumns} dataSource={extendInfo.esteffList} bordered 
            pagination={{
                pageSize: extendPageSize,
                total: extendTotal,
                async onChange(page, pageSize) {
                  setExtendPageSize(pageSize);
                },
              }}
            />
          </div>
      }

    </div>
  );
}

export default Detail;