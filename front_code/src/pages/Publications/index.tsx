import React, { useCallback, useEffect, useRef, useState } from 'react';
import { InputRef } from 'antd';
import { Button, Input, Space, Table } from 'antd';
import type { ColumnsType, ColumnType } from 'antd/es/table';
import type { FilterConfirmProps } from 'antd/es/table/interface';
import { SearchOutlined } from '@ant-design/icons';
import style from './style.less';
import TableTools from '../../components/TableTools';
import { getData } from './services';
import axios from 'axios';
import { API_PREFIX } from '../../const';
import { get } from 'lodash';
import { useSearchParams } from 'react-router-dom';

interface DataType {
  key: string;
  name: string;
  age: number;
  address: string;
  pmid: string;
}

interface SearchType {
  pageNum?:number;
  pageSize?:number;
  keyword?:string;
  orderBy?:string;
  orderDirection?:string;
}

type DataIndex = keyof DataType;


const Home = () => {
  const [searchText, setSearchText] = useState('');
  const [searchedColumn, setSearchedColumn] = useState('');
  const searchInput = useRef<InputRef>(null);

  const [data, setData] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);

  const handleSearch = (
    selectedKeys: string[],
    confirm: (param?: FilterConfirmProps) => void,
    dataIndex: DataIndex,
  ) => {
    confirm();
    setSearchText(selectedKeys[0]);
    setSearchedColumn(dataIndex);
  };
  const handleReset = (clearFilters: () => void) => {
    clearFilters();
    setSearchText('');
  };
  const getColumnSearchProps = (dataIndex: DataIndex): ColumnType<DataType> => ({
    filterDropdown: ({ setSelectedKeys, selectedKeys, confirm, clearFilters, close }) => (
      <div style={{ padding: 8 }} onKeyDown={(e) => e.stopPropagation()}>
        <Input
          ref={searchInput}
          placeholder={`Search ${dataIndex}`}
          value={selectedKeys[0]}
          onChange={(e) => setSelectedKeys(e.target.value ? [e.target.value] : [])}
          onPressEnter={() => handleSearch(selectedKeys as string[], confirm, dataIndex)}
          style={{ marginBottom: 8, display: 'block' }}
        />
        <Space>
          <Button
            type="primary"
            onClick={() => handleSearch(selectedKeys as string[], confirm, dataIndex)}
            icon={<SearchOutlined />}
            size="small"
            style={{ width: 90 }}
          >
            Search
          </Button>
          <Button
            onClick={() => clearFilters && handleReset(clearFilters)}
            size="small"
            style={{ width: 90 }}
          >
            Reset
          </Button>
          <Button
            type="link"
            size="small"
            onClick={() => {
              confirm({ closeDropdown: false });
              setSearchText((selectedKeys as string[])[0]);
              setSearchedColumn(dataIndex);
            }}
          >
            Filter
          </Button>
          <Button
            type="link"
            size="small"
            onClick={() => {
              close();
            }}
          >
            close
          </Button>
        </Space>
      </div>
    ),
    filterIcon: (filtered: boolean) => (
      <SearchOutlined style={{ color: filtered ? '#1890ff' : undefined }} />
    ),
    onFilter: (value, record) =>
      record[dataIndex]
        .toString()
        .toLowerCase()
        .includes((value as string).toLowerCase()),
    onFilterDropdownOpenChange: (visible) => {
      if (visible) {
        setTimeout(() => searchInput.current?.select(), 100);
      }
    },
  });
  const columns: ColumnsType<DataType> = [
    {
      title: 'PMID',
      dataIndex: 'pmid',
      key: 'pmid',
      width: '10%',
      render(dom) {
        return (
          <a href={'/#/publications/' + dom}>{dom}</a>
        );
      },
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'PMCID',
      dataIndex: 'pmcid',
      key: 'pmcid',
      width: '10%',
    },
    {
      title: 'Title',
      dataIndex: 'title',
      key: 'title',
      width: '25%',
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'First Author',
      dataIndex: 'firstAuthor',
      key: 'firstAuthor',
      width: '25%',
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    }, {
      title: 'Journal',
      dataIndex: 'journal',
      key: 'journal',
      width: '10%',
    }, {
      title: 'Year',
      dataIndex: 'year',
      key: 'year',
      width: '5%',
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    }, {
      title: 'DOI',
      dataIndex: 'doi',
      key: 'doi',
      width: '25%',
    }, {
      title: 'Associated PGS Scores',
      dataIndex: 'associatedPgsScores',
      key: 'associatedPgsScores',
      width: '25%',
      render(dom, row) {
        return (
          <a href={'/#/publications/' + row.pmid}>{dom}</a>
        )
      }
    },
  ];
  useEffect(() => {
    (async () => {
      setLoading(true);
      const result = await axios.get(`${API_PREFIX}/api/publication/page`, {
        params: {
          keyword: publications || undefined
        }
      });
      setData(get(result.data.data, 'records', []));
      setTotal(get(result.data.data, 'total', 0));
      setLoading(false);
    })();
  }, []);

  const [searchData, setSearchData] = useState<SearchType>({});

  const doSearch = async() => {
    setLoading(true);
    const result = await axios.get(`${API_PREFIX}/api/publication/page`, {
      params: searchData
    });
    setSearchData(searchData);
    setData(get(result.data.data, 'records', []));
    setTotal(get(result.data.data, 'total', 0));
    setLoading(false);
  }

  const handleTableSearch = useCallback(async (value: string) => {
    searchData.keyword = value;
    setSearchData(searchData)
    doSearch()
    // TODO: 1. 调用接口，2.触发table更新
  }, []);
  const handleTableExport = useCallback(() => {
    // TODO: 直接调用接口
    console.log("handleTableExport");
  }, []);

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
    window.open(`${API_PREFIX}/api/publication/export?keyword=${keyword}`, '_blank')
  }

  const [searchParams] = useSearchParams();
  const publications = searchParams.get("publications");

  return (
    <div className={style.container}>
      <div className={style.title}>Publications</div>

      <TableTools
        defaultValue={publications || undefined}
        onSearch={handleTableSearch}
        onExport={doExport}
      />

      <Table 
        className={style.table} 
        columns={columns} 
        dataSource={data} 
        bordered
        onChange={handleTableChange}
        loading={loading} pagination={{
          // pageSize: 10,
          total,
          async onChange(page, pageSize) {
            searchData.pageNum = page
            searchData.pageSize = pageSize
            setSearchData(searchData)
            doSearch()
          },
        }}/>
    </div>
  );
}

export default Home;