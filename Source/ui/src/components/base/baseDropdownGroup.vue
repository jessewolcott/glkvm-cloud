<!--
 * @Author: shufei.han
 * @Date: 2025-05-27 10:00:27
 * @LastEditors: shufei.han
 * @LastEditTime: 2025-06-12 14:12:35
 * @FilePath: \kvm-cloud-frontend\src\components\base\baseDropdownGroup.vue
 * @Description: 基础的下拉框
-->
<template>
    <Dropdown placement="bottomRight" :trigger="props.trigger">
        <slot>
            <div class="dropdown-group pointer bordered flex">
                <BaseSvg :size="20" class="dropdown-icon text-2" name="gl-icon-sort" />
                <BaseDivider style="height: 100%;" />
                <BaseText>{{ displayLabel }}</BaseText>
                <BaseSvg :size="16" class="dropdown-icon arrow" name="gl-icon-chevron-down-regular" />
            </div>
        </slot>
        <template #overlay>
            <Menu class="base-dropdown-group-menu">
                <div v-for="(item, index) of props.options" :key="item.label">
                    <BaseText class="subtitle" variant="level3">{{ item.label }}</BaseText>
                    <RadioGroup v-model:value="state.value[item.key]">
                        <div class="radio-wrapper flex-start" v-for="(option) of item.options" :key="option.label">
                            <Radio style="display: flex;" :value="option.value">
                                <BaseText>{{ option.label }}</BaseText>
                            </Radio>
                        </div>
                    </RadioGroup>
                    <BaseDivider v-if="index < props.options.length - 1" horizontal :gutter="2" />
                </div>     
            </Menu>
        </template>
    </Dropdown>
</template> 

<script setup lang="ts" generic="T extends AnyObject">
import type { DropdownGroupItem } from '@/models/component'
import type { AnyObject } from 'gl-web-main'
import { BaseDivider } from 'gl-web-main/components'
import { Dropdown, Menu, Radio, RadioGroup } from 'ant-design-vue'
import type { Trigger } from 'ant-design-vue/es/dropdown/props'
import { computed, reactive, watch } from 'vue'

const props = withDefaults(defineProps<{
    options: DropdownGroupItem[];
    label: string;
    value?: T; 
    trigger?: Trigger
 }>(), {
    trigger: 'click',
})

const emits = defineEmits<{
  (e: 'update:value', value: T): void
}>()

const initValue = () => {
    const value = {} as T
    props.options.forEach(item => {
        // 添加类型断言确保 key 是 T 的有效属性
        const key = item.key as keyof T
        // 使用可选链安全访问
        value[key] = (props.value?.[key] as T[keyof T]) || undefined
    })
    return value
}

const state = reactive<{value: T}>({
    value: initValue() as T,
})

const displayLabel = computed(() => {
    if (props.label) {
        return props.label
    }
    const fatherOption = props.options[0]
    console.log(fatherOption, props.value)
    return fatherOption?.options.find(item => item.value === props.value[fatherOption.key])?.label
})

watch(() => state.value, (newValue) => {
    emits('update:value', newValue as T)
}, { deep: true })
</script> 

<style lang="scss" scoped>
.base-dropdown-label {
    padding-right: 4px;
}
.base-dropdown-group-menu {
    padding: 10px;
    border-radius: 12px;
    background: var(--gl-color-bg-surface1);
    box-shadow: 0px 3px 14px 1px rgba(0, 0, 0, 0.05);
    max-height: 360px;
    overflow: auto;
    :deep(.ant-dropdown-menu-item)  {
        &:active {
            background-color: var(--gl-color-brand-disabled);
        }
    }
    :deep(.selected) {
        background-color: var(--gl-color-brand-disabled);
        color: var(--gl-color-brand-primary);
    }
    .subtitle {
        padding: 6px;
    }
    .radio-wrapper {
        padding: 0 10px 0 8px;
        height: 36px;
        margin-bottom: 2px;
    }
}
.dropdown-group {
    border-radius: 4px;
    height: 36px;
    .dropdown-icon {
        margin: 0 8px;
    }
    .arrow {
        color: var(--gl-color-text-level3);
    }
}
</style>