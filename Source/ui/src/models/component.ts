/*
 * @Author: shufei.han
 * @Date: 2025-06-10 18:36:29
 * @LastEditors: shufei.han
 * @LastEditTime: 2025-06-10 18:37:18
 * @FilePath: \kvm-cloud-frontend\src\models\component.ts
 * @Description: 组件有关的models
 */
import type { SelectOptions } from 'gl-web-main'
import type { TableProps } from 'ant-design-vue'

export interface DropdownGroupItem<T = any> {
  label: string;
  key: string;
  options?: SelectOptions<T>[];
}

export interface BaseTableProps<T> extends TableProps {
  dataSource: T[];
}