import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { InputRef, Tree } from 'antd';
import { SearchOutlined } from '@ant-design/icons';
import { Button, Input, Space, Table } from 'antd';
import type { ColumnsType, ColumnType } from 'antd/es/table';
import type { FilterConfirmProps } from 'antd/es/table/interface';
import Echarts from './components/Echarts';
import style from './style.less';
import TableTools from '../../components/TableTools';
import axios from 'axios';
import { API_PREFIX } from '../../const';
import { get, capitalize } from 'lodash';
import { useParams, useSearchParams } from 'react-router-dom';

interface DataType {
  key: string;
  name: string;
  age: number;
  address: string;
  traitId?:string;
}

interface TreeLevelType {
  name: string;
  type?:string;
  total: number;
  children: TreeLevelType[];
}

interface SearchType {
  pageNum?:number;
  pageSize?:number;
  keyword?:string;
  orderBy?:string;
  categoryId?:string;
  orderDirection?:string;
  level1?:string;
  level2?:string;
}

type DataIndex = keyof DataType;

interface NodeData {
  id: string;
  name: string;
  parentId: string;
}
interface OriginTreeData extends NodeData {
  children?: NodeData[];
}
const convertTreeData = (params: OriginTreeData[], externalParentId: string): any[] => {
  return params.map(({ id, name, parentId, children }) => {
    return {
      title: name,
      key: `${externalParentId}-${id}`,
      parentId,
      children: children ? convertTreeData(children, `${externalParentId}-${id}`) : [],
    }
  })
}

const convertTreeLevel = (params: TreeLevelType[]): any[] => {
  return params.map(({ total, name, type, children }) => {
    let childs: { label: string; value: number; }[] = []
    if (children) {
      children.forEach(it => {
        childs.push({
          label: it.name,
          value: it.total
        })
      })
    }

    return {
      label: name,
      value: total,
      children: childs,
    }
  })
}


const Home = () => {
  const [searchText, setSearchText] = useState('');
  const [searchedColumn, setSearchedColumn] = useState('');
  const searchInput = useRef<InputRef>(null);

  const [searchData, setSearchData] = useState<SearchType>({});

  const [categoryId, setCategoryId] = useState('');
  const [chartData, setChartData] = useState<any[]>([]);

  const [data, setData] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);

  const [treeData, setTreeData] = useState<any[]>([]);

  const pieData = [
    { label: 'A', value: 40 },
    { label: 'B', value: 20 },
    { label: 'C', value: 30 },
    { label: 'D', value: 10 },
  ];

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

  const refreshChartData = async () => {
    const result = await axios.get(`${API_PREFIX}/api/category/level/list`, {
      params: {
      }
    });

    if (result) {
      const res = convertTreeLevel(result.data.data)
      setChartData(res)
    }
  }

  const doSearch = async() => {
    setLoading(true);
    const result = await axios.get(`${API_PREFIX}/api/efo/page`, {
      params: searchData
    });
    setData(get(result.data.data, 'records', []));
    setTotal(get(result.data.data, 'total', 0));
    setLoading(false);
  }

  const handleChooseCategory =async (level1: string, level2: string) => {
    searchData.categoryId = categoryId
    searchData.level1 = level1
    searchData.level2 = level2;
    setSearchData(searchData)
    doSearch()
  }

  const handleTreeSelect = async (selectedKeys: string[]) => {
    setLoading(true);
    const categoryId = selectedKeys[0] === '0-0' ? '' : selectedKeys[0];
    const paramCategoryId = categoryId ? (() => {
      const id = categoryId.split('-').pop();
      if (id) return id;
      return undefined
    })() : undefined;

    searchData.categoryId = paramCategoryId
    searchData.pageNum = 1
    setSearchData(searchData)

    doSearch()
  }

  const doExport =async () => {
    const keyword = searchData.keyword ? searchData.keyword : ''
    const categoryId = searchData.categoryId ? searchData.categoryId : ''
    const level1 = searchData.level1 ? searchData.level1 : ''
    const level2 = searchData.level2 ? searchData.level2 : ''
    window.open(`${API_PREFIX}/api/efo/export?keyword=${keyword}&categoryId=${categoryId}&level1=${level1}&level2=${level2}`, '_blank')
  }

  // const getColumnSearchProps = (dataIndex: DataIndex): ColumnType<DataType> => ({
  //   filterDropdown: ({ setSelectedKeys, selectedKeys, confirm, clearFilters, close }) => (
  //     <div style={{ padding: 8 }} onKeyDown={(e) => e.stopPropagation()}>
  //       <Input
  //         ref={searchInput}
  //         placeholder={`Search ${dataIndex}`}
  //         value={selectedKeys[0]}
  //         onChange={(e) => setSelectedKeys(e.target.value ? [e.target.value] : [])}
  //         onPressEnter={() => handleSearch(selectedKeys as string[], confirm, dataIndex)}
  //         style={{ marginBottom: 8, display: 'block' }}
  //       />
  //       <Space>
  //         <Button
  //           type="primary"
  //           onClick={() => handleSearch(selectedKeys as string[], confirm, dataIndex)}
  //           icon={<SearchOutlined />}
  //           size="small"
  //           style={{ width: 90 }}
  //         >
  //           Search
  //         </Button>
  //         <Button
  //           onClick={() => clearFilters && handleReset(clearFilters)}
  //           size="small"
  //           style={{ width: 90 }}
  //         >
  //           Reset
  //         </Button>
  //         <Button
  //           type="link"
  //           size="small"
  //           onClick={() => {
  //             confirm({ closeDropdown: false });
  //             setSearchText((selectedKeys as string[])[0]);
  //             setSearchedColumn(dataIndex);
  //           }}
  //         >
  //           Filter
  //         </Button>
  //         <Button
  //           type="link"
  //           size="small"
  //           onClick={() => {
  //             close();
  //           }}
  //         >
  //           close
  //         </Button>
  //       </Space>
  //     </div>
  //   ),
  //   filterIcon: (filtered: boolean) => (
  //     <SearchOutlined style={{ color: filtered ? '#1890ff' : undefined }} />
  //   ),
  //   onFilter: (value, record) =>
  //     record[dataIndex]
  //       .toString()
  //       .toLowerCase()
  //       .includes((value as string).toLowerCase()),
  //   onFilterDropdownOpenChange: (visible) => {
  //     if (visible) {
  //       setTimeout(() => searchInput.current?.select(), 100);
  //     }
  //   },
    // render: (text) =>
    //   searchedColumn === dataIndex ? (
    //     <Highlighter
    //       highlightStyle={{ backgroundColor: '#ffc069', padding: 0 }}
    //       searchWords={[searchText]}
    //       autoEscape
    //       textToHighlight={text ? text.toString() : ''}
    //     />
    //   ) : (
    //     text
    //   ),
  // });

  const columns: ColumnsType<DataType> = [
    {
      title: 'Reporeted Trait',
      dataIndex: 'reportedTrait',
      key: 'reportedTrait',
      width: '25%',
      render(dom, row) {
        return (
          <a href={'/#/scores/' + row.traitId}>{dom}</a>
        );
      },
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'Trait Label',
      dataIndex: 'traitLabel',
      key: 'traitLabel',
      width: '25%',
      render(dom) {
        return (
          <span>{capitalize(dom)}</span>
        );
      },
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'Trait Ontology ID',
      dataIndex: 'traitOntologyId',
      key: 'traitOntologyId',
      width: '15%',
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    },
    {
      title: 'Trait ID',
      dataIndex: 'traitId',
      key: 'traitId',
      width: '15%',
      render(dom) {
        return (
          <a href={'/#/scores/' + dom}>{dom}</a>
        );
      }
    },
    {
      title: 'Population',
      dataIndex: 'population',
      key: 'population',
      width: '10%',
    },
    {
      title: 'Sample Size',
      dataIndex: 'sampleSize',
      key: 'sampleSize',
      width: '20%',
      sorter: true,
      sortDirections: ['descend', 'ascend'],
    },
  ];

  const handleTableChange = (pagination: any, filters: any, sorter: any, extra: any) => {
    console.log('params', pagination, filters, sorter, extra);

    if (sorter && sorter.field) {
      searchData.orderBy = sorter.field;
      searchData.orderDirection = sorter.order == 'descend' ? 'desc' : 'asc'
      doSearch()
    }

  };
  
  useEffect(() => {
    (async () => {
      setLoading(true);
      const [tableResult, treeResult] = await Promise.all([
        axios.get(`${API_PREFIX}/api/efo/page`, {
          params: {
            keyword: traits || undefined
          }
        }),
        axios.get(`${API_PREFIX}/api/category/tree`),
      ]);
      setData(get(tableResult.data.data, 'records', []));
      setTotal(get(tableResult.data.data, 'total', 0));
      setTreeData(() => {
        return convertTreeData([{
          id: '0',
          name: 'All',
          parentId: '0',
          children: get(treeResult, 'data.data', [])
        }], '0')
      });
      setLoading(false);

      refreshChartData()
    })();
  }, []);

  const expandedKeys = useMemo(() => {
    if (!categoryId) return ['0-0'];
    const tmp: string[] = [];
    // @ts-ignore
    (categoryId.split('-') as string[]).reduce((acc, cur) => {
      const result = acc ? `${acc}-${cur}` : cur;
      tmp.push(result);
      return result;
    }, undefined);
    return tmp;
  }, [categoryId]);

  const [searchParams] = useSearchParams();
  const traits = searchParams.get("traits");

  return (
    <div className={style.container}>
      <div className={style.title}>Traits</div>
      <div className={style.legend_wrapper}>
        <Echarts data={chartData} onChooseCategory={handleChooseCategory} />
      </div>
      <p style={{fontSize: '16px', fontWeight: 'bold'}}>Trait Tree</p>
      <div className={style.content_wrap}>
      
        <div className={style.left_tree}>
          <Tree
            expandedKeys={categoryId ? expandedKeys : ['0-0']}
            // defaultSelectedKeys={['0-0-0', '0-0-1']}
            // defaultCheckedKeys={['0-0-0', '0-0-1']}
            onSelect={handleTreeSelect as any}
            treeData={treeData}
          />
        </div>
        <div style={{ width: "100%" }}>
          <TableTools defaultValue={traits || undefined} onSearch={() => { doSearch() }} onExport={() => { doExport() }} />

          <Table className={style.table} columns={columns} dataSource={data} bordered loading={loading} onChange={handleTableChange} pagination={{
            // pageSize: 10,
            total,
            async onChange(page, pageSize) {
              searchData.pageNum = page;
              searchData.pageSize = pageSize
              setSearchData(searchData)

              doSearch()
            },
          }} />
        </div>
      </div>
    </div>
  );
}

export default Home;