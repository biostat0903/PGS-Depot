import React, { useEffect, useRef } from 'react';
import * as d3 from 'd3';
import { isEqual } from 'lodash';
import style from './style.less'

interface PieChartProps {
  data: { label: string; value: number, children: PieChartProps[] }[];
  onChooseCategory: any
}

const PieChart: React.FC<PieChartProps> = ({ data, onChooseCategory }) => {
  const chartRef = useRef(null);
  const legendRef = useRef(null);
  const legend2Ref = useRef(null);
  const arcRefs = useRef<any>({}); // 引用饼状图路径元素的对象

  useEffect(() => {
    // 绘制饼状图和图例
    drawChart();

    // 组件卸载时清除绘图
    return () => {
      d3.select(chartRef.current).selectAll('*').remove();
      d3.select(legendRef.current).selectAll('*').remove();
    };
  }, [data]);

  const drawChart = () => {
    const width = 340;
    const height = 400;
    const radius = Math.min(width, height) / 2;


    const color = d3.scaleOrdinal(['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b', '#e377c2', 'rgb(0, 102, 153)', '#bcbd22', '#17becf']);

    const arc = d3.arc().outerRadius(radius - 10).innerRadius(0);

    const pie = d3
      .pie<{ label: string; value: number }>()
      .value(d => d.value)
      .sort(null);

    const svg = d3
      .select(chartRef.current)
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .append('g')
      .attr('transform', `translate(${width / 2},${height / 2})`);

    const arcs = svg
      .selectAll('path')
      .data(pie(data))
      .enter()
      .append('path')
      // @ts-ignore
      .attr('d', arc)
      // @ts-ignore
      .attr('fill', (_, i) => color(i))
      .each(function (d) {
        // 将饼状图路径元素绑定到引用对象的相应属性中
        arcRefs.current[d.data.label] = this;
      })
      .on('mouseover', handlePieMouseOver) // 鼠标悬停事件处理程序
      .on('mouseout', handlePieMouseOut); // 鼠标移出事件处理程序

    // 添加标签
    arcs
      .append('text')
      // @ts-ignore
      .attr('transform', d => `translate(${arc.centroid(d)})`)
      .attr('dy', '0.35em')
      .text(d => d.data.label);

    // 创建图例
    const legend = d3
      .select(legendRef.current)
      .append('div')
      .attr('class', 'legend')
      .attr('width', width)
      .attr('height', data.length * 20);

    const legendItems = legend.selectAll('svg').data(data).enter()
      .append('svg')
      .attr('width', width)
      .attr('height', 30)
      .attr('class', 'legend-item')
      .on('mouseover', handleLegendMouseOver)
      .on('mouseout', handleLegendMouseOut)
      .on('click', handleLegendClick);

    legendItems
      .append('rect')
      .attr('width', 18)
      .attr('height', 18)
      // @ts-ignore
      .attr('fill', (_, i) => color(i))
      .attr('transform', (_, i) => `translate(0,4)`);

    legendItems
      .append('text')
      .attr('x', 24)
      .attr('y', 13)
      .attr('dy', '0.35em')
      .text(d => `${d.label} (${d.value})`);

    // 鼠标悬停处理函数
    // @ts-ignore
    function handleLegendMouseOver(_, i) {
      const arcPath = arcRefs.current[i.label];
      d3.select(arcPath).attr('opacity', 0.7);
      // @ts-ignore
      d3.select(this).select('rect').attr('opacity', 0.7);
    }

    // 鼠标移出处理函数
    // @ts-ignore
    function handleLegendMouseOut(_, i) {
      const arcPath = arcRefs.current[i.label];
      d3.select(arcPath).attr('opacity', 1);
      // @ts-ignore
      d3.select(this).select('rect').attr('opacity', 1);
    }

    // @ts-ignore
    function handleLegendClick(e, i) {
      console.log(i, e);
      const target = (() => {
        if ((e.target as HTMLElement).tagName === 'svg') return e.target;
        return (e.target as HTMLElement).parentNode;
      })();
      const fillColor = target.querySelector('rect')?.getAttribute("fill");
      (legend2Ref.current as unknown as HTMLElement).innerHTML = '';
      const legend2 = d3
        .select(legend2Ref.current)
        .append('div')
        .attr('class', 'legend2')
        .attr('width', width)
        .attr('height', data.length * 20);

      legend2.append('div')
        .attr('class', 'legend2-arrow')
        .attr('style', `background-color: ${fillColor}`)
        .append('div')
        .attr('class', 'legend2-arrow-right')
        .attr('style', `border-color: ${fillColor}`);

      const legend2Items = legend2.selectAll('svg').data(i.children).enter()
        .append('svg')
        .attr('width', 500)
        .attr('height', 30)
        .attr('class', 'legend-item')
        .on('click', (item, selected: any) => {
          // refresh data
          onChooseCategory(i.label, selected.label)
        });

      legend2Items
        .append('rect')
        .attr('width', 18)
        .attr('height', 18)
        // @ts-ignore
        .attr('fill', (_, i) => color(i))
        .attr('transform', () => `translate(0,4)`);

      legend2Items
        .append('text')
        .attr('x', 24)
        .attr('y', 13)
        .attr('dy', '0.35em')
         // @ts-ignore
        .text(d => `${d.label}`);
    }

    // 鼠标悬停处理函数
    // @ts-ignore
    function handlePieMouseOver(_, i) {
      const arcPath = arcRefs.current[i.data.label];
      d3.select(arcPath).attr('opacity', 0.7);

      const idx = data.findIndex((item) => isEqual(item, i.data));
      const legendItem = d3.select(legendRef.current).select(`.legend-item:nth-child(${idx + 1})`);
      legendItem.select('rect').attr('opacity', 0.7);
    }

    // 鼠标移出处理函数
    // @ts-ignore
    function handlePieMouseOut(_, i) {
      const arcPath = arcRefs.current[i.data.label];
      d3.select(arcPath).attr('opacity', 1);

      const idx = data.findIndex((item) => isEqual(item, i.data));
      const legendItem = d3.select(legendRef.current).select(`.legend-item:nth-child(${idx + 1})`);
      legendItem.select('rect').attr('opacity', 1);
    }
  };

  return (
    <div className={style.container}>
      <div ref={chartRef}></div>
      <div ref={legendRef} className={style.legend_wrap}></div>
      <div ref={legend2Ref} className={style.legend_wrap}></div>
    </div>
  );
};

export default PieChart;
