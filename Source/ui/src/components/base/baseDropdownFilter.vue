<!--
 * @Author: shufei.han
 * @Date: 2025-06-10 16:01:09
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-20 11:51:32
 * @FilePath: /kvm-cloud-frontend/src/components/base/baseDropdownFilter.vue
 * @Description: 基础的下拉框
-->
<template>
    <BaseDropdownSelect v-bind="props" :value="value" @update:value="handleUpdateValue">
        <div class="dropdown-filter pointer bordered flex">
            <BaseText type="body-r" variant="level2" style="margin-left: 6px;">{{ $t('device.status') }}</BaseText>

            <BaseDivider style="height: 100%;" />
            <BaseText class="label">{{ label }}</BaseText>
            <BaseSvg :size="16" class="dropdown-icon arrow" name="gl-icon-chevron-down-regular" />
        </div>
    </BaseDropdownSelect>
</template> 

<script setup lang="ts" generic="T">
import type { SelectOptions } from 'gl-web-main'
import { BaseDivider, BaseDropdownSelect } from 'gl-web-main/components'
import type { Trigger } from 'ant-design-vue/es/dropdown/props'
import { computed } from 'vue'

const props = withDefaults(defineProps<{ options: SelectOptions<T>[]; value: T; trigger?: Trigger }>(), {
    trigger: 'click',
})

const emits = defineEmits<{
    (e: 'update:value', value: T): void;
}>()

const handleUpdateValue = (value: T) => {
    emits('update:value', value)
}

const label = computed(() => { 
    return props.options.find(item => item.value === props.value)?.label
})  
  
</script> 

<style lang="scss" scoped>
.dropdown-filter {
    border-radius: 4px;
    height: 36px;
    .dropdown-icon {
        margin: 0 8px;
    }
    .arrow {
        color: var(--gl-color-text-level3);
    }
    .label {
        white-space: nowrap;
    }
}
</style>

<style>
.base-dropdown-menu {
    padding: 10px !important;
        border-radius: 12px !important;
        background: var(--gl-color-bg-surface1) !important;
        box-shadow: 0px 3px 14px 1px rgba(0, 0, 0, 0.05) !important;
}
</style>