/*
 * @Author: LPY
 * @Date: 2025-06-03 10:52:47
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-20 09:41:41
 * @FilePath: /kvm-cloud-frontend/src/api/requestError.ts
 * @Description: 统一错误提示。
 */

import { t } from '@/hooks/useLanguage'
import { RequestErrorCodeMap, type RequestErrorCodeEnum } from '@/models/request'
import { message } from 'ant-design-vue'

// 错误码翻译的统一前缀
export const ERR_PREFIX = 'errorCode'

const reflectionCode = function (response: { code: RequestErrorCodeEnum, msg: string }) {
    const { code, msg } = response
    if (RequestErrorCodeMap.get(code)) {
        return t(`${ERR_PREFIX}.${RequestErrorCodeMap.get(code)}`)
    } else {
        /** 防止报一长串的后端错误信息 */
        const errString = 'Server Error Message'
        const msgString = typeof msg === 'string' ? msg : errString
        return (msgString.length > 100) ? errString : (msgString || errString)
    }
}

/** 防止一次性显示多条错误信息 */
let preventDuplicate = false
const showErrorMessage = function (response: { code: RequestErrorCodeEnum, msg: string }, data = { translate: true }) {
    if (!preventDuplicate) {
        preventDuplicate = true
        const { translate } = data
        message.error(translate ? reflectionCode(response) : response.msg)
        setTimeout(function () {
            preventDuplicate = false
        }, 3000)
    }
}

export {
    showErrorMessage,
}