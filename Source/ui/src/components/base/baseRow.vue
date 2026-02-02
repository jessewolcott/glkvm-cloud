<template>
    <div class="base-row display flex-start flex-nowrap flex-column flex-1" :style="computedStyle.outer">
        <div v-for="(outer, index) in computedItems" :key="index" class="row-line full-width" :style="computedStyle.inner">
            <div class="base-col" v-for="(inner, indexInner) of outer" :key="indexInner" >
                <div v-if="inner === EMPTY_ITEM "></div>    
                <slot v-else :data="(inner as T)"></slot>
            </div>
        </div>
    </div>
</template> 

<script setup lang="ts" generic="T">
import { computed } from 'vue'

const EMPTY_ITEM = Symbol('empty_item')

const props = withDefaults(defineProps<{ countPerLine: number; items: T[];  gutter?: number | [number, number] }>(), {
    gutter: 16,
    items: () => [],
})

const computedItems = computed<(T | typeof EMPTY_ITEM)[][]>(() => {
    try {
        const items: T[][] = props.items.reduce((acc, item, index) => {
            const rowIndex = Math.floor(index / props.countPerLine)
            if (!acc[rowIndex]) {
                acc[rowIndex] = []
            }
            acc[rowIndex].push(item)
            return acc
        }, [])
        const lastOuterChildNeeds = props.countPerLine - items[items.length - 1].length 
        if (lastOuterChildNeeds > 0) {
            // 每一行补齐，否则页面显示不整齐
            items[items.length - 1].push(...Array(lastOuterChildNeeds).fill(EMPTY_ITEM))
        }
        return items
    } catch (error) {
        return []
    }
})

const computedStyle = computed(() => { 
    let gutterX:number, gutterY:number
    if (props.gutter instanceof Array) {
        [gutterX, gutterY] = props.gutter
    } else {
        [gutterX, gutterY] = [props.gutter, props.gutter]
    }
    return { outer:  { gap: gutterY + 'px'}, inner:  { gap: gutterX + 'px'} }
})
  
</script> 

<style lang="scss" scoped>
.base-row {
    .row-line {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(0, 1fr));;
        flex: 1;
        .base-col {
            flex: 1;
        }
    }
}
</style>