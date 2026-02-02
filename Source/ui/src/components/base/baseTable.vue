<!--
 * @Author: shufei.han
 * @Date: 2025-06-12 09:10:43
 * @LastEditors: LPY
 * @LastEditTime: 2025-08-22 15:24:08
 * @FilePath: \glkvm-cloud\web-ui\src\components\base\baseTable.vue
 * @Description: 基础的table组件
-->
<template>
    <Table class="base-table" v-bind="props">
        <template #headerCell="{ column }">
            <span>{{ column.title }}</span>
        </template>
        <template #bodyCell="{ column, record }">
            <template v-for="slotName of slots">
                <slot v-if="slotName === column.dataIndex" :name="(slotName as SlotName)" :column="column" :record="record as T"></slot>
            </template>
            <span v-if="!slots.includes(column.dataIndex.toString())">{{
                parseDefaultValue(record as T, column.dataIndex as string)
            }}</span>
        </template>
    </Table>
</template> 

<script setup lang="ts" generic="T extends BaseData" >
import type { BaseTableProps } from '@/models/component'
import { isEmpty, type BaseData } from 'gl-web-main'
import { Table } from 'ant-design-vue'
import { useSlots } from 'vue'

const props = withDefaults(defineProps<BaseTableProps<T>>(), {
    pagination: false,
    showHeader: true,
    size: 'middle',
})

const slotObject = useSlots()
const slots = (Object.keys(slotObject))

type SlotName = keyof (T & { action: any })

const parseDefaultValue = (record: T, dataIndex: string) => {
    const dataIndexArr = dataIndex.split('.')
    let result = record
    dataIndexArr.forEach((element) => {
        if (result) {
            result = result[element]
        }
    })
    if (isEmpty(result)) {
        return '-'
    }
    return result
}
</script> 

<style lang="scss">

</style>