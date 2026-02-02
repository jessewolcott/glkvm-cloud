/*
 * @Author: shufei.han
 * @Date: 2025-06-10 16:46:00
 * @LastEditors: LPY
 * @LastEditTime: 2025-08-26 17:18:56
 * @FilePath: \glkvm-cloud\web-ui\src\stores\modules\device.ts
 * @Description: 设备有关的状态管理
 */
import { getDeviceListApi } from '@/api/device'
import { type DeviceInfo, type DeviceQuery } from '@/models/device'
import { PageLink } from 'gl-web-main'
import { defineStore } from 'pinia'
import { computed, reactive, ref, watch } from 'vue'

/** 轮训获取设备列表的间隔时间 10s */
const GET_DEVICE_POLLING_INTERVAL = 10 * 1000
/** 轮训获取设备列表的定时器 */
let getDeviceListTimer: number
let pollingEnable = false

const DEVICE_VIEW_PAGE_SIZE = 20

export const useDeviceStore = defineStore('device', () => {
    const state = reactive({
        /** 设备列表 */
        deviceList: [] as DeviceInfo[],
        /** 完整设备列表 */
        completeDeviceList: [] as DeviceInfo[],
        /** 获取设备列表的加载状态 */
        getDeviceLoading: false,
        /** 设备列表的文字搜索 */
        searchText: '',
        /** 这个字段存储是否有设备，因为UI上没有设备和没有筛选出来的设备是对应不同的展示画面的 */
        hasDevice: false,
    })

    const pageLink = ref(new PageLink({ size: DEVICE_VIEW_PAGE_SIZE }))
  
    const handleSearch = (text: string) => {
        state.searchText = text
    }
    /** 计算设备列表的查询条件 */
    const computedDeviceQuery = computed<DeviceQuery>(() => {
        const query: DeviceQuery = {
            searchText: state.searchText?.replaceAll(':','').toLowerCase(),
        }
        return query
    })
    /** 设备列表的分页展示数据 */
    const deviceList= computed<DeviceInfo[]>(() => { 
        try {
            const { page, size } = pageLink.value
            return state.deviceList.slice((page - 1) * size, page * size)
        } catch (error) {
            return []
        }    
    })
    /** 获取设备列表 */
    const getDeviceList = async (isPolling = false, isGetAll = false) => {        
        try {
            console.log('getDeviceList', computedDeviceQuery.value)
            !isPolling && (state.getDeviceLoading = true)
            const res = await getDeviceListApi()
            if (isGetAll) {
                state.hasDevice = res.info.length > 0
            }
            if (res.info.length) {
                state.hasDevice = true
            }
            pageLink.value.setTotal(res.info.length)
            state.deviceList = res.info.filter(d => {
                return d.id.toLowerCase().indexOf(computedDeviceQuery.value.searchText) > -1 
                || d.description.toLowerCase().indexOf(computedDeviceQuery.value.searchText) > -1
            }) || []
            state.completeDeviceList = res.info || []
            !isPolling && (state.getDeviceLoading = false)
        } catch (error) {
            state.deviceList = []
            state.completeDeviceList = []
            pageLink.value.setTotal(0)
            !isPolling && (state.getDeviceLoading = false)
            console.error('Failed to fetch device list:', error)
        }
    }
    /** 设备列表是否有符合条件的展示数据 */
    const hasFilteredDevice = computed(() => {
        return deviceList.value.length > 0
    })
    /** 停止轮询 */
    const stopPolling = () => {
        pollingEnable = false
        getDeviceListTimer && clearTimeout(getDeviceListTimer)
        getDeviceListTimer = null
    }
    /** 轮询设备列表 */
    const startPolling = async () => { 
        stopPolling()
        pollingEnable = true
        getDeviceListTimer = setTimeout(async () => {
            await getDeviceList(true)
            pollingEnable && startPolling()
        }, GET_DEVICE_POLLING_INTERVAL)
    }
    /** 监听设备列表的查询条件变化 */
    watch(computedDeviceQuery, () => {
        getDeviceList()
    })

    return {
        state,
        pageLink,
        deviceList,
        hasFilteredDevice,
        getDeviceList,
        handleSearch,
        startPolling,
        stopPolling,
    }
})