/*
 * @Author: LPY
 * @Date: 2025-06-19 09:58:12
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-19 10:12:01
 * @FilePath: /kvm-cloud-frontend/src/projectInitialize/installDirective.ts
 * @Description: 加载自定义指令
 */
import { App } from 'vue'
import ellipsis from '@/directive/ellipsis'

/** 全局注册自定义指令 */
const installDirective = function (app: App) {
    app.directive('ellipsis', ellipsis)
}

export {
    installDirective,
}