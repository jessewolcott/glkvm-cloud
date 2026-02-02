<!--
 * @Author: LPY
 * @Date: 2025-05-30 15:25:24
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-13 17:21:57
 * @FilePath: /kvm-cloud-frontend/src/views/layout/layContent/layContent.vue
 * @Description: 路由内容集成页
-->
<template>
    <section>
        <router-view v-slot="{ Component }">
            <component :is="Component" />
        </router-view>
    </section>
</template>

<script setup lang="ts">
</script>

<style scoped lang="scss">

</style>