/*
 * @Author: shufei.han
 * @Date: 2025-06-13 10:06:28
 * @LastEditors: shufei.han
 * @LastEditTime: 2025-06-13 11:42:27
 * @FilePath: \kvm-cloud-frontend\src\hooks\useDeviceQueue.ts
 * @Description: 自动发现设备队列
 */
import { AnyObject, deepClone, isEmpty } from 'gl-web-main'
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

const DEFAULT_QUEUE_INTERVAL = 400

export function isSameObj (obj1: AnyObject, obj2: AnyObject) {
    return JSON.stringify(obj1) === JSON.stringify(obj2)
}

export function useDeviceQueue<T> (data?: T[], interval: number = DEFAULT_QUEUE_INTERVAL) {
    let timer: number
    const queue = ref<T[]>([])

    const allData = ref<T[]>(deepClone(data))

    const setDataToQueue = () => {
        const data = allData.value[0]
        if (queue.value.find(item => isSameObj(data, item))) {
            allData.value.shift()
            setDataToQueue()
            return
        }
        data && queue.value.push(data)
    }

    const updateData = (data: T[]) => {
        allData.value = deepClone(data)
    }

    onMounted(() => {
        timer = setInterval(() => {
            if (allData.value.length > 0) {
                setDataToQueue()
            }
        }, interval)
    })

    onBeforeUnmount(() => {
        clearInterval(timer)
    })

    const pairedQueue = computed(() => {
        const pairedGroups: T[][] = []
        for (let i = 0; i < queue.value.length; i += 2) {
            // 取出当前元素和下一个元素（若存在）
            const pair = [queue.value[i], queue.value[i + 1]]
            // 过滤掉 undefined（处理奇数个元素的情况）
            pairedGroups.push(pair.filter(item => !isEmpty(item)) as T[])
        }
        return pairedGroups
    })

    return {
        queue,
        allData,
        setDataToQueue,
        updateData,
        pairedQueue,
    }

}