<template>
    <div :class="{'flex no-search-result': true, 'full-height': props.fullHeight}">
        <img width="160" :src="noResultSrc" alt="no result">
    </div>
</template> 

<script setup lang="ts">
import noResultSrc from '@/assets/svg/no-search-result.svg'

const props = defineProps<{
    fullHeight?: boolean
}>()

</script> 

<style lang="scss" scoped></style>