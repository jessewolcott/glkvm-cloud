<!--
 * @Author: shufei.han
 * @Date: 2025-06-12 15:56:06
 * @LastEditors: LPY
 * @LastEditTime: 2025-08-25 11:52:17
 * @FilePath: \glkvm-cloud\web-ui\src\views\device\components\noDevicePage.vue
 * @Description: 
-->
<template>
    <div class="flex full-height">
        <div class="flex flex-column">
            <img :src="noDeviceSvg" width="240" height="240" alt="no device yet">
            <BaseText class="text-center no-device" type='large-title-m'>{{ $t('device.noDevice') }}</BaseText>
            <BaseText class="text-center no-device-tip" type='head-r' variant="level2">{{ $t('device.noDeviceTip') }}</BaseText>
            <BaseButton medium primary class="text-center" @click="addDevice">
                <span>+</span>
                <span style="padding-left: 4px;">{{ $t('device.addDevice') }}</span>
            </BaseButton>
        </div>

        <!-- 添加设备弹窗 -->
        <AddDeviceDialog
            v-model:open="state.addDeviceOpen" 
        />
    </div>
</template> 

<script setup lang="ts">
import noDeviceSvg from '@/assets/svg/no-device.svg'
import AddDeviceDialog from './addDeviceDialog.vue'
import { reactive } from 'vue'

const state = reactive({
    addDeviceOpen: false,
})

const addDevice = () => { 
    state.addDeviceOpen = true
}
</script> 

<style lang="scss" scoped>
.no-device {
    margin: 24px 0 4px;
}
.no-device-tip {
    margin-bottom: 32px;
}
</style>