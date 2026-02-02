<!--
 * @Author: LPY
 * @Date: 2025-07-04 15:55:06
 * @LastEditors: LPY
 * @LastEditTime: 2025-07-04 16:02:11
 * @FilePath: /kvm-cloud-frontend/src/components/base/baseViewChanger.vue
 * @Description: 基础的视图切换组件
-->
<template>
    <div class="base-view-changer bordered flex">
        <Tooltip placement="bottom" :title="$t('device.cardView')">
            <div @click="handleChange(ViewType.CARD)"
                 :class="{'icon-container pointer flex': true, selected: props.value === ViewType.CARD}">
                <BaseSvg :size="16" color="var(--gl-color-text-level3)" name="gl-icon-grid" />
            </div>
        </Tooltip>
        <Tooltip placement="bottom" :title="$t('device.listView')">
            <div  @click="handleChange(ViewType.LIST)"
                  :class="{'icon-container pointer flex': true, selected: props.value === ViewType.LIST}">
                <BaseSvg :size="16" color="var(--gl-color-text-level3)" name="gl-icon-list" />
            </div>
        </Tooltip>
    </div>
</template> 

<script setup lang="ts">
import { ViewType } from 'gl-web-main'
import { Tooltip } from 'ant-design-vue'

const props = withDefaults(defineProps<{
    value: ViewType;
}>(), {
    value: ViewType.CARD,
})

const emits = defineEmits<{
    (e: 'update:value', value: ViewType): void
}>()

const handleChange = (type: ViewType) => {
    if (props.value !== type) {
        emits('update:value', type)
    }
}
  
</script> 

<style lang="scss" scoped>
.base-view-changer {
    height: 36px;
    border-radius: 4px;
    width: 70px;
    gap: 4px;
    .icon-container {
        width: 30px;
        height: 30px;
        border-radius: 3px;
        &.selected {
            background-color: var(--gl-color-brand-background);
            :deep(.gl-icon) {
                color: var(--gl-color-brand-primary);
            }
        }
    }
}
</style>