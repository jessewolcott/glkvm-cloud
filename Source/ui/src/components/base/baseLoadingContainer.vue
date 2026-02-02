<!--
 * @Author: shufei.han
 * @Date: 2025-06-11 14:06:10
 * @LastEditors: shufei.han
 * @LastEditTime: 2025-06-11 14:14:47
 * @FilePath: \kvm-cloud-frontend\src\components\base\baseLoadingContainer.vue
 * @Description: 基础的加载容器
-->
<template>
    <Spin :spinning="spinning" wrapperClassName="base-loading-container" class="base-loading-wrapper">
        <slot></slot>
    </Spin>
</template> 

<script setup lang="ts">
import { Spin } from 'ant-design-vue'

defineProps<{
  spinning: boolean;
}>()
  
</script> 

<style lang="scss" scoped>
.base-loading-container {
    height: 100%;
    :deep(.base-loading-wrapper) {
        max-height: 100%;
    }
    :deep(.ant-spin-container) {
        height: 100%;
    }
}
</style>