<!--
 * @Author: shufei.han
 * @Date: 2025-06-11 10:20:41
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-20 16:31:12
 * @FilePath: /kvm-cloud-frontend/src/components/base/baseSearchInput.vue
 * @Description: 基础搜索框
-->
<template>
    <div class="search-container">
        <div class="input-wrapper">
            <input
                ref="inputRef"
                type="text"
                class="search-input"
                v-model="value"
                @input="handleInput"
                @keyup.enter="emitSearch"
                @focus="isExpanded = true"
                @blur="handleBlur"
                :placeholder="placeholder"
                :style="{
                    'padding-right': (isExpanded || value) ? '36px' : '0'
                }"
                :class="{ 'is-expanded': isExpanded || value }"
            />
            <div 
                class="search-icon"
                @click="handleIconClick"
                :class="{ 'is-active': isExpanded || value }"
            >
                <BaseSvg name="gl-icon-search" :size="16"/>
            </div>
            <transition name="fade">
                <div 
                    v-if="value && (isExpanded || value)"
                    class="clear-icon"
                    @click="clearInput"
                    @mousedown.prevent
                >
                    <BaseSvg name="gl-icon-circle-xmark-solid" />
                </div>
            </transition>
        </div>
    </div>
</template>

<script setup lang="ts">
import { debounce } from 'gl-web-main'
import { ref } from 'vue'

const props = withDefaults(defineProps<{
    placeholder?: string
    width?: string
}>(), {
    width: '200px',
})

const emit = defineEmits(['update:value', 'search'])
const inputRef = ref<HTMLInputElement | null>(null)
const isExpanded = ref(false)

const value = ref('')

const handleInput = (e: Event) => {
    emit('update:value', (e.target as HTMLInputElement).value)
    emitSearch()
}

const emitSearch = debounce(() => {
    emit('search', value.value)
})

const handleBlur = () => {
    if (!value.value) {
        isExpanded.value = false
    }
}

const handleIconClick = () => {
    if (!value.value) {
        inputRef.value?.focus()
    } else {
        emitSearch()
    }
}

const clearInput = () => {
    emit('update:value', '')
    value.value = ''
    emitSearch()
    inputRef.value?.focus()
}
</script>

<style lang="scss" scoped>
.search-container {
  --icon-size: 36px; /* 图标严格36px */
  --input-height: auto; /* 输入框高度不强制 */
  --expanded-width: v-bind('props.width');
  position: relative;
  color: var(--gl-color-text-level2);
}

.input-wrapper {
  position: relative;
  display: inline-block;
}

.search-input {
  /* 完全重置输入框样式 */
  all: unset;
  box-sizing: border-box;
  
  /* 尺寸控制 */
  width: var(--icon-size); /* 初始宽度=图标宽度 */
  height: var(--input-height);
  padding-left: var(--icon-size) !important;
  min-height: var(--icon-size); /* 确保最小高度 */
  
  /* 视觉样式 */
  font-size: 14px;
  background-color: var(--gl-color-bg-white);
  border: 1px solid var(--gl-color-line-border1);
  border-radius: 4px;
  color: inherit;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover,
  &.is-expanded {
    width: var(--expanded-width);
    cursor: text;
  }
}

.search-icon,
.clear-icon {
  /* 严格36px宽度 */
  position: absolute;
  width: var(--icon-size);
  min-width: var(--icon-size); /* 确保不收缩 */
  height: 100%;
  top: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  
  svg {
    width: 20px; /* 图标内容大小 */
    height: 20px;
    flex-shrink: 0;
  }
}

.search-icon {
  left: 0;
  pointer-events: none;
  transition: all 0.3s ease;

  &.is-active {
    pointer-events: all;
    cursor: pointer;
  }
}

.clear-icon {
  right: 0;
  cursor: pointer;
  opacity: 0.6;
  transition: opacity 0.2s ease;

  &:hover {
    opacity: 1;
  }
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
</style>