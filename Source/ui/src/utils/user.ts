/*
 * @Author: LPY
 * @Date: 2025-06-11 11:09:41
 * @LastEditors: LPY
 * @LastEditTime: 2025-07-01 15:51:47
 * @FilePath: /kvm-cloud-frontend/src/utils/user.ts
 * @Description: 用户相关方法
 */

import { isForeignEnv } from '.'

/** 获取管理员邮箱地址 */ 
export const getAdminEmailAddress = () => {
    if (isForeignEnv.value) {
        return 'no-reply@goodcloud.xyz'
    } else {
        return 'no-reply@cloud.gl-inet.cn'
    }
}

/** 获取用户头像展示字符 */
export const getUserAvatarInitials = (name: string) => {
    if (name) {
        return name.substring(0, 1).toLocaleUpperCase()
    } else {
        return '-'
    }
}