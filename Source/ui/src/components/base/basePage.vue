<!--
 * @Author: LPY
 * @Date: 2025-05-30 15:16:20
 * @LastEditors: LPY
 * @LastEditTime: 2025-07-17 17:35:59
 * @FilePath: /kvm-cloud-frontend/src/components/base/basePage.vue
 * @Description: 页面基础布局，所有页面务必使用该布局，如果该组件不能支撑，可以修改该组件进行支撑
-->
<template>
    <BaseBreadcrumb v-if="showBreadCrumb" />
    <div :class="{ 'base-page-wrapper': !full, 'base-page-wrapper-full': full, 'with-breadcrumb': showBreadCrumb }">
        <div class="base-page" :style="basePageStyle">
            <slot />
        </div>
    </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseBreadcrumb from './baseBreadcrumb.vue'
import { useBreadcrumb } from '@/hooks/useBreadcrumb'

const { showBreadCrumb } = useBreadcrumb()

const props = withDefaults(defineProps<{
    full?: boolean
    minWidth?: number
}>(), {
    full: false,
    minWidth: 0,
})

const basePageStyle = computed(() => {
    const minWidth = props.minWidth ? `min-width: ${props.minWidth}px;` : ''
    return minWidth
})
</script>

<style scoped lang="scss">
basePage {
    height: 100%;
    background: var(--gl-color-bg-page);
}
.base-page {
    overflow: auto;
    min-height: 100%;
    height: 100%;
}
.base-page-wrapper{
    padding: 20px;
    @extend basePage;
    .base-page {
        padding: 20px;
        border-radius: 4px;
        background-color: var(--gl-color-bg-surface1);
    }
    &.with-breadcrumb{ 
        height: calc(100% - 38px);
        padding: 16px 20px 20px;
    }
}
.base-page-wrapper-full{
    @extend basePage;
}
</style>