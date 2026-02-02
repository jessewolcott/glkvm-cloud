<template>
    <div class="base-icon-button pointer flex">
        <BaseSvg :size="20" variant="level3" :name="icon" />
    </div>
</template> 

<script setup lang="ts">
  
defineProps<{
  icon: string;
}>()

</script> 

<style lang="scss" scoped>
.base-icon-button {
    width: 24px;
    height: 24px;
    border-radius: 3px;
    &:hover {
        background-color: var(--gl-color-bg-icon-button-hover);
    }
    &:active {
        background-color: var(--gl-color-bg-icon-button-active);
    }
}
</style>