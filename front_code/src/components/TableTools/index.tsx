import React, { FC, useCallback } from 'react';
import style from './style.less';
import { Input, Tooltip } from 'antd';
import { DownloadOutlined } from '@ant-design/icons';


interface TableToolsProps {
    defaultValue?: string;
    onSearch(value: string): void;
    onExport(): void;
}
const TableTools: FC<TableToolsProps> = ({ defaultValue, onSearch, onExport }) => {
    const handlePressEnter = useCallback((e: React.KeyboardEvent<HTMLInputElement>) => {
        const inputValue = (e.target as HTMLInputElement).value;
        onSearch(inputValue);
    }, []);

    const handleSearch = (value: string) => {
        onSearch(value);
    }

    return (
        <div className={style.container}>
            <Input.Search
                className={style.search} 
                placeholder="Search" 
                onPressEnter={handlePressEnter}
                onSearch={handleSearch}
                defaultValue={defaultValue}
                allowClear
            />
            <Tooltip title="Export as excel">
                <DownloadOutlined className={style.download} onClick={onExport} />
            </Tooltip>
        </div>
    )
}

export default TableTools;