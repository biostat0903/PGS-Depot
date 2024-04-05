import React, { useCallback, useEffect, useRef, useState } from 'react';
import style from './style.less';
import Legend from '../../../components/Legend';
import TableTools from '../../../components/TableTools';
import { Table } from 'antd';
import { ColumnsType } from 'antd/es/table';
import Echarts from '../../../components/Echarts';
import { FileTextOutlined } from '@ant-design/icons';
import axios from 'axios';
import { API_PREFIX, FTP_PREFIX } from '../../../const';
import { get } from 'lodash';
import { useParams } from 'react-router-dom';

interface DataType {
  key: string;
  name: string;
  age: number;
  address: string;
}

interface FormType {
  pmid?: string;
  pmcid?: string;
  title?: string;
  authors?: string;
  firstAuthor?: string;
  journal?: string;
  year?: string;
  doi?: string;
  traitId?:string;
  cohort?:string;
  pubDate?: string;
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
  const [form, setForm] = useState<FormType>({});
  const {pmid} = useParams();
  const [data, setData] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);

  const columns: ColumnsType<FormType> = [
    {
      title: 'PDID',
      dataIndex: 'traitId',
      key: 'traitId',
      width: '8%',
      render(dom) {
        return (
          <a href={'/#/scores/' + dom}>{dom}</a>
        );
      }
    },
    {
      title: 'PMID',
      dataIndex: 'pmid',
      key: 'pmid',
      width: '8%',
    },
    {
      title: 'Reported Trait',
      dataIndex: 'reportedTrait',
      key: 'reportedTrait',
      width: '20%',
    },
    {
      title: 'Mapped Trait',
      dataIndex: 'mappedTrait',
      key: 'mappedTrait',
      width: '20%',
    },
    {
      title: 'Population',
      dataIndex: 'population',
      key: 'population',
      width: '6%',
    },
    {
      title: 'Sample Size',
      dataIndex: 'sampleSize',
      key: 'sampleSize',
      width: '6%',
    },
    {
      title: 'Num Case',
      dataIndex: 'numCase',
      key: 'numCase',
      width: '6%',
    },
    {
      title: 'Num Control',
      dataIndex: 'numControl',
      key: 'numControl',
      width: '6%',
    },
    {
      title: 'Cohort',
      dataIndex: 'cohort',
      key: 'cohort',
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
      title: 'Scoring File (FTP Link)',
      dataIndex: 'age',
      key: 'age',
      width: '20%',
      render(r, row) {
        let path = row.cohort == 'UKBB' ? '/UKBB' : '/nonUKBB';
        path = path + '/' + row.traitId;

        return (
          <a href={FTP_PREFIX + path} target='_blank'><FileTextOutlined className={style.file} /></a>
        );
      }
    }
  ];

  const handleSearch = useCallback(async (value: string) => {
    setLoading(true);
    const result = await axios.get(`${API_PREFIX}/api/publication/${pmid}/detail/page`, {
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
      const result = await axios.get(`${API_PREFIX}/api/publication/${pmid}`);
      setForm(get(result.data, 'data', {}));

      handleSearch('')
    })();
  }, []);

  // http://localhost:3000/detail?from=Trait&value=10101 路由这样设计
  return (
    <div className={style.container}>
      <div className={style.title}><span>Publication:</span> {form.title}</div>
      <div className={style.information}>
        <table className="table table-bordered table_pgs_h mt-4">
          <tbody>
            <tr>
              <td className="table_title table_title_c" colSpan={2}>
                Publication Information
              </td>
            </tr>
            <tr>
              <td>PMID</td>
              <td><b><a href="http://www.ebi.ac.uk/efo/EFO_0004329" target="_blank" className="external-link">{form.pmid}</a></b></td>
            </tr>
            <tr>
              <td>First Author</td>
              <td>{form.firstAuthor}</td>
            </tr>
            <tr>
              <td>Authors</td>
              <td>{form.authors}</td>
            </tr>
            <tr>
              <td>Title</td>
              <td>
                <span className="more"
                  style={{
                    maxWidth: "100 %",
                    wordBreak: "break-word"
                  }}
                >{form.title}</span>
              </td>
            </tr>
            <tr><td>Journal</td>
              <td className="trait_categories">
                <div style={{
                  maxWidth: "100 %",
                  wordBreak: "break-word"
                }}>
                  <span className="trait_colour" ></span>
                  {form.journal}
                </div>
              </td>
            </tr>
            <tr>
              <td>Year</td>
              <td>
                {form.year}
              </td>
            </tr>
            <tr>
              <td>Publish Date</td>
              <td>
                {form.pubDate}
              </td>
            </tr>
            <tr>
              <td>DOI</td>
              <td>
                {form.doi}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div className={style.legend_wrapper}>
        <Legend type='nonUKBB' />
      </div>

      <TableTools onSearch={() => { }} onExport={() => { }} />

      <Table className={style.table} columns={columns} dataSource={data} bordered loading={loading} pagination={{
        // pageSize: 10,
        total,
        async onChange(page, pageSize) {
          const result = await axios.get(`${API_PREFIX}/api/publication/${pmid}/detail/page`, {
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

    </div>
  );
}

export default Detail;