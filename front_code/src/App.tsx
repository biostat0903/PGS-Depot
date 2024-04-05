import React, { useMemo } from 'react';
import { Layout, Menu, Divider } from 'antd';
import { Routes, Route, Link, useLocation } from 'react-router-dom';
import './App.css';
import Home from './pages/Home';
import Scores from './pages/Scores';
import Traits from './pages/Traits';
import Publications from './pages/Publications';
import Search from './pages/Search';
import About from './pages/About';
import Help from './pages/Help';
import Submit from './pages/Submit';
import ScoreDetail from './pages/Scores/Detail';
import PublicationDetail from './pages/Publications/Detail';

const { Header, Content, Footer } = Layout;
const navConfig = [
  {
    key: "Home",
    title: "Home",
    path: "/"
  }, {
    key: "Polygenic Scores",
    title: "PGS",
    path: "/scores/all"
  }, {
    key: "Non UKBB PGS",
    title: "Non UKBB PGS",
    path: "/scores/nonukbb"
  }, {
    key: "Traits",
    title: "Traits",
    path: "/traits"
  }, {
    key: "Publications",
    title: "Publications",
    path: "/publications"
  },
   {
    key: "Search",
    title: "Search",
    path: "/search"
  },
  {
    key: "Submit",
    title: "Submit",
    path: "/submit"
  },
   {
    key: "About",
    title: "About",
    path: "/about"
  },{
    key: "Help",
    title: "Help",
    path: "/help"
  },
];

const App = () => {
  const { pathname } = useLocation();
  const selectedKey = useMemo(() => {
    const target = navConfig.find(({ path }) => path === pathname);
    if (target) return [target.key];
    return [];
  }, [pathname]);
  return (
    <Layout className="layout">
      <Header style={{ backgroundColor: 'rgb(135 89 143)' }}>
        <div className="logo">
          <img src='/images/logo.jpeg' />
        </div>
        <Divider className='divider' />
        <Menu
          style={{ backgroundColor: "rgb(135 89 143)", fontSize: '18px' }}
          theme="dark"
          mode="horizontal"
          className='nav'
          selectedKeys={selectedKey}
          items={navConfig.map(({ key, title, path }) => {
            return {
              key,
              label: <Link to={path}>{title}</Link>,
            };
          })}
        />
        <img src='/images/school.png' style={{width: '283px', height: '63px'}} />
      </Header>

      <Content style={{ padding: '0 50px', minHeight: 'calc(100vh - 128px)' }}>
        <div className="site-layout-content">
          <Routes>
            <Route path="/" element={<Home />}></Route>
            <Route path="/scores/all" element={<Scores />}></Route>
            <Route path="/scores/nonukbb" element={<Scores />}></Route>
            <Route path="/traits" element={<Traits />}></Route>
            <Route path="/scores/:scoreId" element={<ScoreDetail />}></Route>
            <Route path="/publications" element={<Publications />}></Route>
            <Route path="/publications/:pmid" element={<PublicationDetail />}></Route>
            <Route path="/search" element={<Search />}></Route>
            <Route path="/about" element={<About />}></Route>
            <Route path="/help" element={<Help />}></Route>
            <Route path="/submit" element={<Submit />}></Route>
          </Routes>
        </div>
      </Content>

      <Footer
        style={{ width: '100%', textAlign: 'center', color: "#fff", backgroundColor: "rgb(135 89 143)" }}
      >
        
      </Footer>
    </Layout>
  );
};

export default App;