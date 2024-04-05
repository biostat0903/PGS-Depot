import React, { useRef, useState } from 'react';
import style from './style.less';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Button, Form, FormInstance, Input, Select, UploadProps, Upload, Tooltip, message, Switch, Row, Col } from 'antd';
import { debounce, get } from 'lodash';
import axios from 'axios';
import { API_PREFIX } from '../../const';
import { UploadOutlined, BulbOutlined } from '@ant-design/icons';

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
  const [form] = Form.useForm();
  const [filePath, setFilePath] = useState<any>('');
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

  const handleUpload = async (resp: any) => {
    console.log(resp)
    if (resp.file.status == 'done') {
        setFilePath(resp.fileList[0].response.data)
    }
  }

  if (typeof form.getFieldValue('isPrivate') == 'undefined') {
    form.setFieldValue('isPrivate', 'true');
  }

  const handleSubmit = async (value: any) => {
    const data = form.getFieldsValue()
    const result = await axios.post(`${API_PREFIX}/api/ftp/gwas/submit`, {
        ...data,
        filePath
    });

    if (!result.data.code || result.data.code != 200) {
        message.warning(result.data.message)
        return
    }
    
    message.success('操作成功');
  }

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
        form={form} 
        className={style.form}
        labelCol={{ span: 4 }}
        wrapperCol={{ span: 16 }}
        initialValues={{ remember: true }}
        onFinish={onFinish}
        // onFinishFailed={onFinishFailed}
        autoComplete="off"
      >
        <p style={{fontSize:"15px", fontWeight: 'bold'}}>Step 1: Preparation Ensure your GWAS Summary Statistics data is in *.gz format ready for upload.</p>
        <p style={{fontSize:"15px", fontWeight: 'bold'}}>Step 2: Enter Your Details Start by entering your email address in the "Email Address" field. This is a required field. We will use your email address to track and access your uploaded data, and to contact you regarding your submission.</p>
        <p style={{fontSize:"15px", fontWeight: 'bold'}}>Step 3: Manuscript Information Enter the PMID, Publication Title, and Authors of the associated manuscript in the corresponding fields.</p>
        <p style={{fontSize:"15px", fontWeight: 'bold'}}>Step 4: Enter Data Specifics Provide specifics about your data and submit your own GWAS Summary Statistics. </p><br />
        <div className={style.form_item}>
          <Form.Item
          label={ <p style={{fontSize:"15px"}}>Email Address <span style={{color: 'red'}}>*</span></p> }
          labelCol={{span: 5}}
          tooltip={{title: 'Please enter your email address. This will be used to track and access your uploaded GWAS Summary Statistics data once it has been incorporated into PGS-depot. The maintainers will also use this email address to contact you as necessary regarding your submission.', icon: <BulbOutlined />}}
            name="email"
          >
            <Input placeholder="Please enter your email address. This will be used to track and access your uploaded GWAS Summary Statistics data once it has been incorporated into PGS-depot. The maintainers will also use this email address to contact you as necessary regarding your submission." />
          </Form.Item>
        </div>
        <div className={style.form_item}>
          <Form.Item
          label={ <p style={{fontSize:"15px"}}>PMID</p> }
          labelCol={{span: 5}}
          tooltip={{title: 'Please enter the PMID of the associated manuscript.', icon: <BulbOutlined />}}
            name="pmid"
          >
            <Input placeholder="Please enter the PMID of the associated manuscript." />
          </Form.Item>
        </div>
        <div className={style.form_item}>
          <Form.Item
          label={ <p style={{fontSize:"15px"}}>Publication Title</p> }
          labelCol={{span: 5}}
          tooltip={{title: 'Please enter the title of the associated manuscript.', icon: <BulbOutlined />}}
            name="publicationTitle"
          >
            <Input placeholder="Please enter the title of the associated manuscript." />
          </Form.Item>
        </div>
        <div className={style.form_item}>
          <Form.Item
          label={ <p style={{fontSize:"15px"}}>Authors</p> }
          labelCol={{span: 5}}
          tooltip={{title: 'Please list the authors of the associated manuscript.', icon: <BulbOutlined />}}
            name="authors"
          >
            <Input placeholder="Please list the authors of the associated manuscript." />
          </Form.Item>
        </div>
        <div className={style.form_item}>
          <Form.Item
          label={ <p style={{fontSize:"15px"}}>Trait <span style={{color: 'red'}}>*</span></p> }
          labelCol={{span: 5}}
          tooltip={{title: 'Please enter the name of the trait associated with your GWAS Summary Statistics.', icon: <BulbOutlined />}}
            name="trait"
          >
            <Input placeholder="Please enter the name of the trait associated with your GWAS Summary Statistics." />
          </Form.Item>
        </div>
        <div className={style.form_item}>
          <Form.Item
          label={ <p style={{fontSize:"15px"}}>Sample Size <span style={{color: 'red'}}>*</span></p> }
          labelCol={{span: 5}}
          tooltip={{title: 'Please enter the sample size used in your GWAS Summary Statistics.', icon: <BulbOutlined />}}
            name="sampleSize"
          >
            <Input placeholder="Please enter the sample size used in your GWAS Summary Statistics." />
          </Form.Item>
        </div>
        <div className={style.form_item}>
          <Form.Item
          label={ <p style={{fontSize:"15px"}}>Number of Cases</p> }
          labelCol={{span: 5}}
          tooltip={{title: 'Please enter the number of cases associated with your GWAS Summary Statistics.', icon: <BulbOutlined />}}
            name="nCases"
          >
            <Input placeholder="Please enter the number of cases associated with your GWAS Summary Statistics." />
          </Form.Item>
        </div>
        <div className={style.form_item}>
          <Form.Item
          label={ <p style={{fontSize:"15px"}}>Number of Controls</p> }
          labelCol={{span: 5}}
          tooltip={{title: 'Please enter the number of controls associated with your GWAS Summary Statistics.', icon: <BulbOutlined />}}
            name="nControl"
          >
            <Input placeholder="Please enter the number of controls associated with your GWAS Summary Statistics." />
          </Form.Item>
        </div>
        <div className={style.form_item}>
        <Form.Item
          label={ <p style={{fontSize:"15px"}}>Population</p> }
          labelCol={{span: 5}}
          tooltip={{title: 'Please select the population demographic associated with your GWAS Summary Statistics from the following options.', icon: <BulbOutlined />}}
            name="population"
          >
            <Select className={style.select}
              onChange={handleChange2}
              placeholder='Please select the population demographic associated with your GWAS Summary Statistics from the following options.'
              options={[
                // {
                //   label: "--",
                //   value: "all",
                // },
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
          <div className={style.form_item_title} >GWAS Summary Statistics Info: Please provide identifiers for the following columns.</div>
            <div className={style.form_item}>
                <Form.Item
                    label={ <p style={{fontSize:"15px"}}>SNP Column <span style={{color: 'red'}}>*</span></p> }
                    labelCol={{span: 5}}
                    tooltip={{title: 'Please enter the column name that contains the SNP identifiers (rsID).', icon: <BulbOutlined />}}
                    name="snp"
                >
                    <Input placeholder="Please enter the column name that contains the SNP identifiers (rsID)." />
                </Form.Item>
                <Form.Item
                    label={ <p style={{fontSize:"15px"}}>Effect Allele Column <span style={{color: 'red'}}>*</span></p> }
                    labelCol={{span: 5}}
                    tooltip={{title: 'Please enter the column name that contains the effect allele (listed first, A1).', icon: <BulbOutlined />}}
                    name="a1"
                >
                    <Input placeholder="Please enter the column name that contains the effect allele (listed first, A1)." />
                </Form.Item>
                <Form.Item
                    label={ <p style={{fontSize:"15px"}}>Non-Effect Allele Column <span style={{color: 'red'}}>*</span> </p> }
                    labelCol={{span: 5}}
                    tooltip={{title: 'Please enter the column name that contains the non-effect allele (listed second, A2).', icon: <BulbOutlined />}}
                    name="a2"
                >
                    <Input placeholder="Please enter the column name that contains the non-effect allele (listed second, A2)." />
                </Form.Item>
                <Form.Item
                    label={ <p style={{fontSize:"15px"}}>Beta Column <span style={{color: 'red'}}>*</span></p> }
                    labelCol={{span: 5}}
                    tooltip={{title: 'Please enter the column name that contains the beta values (estimated effect sizes for each SNP).', icon: <BulbOutlined />}}
                    name="beta"
                >
                    <Input placeholder="Please enter the column name that contains the beta values (estimated effect sizes for each SNP)." />
                </Form.Item>
                <Form.Item
                    label={ <p style={{fontSize:"15px"}}>P-Value Column <span style={{color: 'red'}}>*</span> </p> }
                    labelCol={{span: 5}}
                    tooltip={{title: 'Please enter the column name that contains the P-values for each SNP.', icon: <BulbOutlined />}}
                    name="pvalue"
                >
                    <Input placeholder="Please enter the column name that contains the P-values for each SNP." />
                </Form.Item>
                <Row>
                  <Col md={8}>
                    <Form.Item
                        label={ <p style={{fontSize:"15px"}}>Is this data considered private? <span style={{color: 'red'}}>*</span> </p> }
                        labelCol={{span: 18}}
                        tooltip={{title: "If you're submitting data classified as private, the PGS-depot will ensure the data remains confidential. Once the analysis is complete, PGS-depot will send the results directly to the specified email address. Afterward, the submitted data will be permanently deleted from our system, ensuring no retention or potential misuse.", icon: <BulbOutlined />}}
                        name="isPrivate"
                    >
                        <Switch defaultChecked checkedChildren="Yes" unCheckedChildren="No" />
                    </Form.Item>
                  </Col>
                  <Col md={15}>
                    <span style={{color: 'red'}}>If you're submitting data classified as private, the PGS-depot will ensure the data remains confidential. Once the analysis is complete, PGS-depot will send the results directly to the specified email address. Afterward, the submitted data will be permanently deleted from our system, ensuring no retention or potential misuse.</span>
                  </Col>
                </Row>
                <br />
                <Form.Item
                    label={ <p style={{fontSize:"15px"}}>Submit your own GWAS Summary Statistics <span style={{color: 'red'}}>*</span> </p> }
                    labelCol={{span: 8}}
                    tooltip={{title: 'Please upload your GWAS summary statistics data in *.gz format. ', icon: <BulbOutlined />}}
                    name="filePath"
                >
                    <Upload name='file' maxCount={1} action={API_PREFIX + '/api/ftp/upload'} onChange={info => handleUpload(info)}>
                        <Button icon={<UploadOutlined />}>Please upload your GWAS summary statistics data in *.gz format. </Button>
                    </Upload>
                </Form.Item>
            </div>  
        </div>
        <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
          <Button type="primary" htmlType="submit" className={style.submit} onClick={handleSubmit}>
            Submit
          </Button>
        </Form.Item>
      </Form>
    </div>
  );
};

export default Search;