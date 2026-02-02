/*
 * @Author: LPY
 * @Date: 2025-06-25 09:55:49
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-25 10:22:21
 * @FilePath: /kvm-cloud-frontend/src/utils/auth.ts
 * @Description: 权限模块方法
 */
import Cookies from 'js-cookie'

const TokenKey = 'auth_token'

// 获取token
export function getCookieToken () {
    return Cookies.get(TokenKey)
}

// 设置token
export function setCookieToken (token: string) {
    Cookies.set(TokenKey, token, {
        // expires: expiresDate,
        // secure: ENVIRONMENT === 'production', // 生产环境启用
        // sameSite: 'strict',
        // httpOnly: true, // 注意：客户端JS无法设置HttpOnly，这需要后端设置
    })
}

// 移除token
export function removeCookieToken () {
    Cookies.remove(TokenKey)
}