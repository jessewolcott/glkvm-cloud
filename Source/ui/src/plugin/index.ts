/*
 * @Author: LPY
 * @Date: 2025-05-30 09:42:28
 * @LastEditors: LPY
 * @LastEditTime: 2025-05-30 09:59:17
 * @FilePath: \kvm-cloud-frontend\src\plugin\index.ts
 * @Description: 插件相关配置
 */
import type { App } from 'vue'
import router from '@/router'
import store from '@/stores'
import i18n from '@/lang'

/** 加载插件 */
export default function (app: App) {
    app.use(store)
    app.use(router)
    
    /** 加载多语言 */
    app.use(i18n)
}