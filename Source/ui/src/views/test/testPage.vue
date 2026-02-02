<!--
 * @Author: LPY
 * @Date: 2025-05-30 15:35:38
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-20 16:33:26
 * @FilePath: /kvm-cloud-frontend/src/views/test/testPage.vue
 * @Description: 测试页面
-->
<template>
    <BasePage>
        <div style="width: 1700px; height: 600px;background-color: aqua;">
            测试内容{{ route.name }}
        </div>
        <div>版本1.0</div>

        <div class="pagination flex-end items-end">
            <BasePagination
                :total="pagination.total"
                :pageSize="pagination.size"
                v-model:current="pagination.page" />
        </div>
    </BasePage>
</template>

<script setup lang="ts">
import BasePage from '@/components/base/basePage.vue'
import BasePagination from '@/components/base/basePagination.vue'
import { reactive } from 'vue'
import { useRoute } from 'vue-router'
const route = useRoute()

const pagination = reactive({
    total: 100,
    size: 10,
    page: 1,
})
</script>

<style scoped lang="scss">

</style>