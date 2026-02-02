/*
 * @Author: LPY
 * @Date: 2025-05-30 09:45:16
 * @LastEditors: shufei.han
 * @LastEditTime: 2025-06-10 12:16:24
 * @FilePath: \kvm-cloud-frontend\src\projectInitialize\installComponent.ts
 * @Description: 注册插件
 */
import type { App }  from 'vue'

import '@/assets/iconfont/iconfont.js'
import BaseSvg from '@/components/base/baseSvg.vue'
import { BaseButton, BaseText } from 'gl-web-main/components'

/** 全局注册自定义组件 */
const installComponent = function (app: App) {
    app.component('BaseButton', BaseButton)
    app.component('BaseText', BaseText)
    app.component('BaseSvg', BaseSvg)
}

export {
    installComponent,
}