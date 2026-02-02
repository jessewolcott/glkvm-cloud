/*
 * @Author: LPY
 * @Date: 2025-06-13 10:57:38
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-13 11:03:55
 * @FilePath: /kvm-cloud-frontend/src/models/error.ts
 * @Description: 错误相关配置
 */
/** 用户页面状态 */
export enum PageErrorStatus {
    NOT_LOGIN = '401', // 未登录
    NO_PERMISSION = '403', // 没有权限
    NOT_FOUND = '404', // 未找到
}

/** 各种状态下的错误描述，错误码，以及按钮状态配置 */
export const PageErrorStatusMap = new Map([
    [
        PageErrorStatus.NOT_LOGIN,
        {
            code: 401,
            desc: 'errorPage.notLogion',
            // 底部展示的按钮配置，目前支持的按钮类型有：backHome,refresh
            btnList: ['backHome'],
        },
    ],
    [
        PageErrorStatus.NO_PERMISSION,
        {
            code: 403,
            desc: 'errorPage.noPermission',
            // 底部展示的按钮配置，目前支持的按钮类型有：backHome,refresh
            btnList: ['backHome'],
        },
    ],
    [
        PageErrorStatus.NOT_FOUND,
        {
            code: 404,
            desc: 'errorPage.notFound',
            // 底部展示的按钮配置，目前支持的按钮类型有：backHome,refresh
            btnList: ['backHome', 'refresh'],
        },
    ],
])