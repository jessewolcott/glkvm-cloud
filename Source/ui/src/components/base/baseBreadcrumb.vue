<!--
 * @Author: shufei.han
 * @Date: 2025-06-12 16:03:46
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-20 17:10:43
 * @FilePath: /kvm-cloud-frontend/src/components/base/baseBreadcrumb.vue
 * @Description: 基础的面包屑组件
-->
<template>
    <div class="base-bread-crumb flex-start">
        <template v-for="(item, index) of breadcrumbs"  :key="index">
            <BaseText 
                @click="handleClick(item.pathName, index)" 
                :class="isLatest(index)?'': 'pointer'"
                :variant="isLatest(index) ? 'level1' : 'level2'" >{{ $t(item.title) }}</BaseText>
            <BaseText style="padding: 0 6px;" variant="level2" v-if="index < breadcrumbs.length - 1" >/</BaseText>
        </template>    
    </div>
</template> 

<script setup lang="ts">
import { useBreadcrumb } from '@/hooks/useBreadcrumb'

const { breadcrumbs, isLatest, handleClick } = useBreadcrumb()

</script> 

<style lang="scss" scoped>
.base-bread-crumb {
    padding-left: 24px;
    height: 38px;
    background: var(--gl-color-bg-page);
    padding-top: 16px;
}
</style>