/*
* @Author: LPY
* @Date: 2025-06-03 10:31:04
 * @LastEditors: LPY
 * @LastEditTime: 2025-07-01 16:03:28
 * @FilePath: /kvm-cloud-frontend/src/utils/index.ts
* @Description: 公共方法
*/

import { t } from '@/hooks/useLanguage'
import { glConfirm, type BaseConfirmProps } from 'gl-web-main'
import { message } from 'ant-design-vue'
import { ValidateErrorEntity } from 'ant-design-vue/es/form/interface'
import { AxiosError } from 'axios'
import { computed } from 'vue'

/** 环境变量 */
export const ENVIRONMENT = import.meta.env.MODE

/** 是否国外环境 */
export const isForeignEnv = computed(() => {
    return ['production', 'test', 'development'].includes(ENVIRONMENT)
})

/** 判空方法 */
export function isEmpty (value: any) {
    return [null, undefined, ''].includes(value)
}

/** 封装基础的confirm方法 */
export function baseConfirm (props: BaseConfirmProps) {
    return glConfirm({
        ...props,
        keyboard: false,
        title: t(<string>props.title || 'common.confirm'),
        okText: t( props.okText || 'common.confirm'),
        cancelText: t( props.cancelText || 'common.cancel'),
        content: t(<string>props.content),
    })
}
/** 封装基础的info方法 */
export function baseInfo (props: BaseConfirmProps) {
    return baseConfirm({
        showIcon: false,
        ...props,
        type: 'info',
    })
}
export class ErrorMsgHandler {
    /** 是否从服务器返回的信息中解析出错误信息并在页面提示 */
    public hasError: boolean
    constructor (private  error: unknown) {
        this.hasError = this.showError() || this.showFormError()
    }
    /**
     * @description 使用message.error提示错误信息到页面
     * @returns 是否从服务器返回的信息中解析出错误信息并在页面提示
     */
    private showError () {
        try {
            const { error_msg } = (<AxiosError<{result: {error_msg: string}}>> this.error).response.data.result
            message.error(error_msg)
            return true
        } catch (error) {
            return false
        }
    }
    /**
     * @description 显示antd的表单验证的错误信息
     * @returns 显示表单验证错误
     */
    private showFormError () {
        try {
            const error = (this.error as ValidateErrorEntity)?.errorFields?.[0]?.errors?.[0]
            if (error) {
                message.error(error)
                return true
            }
            return false
        } catch (error) {
            return false
        }
    }
}

/**
 * 将毫秒数转换为 "MM:SS" 格式
 * @param milliseconds 要转换的毫秒数
 * @returns 格式化为 "MM:SS" 的字符串
 */
export function formatMillisecondsToMMSS (milliseconds: number): string {
    // 确保输入是数字且不为负数
    if (typeof milliseconds !== 'number' || milliseconds < 0) {
        return '00:00'
    }

    // 计算总秒数并向下取整
    const totalSeconds = Math.floor(milliseconds / 1000)
  
    // 计算分钟和秒数
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60

    // 使用 padStart 确保两位数格式
    const formattedMinutes = String(minutes).padStart(2, '0')
    const formattedSeconds = String(seconds).padStart(2, '0')

    return `${formattedMinutes}:${formattedSeconds}`
}
