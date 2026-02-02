/*
 * @Author: LPY
 * @Date: 2025-06-23 14:18:41
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-23 14:39:57
 * @FilePath: /kvm-cloud-frontend/src/hooks/useSessionStorage.ts
 * @Description: 存储hook
 */
import { ref } from 'vue'

/** 整个系统 */
export enum SessionStorageKeys {
  /** 固件端绑定保存用设备信息 */
  BIND_DEVICE_INFO_KEY = 'bind-device-info',
}

/** 
 * @template T 需要使用的数据类型
 * @param key 需要使用哪种数据
 * @param {T} initValue 如果没有存储，则返回的初始值
*/
export function useSessionStorage <T extends {toString: () => string}> (
    key: SessionStorageKeys,
    initValue: T = null, 
    transform: (value: string) => T = (value) => value as unknown as T,
){

    const storageValue = ref<T>(initValue)
    /** 获取本地存储的值 */
    const getValue = () => {
        const storageData = sessionStorage.getItem(key)
        if (storageData !== null) {
            return transform(storageData)
        }
        else {
            return initValue
        }
    }
    /** 设置本地存储的值 */
    const setValue = (value: T) => {
        sessionStorage.setItem(key, value?.toString())
    }
    /** 清除本地存储的值 */
    const removeValue = () => {
        sessionStorage.removeItem(key)
    }
    /** 初始化 */
    storageValue.value = getValue()

    return {
        getValue,
        setValue,
        removeValue,
        storageValue,
    }
}