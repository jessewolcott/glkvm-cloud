<!--
 * @Author: shufei.han
 * @Date: 2025-06-11 16:53:52
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-20 10:55:56
 * @FilePath: /kvm-cloud-frontend/src/components/base/basePagination.vue
 * @Description: 基础的分页组件
-->
<template>
    <Pagination size="small" v-bind="props" @change="handleChange" showLessItems></Pagination>
</template> 

<script setup lang="ts">
import { Pagination, type PaginationProps } from 'ant-design-vue'

const props = defineProps<PaginationProps>()
const emit = defineEmits<{ (e: 'update:current', value: number): void  }>()

const handleChange = (page: number) => {
    emit('update:current', page)
}

</script> 

<style lang="scss" scoped>
:deep(.ant-pagination-item), :deep(.ant-pagination-jump-next), :deep(.ant-pagination-jump-prev) {
    margin-inline-end: unset;
    border-radius: unset;
    border: 1px solid var(--gl-color-line-border1);
    border-right: unset;
    min-width: 42px;

    a {
        color: var(--gl-color-text-level2);
    }
}

:deep(.ant-pagination-item):not(.ant-pagination-item-active):hover {
    background-color: var(--gl-color-bg-icon-button-hover);
}

:deep(.ant-pagination-item-active) {
    position: relative;

    &::before {
        content: '';
        position: absolute;
        bottom: 4px;
        left: 50%;
        transform: translate(-50%, 0);

        width: 22px;
        height: 2px;
        border-radius: 1px;
        background-color: var(--gl-color-brand-primary);
    }

    &:hover {
        border-color: var(--gl-color-line-border1);
    }

    a {
        color: var(--gl-color-text-level2);
    }
}

:deep(.ant-pagination-prev) {
    margin-inline-end: unset;
    border: 1px solid var(--gl-color-line-border1);
    border-right: unset;
    border-radius: 4px 0 0 4px;
    min-width: 32px;

    .ant-pagination-item-link {
        border-radius: 4px 0 0 4px;

        .anticon {
            color: var(--gl-color-text-level2);
        }
    }

    &:hover {
        .ant-pagination-item-link {
            background-color: var(--gl-color-bg-icon-button-hover);
        }
    }
}

:deep(.ant-pagination-next) {
    border: 1px solid var(--gl-color-line-border1);
    border-radius: 0 4px 4px 0;
    min-width: 32px;

    .ant-pagination-item-link {
        border-radius: 0 4px 4px 0;

        .anticon {
            color: var(--gl-color-text-level2);
        }
    }

    &:hover {
        .ant-pagination-item-link {
            background-color: var(--gl-color-bg-icon-button-hover);
        }
    }
}
</style>