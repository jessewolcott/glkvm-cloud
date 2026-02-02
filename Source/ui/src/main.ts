/*
 * @Author: LPY
 * @Date: 2025-05-29 17:09:32
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-10 15:24:29
 * @FilePath: /kvm-cloud-frontend/src/main.ts
 * @Description: 项目入口配置文件
 */

import { createApp } from 'vue'
import 'gl-web-main/style.css'
import '@/styles/index.scss'
import App from './App.vue'
import projectInitialize from './projectInitialize'

const app = createApp(App)

projectInitialize(app)

app.mount('#app')