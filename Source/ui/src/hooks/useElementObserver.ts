import { onMounted, onUnmounted, ref, Ref } from 'vue'

export function useElementObserver (el: Ref<HTMLElement | null>) {
    const width = ref(el.value?.clientWidth)
    const height = ref(el.value?.clientHeight)


    const observer = new ResizeObserver((entries) => {
        width.value = entries[0].contentRect.width
        height.value = entries[0].contentRect.height
    })
    onMounted(() => {
        if (el.value) {
            observer.observe(el.value)
        }
    })
    onUnmounted(() => {
        if (el.value) {
            observer.unobserve(el.value)
        }
    })

    return {
        width,
        height,
    }
}