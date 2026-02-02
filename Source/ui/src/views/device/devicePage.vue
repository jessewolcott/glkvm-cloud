<!--
 * @Author: shufei.han
 * @Date: 2025-06-09 09:22:43
 * @LastEditors: LPY
 * @LastEditTime: 2025-08-26 10:09:20
 * @FilePath: \glkvm-cloud\web-ui\src\views\device\devicePage.vue
 * @Description: 设备模块入口页面
-->
<template>
    <BasePage v-if="!state.hasFetchedDevice">
        <div  class="full-height flex">
            <BaseLoading antdMode block>
            </BaseLoading>
        </div>
    </BasePage>
    <BasePage v-else-if="!deviceStore.state.hasDevice">
        <NoDevicePage />
    </BasePage>

    <div class="device-list-container" v-else>
        <div class="out-device-list-header">
            <div class="left">
                <BaseSvg name="gl-icon-device" :size="24" style="color: var(--gl-color-brand-primary);margin: 2px 8px 0 0;"></BaseSvg>
                <BaseText type="large-title-m">{{ $t('device.devices') + '(' + deviceStore.deviceList.length + ')' }}</BaseText>
            </div>
            <div class="right">
                <BaseButton type="primary" size="middle" @click="state.addDeviceOpen = true">+ {{ $t('device.addDevice') }}</BaseButton>
            </div>
        </div>
        <div class="device-list">
            <div class="device-list-content">
                <DeviceListView />
            </div> 
        </div>
    </div>

    <!-- 添加设备弹窗 -->
    <AddDeviceDialog
        v-model:open="state.addDeviceOpen"
    />

</template> 

<script setup lang="ts">
import BasePage from '@/components/base/basePage.vue'
import NoDevicePage from './components/noDevicePage.vue'
import { useDeviceStore } from '@/stores/modules/device'
import DeviceListView from './components/deviceListView.vue'
import { reactive, onBeforeUnmount, onMounted } from 'vue'
import { BaseLoading } from 'gl-web-main/components'
import AddDeviceDialog from './components/addDeviceDialog.vue'

const deviceStore = useDeviceStore()

const state = reactive({
    remoteLoadingDeviceMacs: new Set<string>(),
    /** 是否已经第一次获取完毕 */
    hasFetchedDevice: false,
    /** 添加设备弹窗 */
    addDeviceOpen: false,
})

deviceStore.startPolling()

onBeforeUnmount(deviceStore.stopPolling)

onMounted(async () => { 
    await deviceStore.getDeviceList(false, true)
    state.hasFetchedDevice = true
})
</script> 

<style lang="scss" scoped>
.device-list-container {
    height: 100%;
    padding: 20px 24px;
    background-color: var(--gl-color-bg-page);

    .out-device-list-header {
        height: 48px;
        margin-bottom: 16px;
        padding: 0 12px;
        display: flex;
        justify-content: space-between;
        align-items: center;

        .left {
            display: flex;
            align-items: center;
        }
    }

    .device-list {
        height: calc(100% - 64px);
        background-color: var(--gl-color-bg-surface1);
        border-radius: 10px;
        padding: 20px 24px;
        .device-list-content {
            height: 100%;
        }
    }
}
</style>