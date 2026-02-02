<!--
 * @Author: LPY
 * @Date: 2025-06-11 15:06:48
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-12 14:56:13
 * @FilePath: /kvm-cloud-frontend/src/components/base/baseStep.vue
 * @Description: 步骤条通用组件
-->
<template>
    <div class="base-step-container">
        <div class="step-list">
            <div
                v-for="(item, index) in items"
                :key="index"
                :class="['step-item',getCurrentItemClassNameAndShowIcon(index).className, getPositionClass]"
                :style="{'flex': index === items.length - 1 ? 'unset' : 1}"
            >
                <div class="step-item-title" :style="{'cursor': clickable ? 'pointer': 'unset'}" @click="emits('click', index)">
                    <div class="step-item-title-icon">
                        <div class="step-item-title-icon-content">
                            <BaseSvg v-if="getCurrentItemClassNameAndShowIcon(index).showIcon" name="gl-icon-check-regular" />
                            <span v-else>{{ index + 1 }}</span>
                        </div>
                    </div>
                    <div class="step-item-title-text">
                        {{ (item as any).title }}
                    </div>
                </div>
                <div v-if="index !== items.length - 1" class="step-line" />
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import { computed, watch } from 'vue'
const Props = defineProps({
    // v-model绑定的value
    value: {
        default: 0,
        type: Number,
    },
    // items,数据格式[{title: '1'}, {title: '2'}]
    items: {
        type: Array,
        default: () => [],
        required: true,
    },
    // title的位置,[bottom,right]，需注意如果使用bottom，外面需要设置padding，且paddingBottom在原有基础上增加28px，左右padding基准点为第一个和最后一个小球至侧边缘的距离
    titlePosition: {
        type: String,
        default: 'right',
        validator (titlePosition: 'bottom' | 'right') {
            return ['bottom', 'right'].includes(titlePosition)
        },
    },
    // 是否可以点击选择，默认false
    clickable: {
        type: Boolean,
        default: false,
    },
})

const getCurrentItemClassNameAndShowIcon = (index) => {
    // 判断当前值是否超过了最大值和最小值
    if (index === Props.items.length - 1 && Props.value >= Props.items.length - 1) {
        return { className: 'step-item-current', showIcon: false }
    } else if (index === 0 && Props.value <= 0) {
        return { className: 'step-item-current', showIcon: false }
    }

    if (Props.value < index) {
        return { className: 'step-item-after', showIcon: false }
    } else if (Props.value === index) {
        return { className: 'step-item-current', showIcon: false }
    } else {
        return { className: 'step-item-before', showIcon: true }
    }
}

const getPositionClass = computed(() => {
    if (Props.titlePosition === 'bottom') {
        return 'step-item-position-bottom'
    } else {
        return ''
    }
})

const emits = defineEmits(['input', 'click'])

watch(() => Props.value, () => {
    emits('input', Props.value)
})
</script>

<style lang="scss" scoped>
.base-step-container {
  width: 100%;
  .step-list {
    display: flex;
    align-items: center;
    justify-content: space-between;

    .step-item {
      display: flex;
      align-items: center;

      .step-item-title {
        display: flex;
        align-items: center;

        user-select: none;
        .step-item-title-icon {
          position: relative;

          width: 24px;
          height: 24px;
          font-size: 12px;
          display: flex;
          justify-content: center;
          align-items: center;
          border-radius: 24px;
          background-color: var(--gl-color-brand-primary);
          margin-right: 8px;

          transition: all .3s;

          .step-item-title-icon-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);

            color: var(--gl-color-text-white);

            transition: all .3s;

            span {
              display: block;
              width: 14px;
              height: 14px;
              line-height: 14px;
              text-align: center;
            }
          }
        }

        .step-item-title-text {
          font-size: 14px;
          transition: all .3s;
          white-space: nowrap;
        }
      }

      .step-line {
        flex: 1;
        background-color: var(--gl-color-brand-primary);
        height: 2px;
        border-radius: 1px;
        margin: 0 12px;
        transition: all .3s;
      }
    }

    .step-item.step-item-current {
      .step-item-title-icon {
        background-color: var(--gl-color-brand-primary);
        .step-item-title-icon-content {
          color: var(--gl-color-text-white);
        }
      }
      .step-item-title-text {
        color: var(--gl-color-text-level1);
      }
    }

    .step-item.step-item-before {
      .step-item-title-icon {
        background-color: var(--gl-color-brand-primary);
        .step-item-title-icon-content {
          color: var(--gl-color-text-white);
        }
      }
      .step-item-title-text {
        color: var(--gl-color-text-level1);
      }
      .step-line {
        background-color: var(--gl-color-brand-primary);
      }
    }

    .step-item.step-item-after {
      .step-item-title-icon {
        background-color: var(--gl-color-brand-disabled);
        .step-item-title-icon-content {
          color: var(--gl-color-text-white);
        }
      }
      .step-item-title-text {
        color: var(--gl-color-text-level1);
      }
    }

    .step-item-position-bottom {
      .step-item-title {
        position: relative;

        .step-item-title-icon {
          margin-right: 0;
        }

        .step-item-title-text {
          position: absolute;
          bottom: -28px;
          left: 50%;
          transform: translateX(-50%);
        }
      }
    }
  }
}
</style>