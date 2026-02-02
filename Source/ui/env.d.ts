/*
 * @Author: LPY
 * @Date: 2025-06-03 09:59:55
 * @LastEditors: shufei.han
 * @LastEditTime: 2025-06-10 11:55:40
 * @FilePath: \kvm-cloud-frontend\env.d.ts
 * @Description: ts类型统一配置
 */
/// <reference types="vite/client" />

import type { BaseButton, BaseText } from 'gl-web-main/components'
import type BaseSvg from './src/components/base/baseSvg.vue'

declare module 'vue' {
    export interface GlobalComponents {
        BaseButton: typeof BaseButton
        BaseText: typeof BaseText
        BaseSvg: typeof BaseSvg
    }
}