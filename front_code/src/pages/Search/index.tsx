import React, { useRef, useState } from 'react';
import style from './style.less';
import { useNavigate, useSearchParams } from 'react-router-dom';
import Result from './components/Result';
import { Button, Form, FormInstance, Input, Select } from 'antd';
import { debounce, get } from 'lodash';
import axios from 'axios';
import { API_PREFIX } from '../../const';

const Search = () => {
  const ref = useRef(null);
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const onFinish = (values: any) => {
    const population = get(values, "Population");
    const Publication = get(values, "Publication");
    const Cohort = get(values, "Cohort");
    const Trait = get(values, "Trait");
    if (population) {
      navigate(`/scores/all?population=${population}`);
    } else if (Cohort) {
      navigate(`/scores/all?cohort=${Cohort}`);
    } else if (Publication) {
      navigate(`/publications?publications=${Publication}`);
    } else if (Trait) {
      navigate(`/traits?traits=${Trait}`);
    }
  }
  const handleChange = () => {
    // @ts-ignore
    (ref.current as unknown as React.Ref<FormInstance<any>>)?.resetFields(['Population', 'Cohort', 'Publication']);
  };
  const handleChange2 = () => {
    // @ts-ignore
    (ref.current as unknown as React.Ref<FormInstance<any>>)?.resetFields(['Trait', 'Cohort', 'Publication']);
  };
  const handleChange3 = () => {
    // @ts-ignore
    (ref.current as unknown as React.Ref<FormInstance<any>>)?.resetFields(['Trait', 'Population', 'Publication']);
  };
  const handleChange4 = () => {
    // @ts-ignore
    (ref.current as unknown as React.Ref<FormInstance<any>>)?.resetFields(['Trait', 'Population', 'Cohort']);
  };
  const onReset = () => {
    // @ts-ignore
    (ref.current as unknown as React.Ref<FormInstance<any>>)?.resetFields(['Trait', 'Population', 'Cohort', 'Publication']);
  }
  const [data1, setData1] = useState<any[]>([]);
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
  const [data2, setData2] = useState<any[]>([]);
  const onSearch2 = debounce(async (value: string) => {
    const result = await axios.get(`${API_PREFIX}/api/publication/page`, {
      params: {
        keyword: value
      }
    });
    const tmp = (get(result, 'data.data.records', []) as any[]).map(item => {
      return {
        label: get(item, 'title'),
        value: get(item, 'title'),
      }
    });
    setData2(tmp);
    console.log(tmp)
  }, 300);
  return (
    <div className={style.container}>
      {/* <div className={style.title}>Search results for "<span>{searchParams.get('q')}</span>"</div>
      <div className={style.result}>
        All result: 40
      </div>
      <div className={style.list_wrapper}>
        <Result />
        <Result />
        <Result />
      </div> */}
      <Form
        name="basic"
        ref={ref}
        className={style.form}
        labelCol={{ span: 4 }}
        wrapperCol={{ span: 16 }}
        style={{ maxWidth: 600 }}
        initialValues={{ remember: true }}
        onFinish={onFinish}
        // onFinishFailed={onFinishFailed}
        autoComplete="off"
      >
        <div className={style.form_item}>
          <div className={style.form_item_title} >Search By Trait</div>
          <Form.Item
          label={ <p style={{fontSize:"18px"}}>Trait</p> }
            name="Trait"
          >
            <Select
              onChange={handleChange}
              showSearch
              placeholder='eg: rheumatoid arthritis'
              // onChange={onChange}
              options={data1}
              onSearch={onSearch1}
            />
          </Form.Item>
        </div>
        <div className={style.form_item}>
          <div className={style.form_item_title} >Search By Population</div>
          <Form.Item
          label={ <p style={{fontSize:"18px"}}>Population</p> }
            name="Population"
          >
            <Select className={style.select}
              onChange={handleChange2}
              options={[
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
          </Form.Item>
        </div>
        <div className={style.form_item}>
          <div className={style.form_item_title} >Search By Cohort</div>
          <Form.Item
            label={ <p style={{fontSize:"18px"}}>Cohort</p> }
            name="Cohort"
          >
            <Select className={style.select}
              onChange={handleChange3}
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
          </Form.Item>
        </div>
        <div className={style.form_item}>
          <div className={style.form_item_title} >Search By Publication</div>
          <Form.Item
            label={ <p style={{fontSize:"18px"}}>Publication</p> }
            name="Publication"
          >
            <Select showSearch onChange={handleChange4} options={data2} onSearch={onSearch2} placeholder='eg: Biological, clinical and population relevance of 95loci for blood lipids' />
          </Form.Item>
        </div>
        <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
          <Button type="primary" htmlType="submit" className={style.submit}>
            Submit
          </Button>
          <Button
            htmlType="button"
            className={style.reset}
            onClick={onReset}
          >
            Reset
          </Button>
        </Form.Item>
      </Form>
    </div>
  );
};

export default Search;