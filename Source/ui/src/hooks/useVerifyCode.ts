/*
 * @Author: shufei.han shufei.han@gl-inet.com
 * @Date: 2024-03-26 10:54:35
 * @LastEditors: shufei.han
 * @LastEditTime: 2025-06-18 10:55:31
 * @FilePath: \kvm-cloud-frontend\src\hooks\useVerifyCode.ts
 * @Description: 发送验证码有关的代码逻辑封装
 */
import { sendPhoneCodeApi, sendEmailCodeApi, sendNewEmailCodeApi,
    reqSendTwoFactorEmailCode as sendEmailForTwoFactor,type SendPhoneCodeParams } from '@/api/user'
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { t } from './useLanguage'

// 发送手机验证码的时间
export const SEND_PHONE_CODE_INTERVAL = 60 * 1000
// 本地存储的发送手机验证码的时间的key
export const SEND_PHONE_CODE_STORAGE_KEY = 'send_phone_code_storage_key'

// 发送邮箱验证码的时间
export const SEND_EMAIL_CODE_INTERVAL = 60 * 1000
// 本地存储的发送邮箱验证码的时间的key
export const SEND_EMAIL_CODE_STORAGE_KEY = 'send_email_code_storage_key'

// 发送邮箱验证码的时间
export const SEND_NEW_EMAIL_CODE_INTERVAL = 60 * 1000
// 本地存储的发送邮箱验证码的时间的key
export const SEND_NEW_EMAIL_CODE_STORAGE_KEY = 'send_new_email_code_storage_key'


export type SEND_CODE_TYPE = 'phone' | 'email' | 'new_email'
// 根据用户传入的type去映射本地存储的key以及对应的interval
const sendTypeArgsMap = new Map<SEND_CODE_TYPE, {key:string, interval:number}>([
    ['email', {key: SEND_EMAIL_CODE_STORAGE_KEY, interval:SEND_EMAIL_CODE_INTERVAL}],
    ['phone', {key: SEND_PHONE_CODE_STORAGE_KEY, interval:SEND_PHONE_CODE_INTERVAL}],
    ['new_email', {key: SEND_NEW_EMAIL_CODE_STORAGE_KEY, interval:SEND_NEW_EMAIL_CODE_INTERVAL}],
])

export default function useVerifyCode (type: SEND_CODE_TYPE = 'phone', useStorage?: boolean) {
    let timer: number

    const latestTime = ref(0)
    const loading = ref(false)
    // 通过传入的type映射出有关数据
    const {key, interval} = sendTypeArgsMap.get(type)

    // 从本地存储拿到数据，然后做判断
    const getStorageTime = () => {
        try {
            const storageValue = parseInt(localStorage.getItem(key))
            if (!storageValue) {
                return 0
            }
            // 上次触发时间
            const lastSendTime = new Date(storageValue).valueOf()
            // 现在的时间
            const nowTime = new Date().valueOf()
            // 判断上次触发到现在是否过了定义的SEND_PHONE_CODE_INTERVAL
            const timeFromLatestEmit = interval - (nowTime - lastSendTime)
            
            const waitTime = Math.round((timeFromLatestEmit) / 1000)
            if (timeFromLatestEmit <= interval) {
                latestTime.value = (waitTime > 0)? waitTime : 0
            }
            
            return latestTime.value
        } catch (error) {
            latestTime.value = 0
            return 0
        }
    }
    // 设置定时器改变时间
    const handleChangeWaitTime = () => {
        timer = setInterval(() => {
            if (latestTime.value > 0) {
                latestTime.value -= 1
            }
        }, 1000 )
    }
    // 计算出能不能点击按钮继续发送
    const sendEnabled = computed(() => {
        return latestTime.value <= 0
    })
    // 调用成功后将这次的调用时间存储到本地
    const setTimeToStorage = () => {
        localStorage.setItem(key, new Date().valueOf().toString())
    }
    // 发送短信验证码
    const sendPhoneCode = async (params: SendPhoneCodeParams) => {
        try {
            loading.value = true
            await sendPhoneCodeApi(params)
            await new Promise((resolve) => {
                setTimeout(() => resolve(1), 1000)
            })
            loading.value = false
            setTimeToStorage()
            getStorageTime()
        } catch (error) { 
            loading.value = false
        }
    }
    // 发送邮箱验证码
    const sendEmailCode = async (email: string) => {
        try {
            loading.value = true
            await sendEmailCodeApi(email)
            await new Promise((resolve) => {
                setTimeout(() => resolve(1), 1000)
            })
            loading.value = false
            setTimeToStorage()
            getStorageTime()
        } catch (error) { 
            loading.value = false
        }
    }
    // 发送新邮箱验证码
    const sendNewEmailCode = async (email: string) => {
        try {
            loading.value = true
            await sendNewEmailCodeApi(email)
            await new Promise((resolve) => {
                setTimeout(() => resolve(1), 1000)
            })
            loading.value = false
            setTimeToStorage()
            getStorageTime()
        } catch (error) { 
            loading.value = false
        }
    }
    // 发送邮箱验证码(两步验证)
    const sendEmailCodeTwoFactor = async (params) => {
        try {
            loading.value = true
            await sendEmailForTwoFactor(params)
            loading.value = false
            setTimeToStorage()
            getStorageTime()
        } catch (error) {
            loading.value = false
        }
    }

    /**
     *
     * @param {'email'|'phone'} type 清除邮箱还是手机号限制
     */
    const clearVerifyCodeTimeout = (type: SEND_CODE_TYPE) => {
        latestTime.value = 0
        if (type === 'email') {
            localStorage.removeItem(SEND_EMAIL_CODE_STORAGE_KEY)
        } else if (type === 'phone') {
            localStorage.removeItem(SEND_PHONE_CODE_STORAGE_KEY)
        } else if (type  === 'new_email'){
            localStorage.removeItem(SEND_NEW_EMAIL_CODE_STORAGE_KEY)
        }
    }

    onMounted(() => {
        if (useStorage) {
            getStorageTime()
        }
        handleChangeWaitTime()
    })

    onUnmounted(() => {
        timer && clearInterval(timer)
    })
    // 页面在等待到期时间的时候的展示内容
    const sendBtnTitle = computed(() => {
        if (latestTime.value) {
            return latestTime.value + 's'
        }
        return t('login.sendCode')
    })

    return { latestTime, loading, sendEnabled, sendPhoneCode, sendEmailCode, sendEmailCodeTwoFactor, clearVerifyCodeTimeout, sendBtnTitle, sendNewEmailCode }
}