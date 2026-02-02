<!--
 * @Author: LPY
 * @Date: 2025-06-09 09:51:05
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-24 16:08:26
 * @FilePath: /kvm-cloud-frontend/src/components/base/baseSvg.vue
 * @Description: 基础svg组件
-->
<template>
    <span class="base-icon" :style="{color: props.color, fontSize: props.size + 'px'}">
        <Tooltip v-if="props.tooltip" v-bind="$attrs">
            <template #title>
                <slot></slot>
            </template>
            <svg :class="className" aria-hidden="true">
                <use :xlink:href="`#${props.name}`" />
            </svg>
        </Tooltip>
        <svg v-else :class="className" aria-hidden="true" :color="color">
            <use :xlink:href="`#${props.name}`" />
        </svg>
    </span>
</template>

<script setup lang="ts">
import { Tooltip } from 'ant-design-vue'
import { computed } from 'vue'

const props = withDefaults(defineProps<{
  name: string
  color?: string
  tooltip?: boolean
  primary?: boolean
  error?: boolean
  size?: number
  variant?: 'level1' | 'level2' | 'level3'
}>(),{
    tooltip: false,
    size: 14,
})


const className = computed(() => {
    const classNames = {
        'gl-icon': true,
    }
    if (props.primary) {
        classNames['gl-icon-primary'] = true
    }
    if (props.error) {
        classNames['gl-icon-error'] = true
    }
    if (props.variant) {
        classNames[`text-${props.variant.replace('level', '')}`] = true
    }
    return classNames
})

</script>

<style lang="scss" scoped>
.gl-icon {
    width: 1em;
    height: 1em;
    fill: currentColor;
    overflow: hidden;

    &:focus {
        outline: none !important;
    }
    &.gl-icon-primary {
        fill: var(--gl-color-brand-primary);
    }
    &.gl-icon-error {
        fill: var(--gl-color-error-primary);
    }
}
.base-icon {
    display: inline-flex;
    align-items: center;
}
</style>