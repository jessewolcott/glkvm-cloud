<template>
    <div class="svg-box">
        <BaseSvg :name="name" class="svg" style="font-size: 24px;"/>
    </div>
</template> 

<script setup lang="ts">
defineProps<{
    name: string;
}>()

</script> 

<style lang="scss" scoped>
.svg-box {
    width: 40px;
    height: 40px;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 10px;
    background-color: var(--gl-color-brand-disabled);
    .svg {
        display: inline-block;
        font-size: 24px;
        width: 24px;
        height: 24px;
        line-height: 24px;
        color: var(--gl-color-brand-primary);
    }
}
</style>