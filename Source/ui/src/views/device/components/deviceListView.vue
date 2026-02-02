<!--
 * @Author: shufei.han
 * @Date: 2025-06-11 12:04:48
 * @LastEditors: LPY
 * @LastEditTime: 2025-12-10 14:22:45
 * @FilePath: \glkvm-cloud\ui\src\views\device\components\deviceListView.vue
 * @Description: 
-->
<template>
    <BaseLoadingContainer :spinning="deviceStore.state.getDeviceLoading">
        <div class="device-list-view full-height">
            <div class="header">
                <a-input-search
                    :placeholder="$t('device.searchTip')"
                    style="width: 316px"
                    @search="deviceStore.handleSearch"
                />

                <div>
                    <BaseButton size="middle" style="margin-right: 12px;" @click="refresh">{{ $t('common.refresh') }}</BaseButton>
                    <BaseButton size="middle" @click="executeCommand">{{ $t('device.executeCommand') }}</BaseButton>
                </div>
            </div>
            <div class="content">
                <BaseTable 
                    :data-source="deviceStore.deviceList"
                    :columns="deviceColumns"
                    rowKey="id"
                    :rowSelection="{ selectedRowKeys: state.selectedRowKeys, onChange: onSelectChange }"
                >
                    <template #status="{ record }">
                        <BaseTag primary v-if="isDeviceOnline(record)">{{ $t('device.online') }}</BaseTag>
                        <BaseTag v-else>{{ $t('device.offline') }}</BaseTag>
                    </template>
                    <template #connected="{ record }">
                        {{ record.connected ? calculateWithDuration(record.connected) : '-' }}
                    </template>
                    <template #uptime="{ record }">
                        {{ record.uptime ? calculateWithDuration(record.uptime) : '-' }}
                    </template>
                    <template #action="{ record }">
                        <div class="flex-start">
                            <a 
                                target="_blank"
                                rel="noopener noreferrer"
                                :class="[{'disabled': !isDeviceOnline(record)}]"
                                @click="handleRemoteSSH(record.id, record)">{{ $t('device.remoteSSH') }}</a>
                            <a 
                                target="_blank"
                                rel="noopener noreferrer"
                                style="margin-left: 16px;"
                                :class="[{'disabled': !isDeviceOnline(record)}]"
                                @click="handleRemoteControl(record.id, record)">
                                {{ $t('device.remoteControl') }}
                            </a>
                            <BaseDropdownSelect :options="DEVICE_OPTIONS(record)" @update:value="(v) => handleAction(v, record)">
                                <a 
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    style="margin-left: 16px;">
                                    {{ $t('common.more') }}
                                </a>
                            </BaseDropdownSelect>
                        </div>
                    </template>
                </BaseTable>
            </div>
            <div class="pagination flex-end items-end">
                <BasePagination 
                    :total="deviceStore.pageLink.total"
                    :pageSize="deviceStore.pageLink.size"
                    v-model:current="page" />
            </div>
        </div>

        <!-- 批量编辑弹窗 -->
        <ExecuteCommandDialog 
            v-model:open="executeCommandOpen"
            :selection="state.selectedRows"
            @handleApply="executeCommandApply"
        />

        <!-- 执行命令结果弹窗 -->
        <CommandResponseDialog 
            v-if="commandResponseOpen"
            v-model:open="commandResponseOpen"
            :selection="state.selectedRows"
            :formData="executeCommandFormData"
        />

        <!-- 修改描述弹窗 -->
        <EditDescriptionDialog 
            v-model:open="editDescriptionOpen"
            :deviceId="editingDeviceId"
            :currentDescription="currentDescription"
            @handleApply="handleEditDescriptionApply"
        />
    </BaseLoadingContainer>
</template> 

<script setup lang="ts">
import BaseLoadingContainer from '@/components/base/baseLoadingContainer.vue'
import BasePagination from '@/components/base/basePagination.vue'
import BaseTable from '@/components/base/baseTable.vue'
import { t } from '@/hooks/useLanguage'
import { useDeviceStore } from '@/stores/modules/device'
import { message, type TableColumnType } from 'ant-design-vue'
import { computed, reactive, ref } from 'vue'
import ExecuteCommandDialog from './executeCommandDialog.vue'
import { DeviceInfo, ExecuteCommandFormData } from '@/models/device'
import CommandResponseDialog from './commandResponseDialog.vue'
import { BaseDropdownSelect, BaseInfo, BaseTag } from 'gl-web-main/components'
import EditDescriptionDialog from './editDescriptionDialog.vue'
import { baseCustomModal, SelectOptions } from 'gl-web-main'
import { reqDeleteDevice } from '@/api/device'

const deviceStore  = useDeviceStore()

const deviceColumns = computed<TableColumnType[]>(() => { 
    return [
        {title: t('device.deviceID'), dataIndex: 'id', ellipsis: true},
        {title: t('MAC'), dataIndex: 'mac', ellipsis: true},
        {title: t('device.status'), dataIndex: 'status', ellipsis: true},
        {title: t('device.connectedTime'), dataIndex: 'connected', ellipsis: true},
        {title: t('device.uptime'), dataIndex: 'uptime', ellipsis: true},
        {title: t('device.IPAddress'), dataIndex: 'ipaddr', ellipsis: true},
        {title: t('device.description'), dataIndex: 'description', ellipsis: true},
        {title: t('common.action'), dataIndex: 'action', width: 270},
    ]
})

const page = computed({
    get: () => deviceStore.pageLink.page,
    set: (val) => {
        deviceStore.pageLink.changePage(val)
    },
})

type Key = string | number;
const state = reactive<{
  selectedRowKeys: Key[];
  selectedRows: DeviceInfo[];
}>({
    selectedRowKeys: [], // Check here to configure the default column
    selectedRows: [],
})

const onSelectChange = (selectedRowKeys: Key[], selectedRows: DeviceInfo[]) => {
    console.log('selectedRowKeys changed: ', selectedRowKeys)
    state.selectedRowKeys = selectedRowKeys
    state.selectedRows = selectedRows
}

/** 计算时间 */
const calculateWithDuration = (connected: number) => {
    const day = Math.floor(connected / (60 * 60 * 24))
    const hour = Math.floor((connected % (60 * 60 * 24)) / (60 * 60))
    const minute = Math.floor((connected % (60 * 60)) / (60))
    const second = Math.floor((connected % (60)))

    return `${day}${t('common.d')} ${hour}${t('common.h')} ${minute}${t('common.m')} ${second}${t('common.s')}`
}

/** 刷新列表 */
const refresh = () => {
    deviceStore.getDeviceList()
    message.success(t('device.refreshSuccess'))
}

/** 批量配置 */
const executeCommandOpen = ref(false)
const executeCommand = () => {
    // 判断是否选择了设备
    if (!state.selectedRowKeys.length) {
        message.error(t('device.selectDeviceTips'))
        return
    }
    executeCommandOpen.value = true
}

/** 批量配置结果弹窗 */
const commandResponseOpen = ref(false)

const executeCommandFormData = ref<ExecuteCommandFormData>()
/** 执行命令弹窗提交 */
const executeCommandApply = (formData: ExecuteCommandFormData) => {
    executeCommandFormData.value = formData
    executeCommandOpen.value = false
    commandResponseOpen.value = true
}

/** 远程SSH */
const handleRemoteSSH = async (id: string, device: DeviceInfo) => {
    if (!isDeviceOnline(device)) return
    try {
        let url = `/#/rtty/${id}`
        window.open(url)
    } catch (error) {
        console.log(error)
    }
}

/** 远程控制 */
const handleRemoteControl = async (id: string, device: DeviceInfo) => {
    if (!isDeviceOnline(device)) return
    try {
        let proto = 'https'
        let ipaddr = '127.0.0.1'
        let port = 443
        let path = '/'
        const addr = encodeURIComponent(`${ipaddr}:${port}${path}`)
        window.open(`/web/${id}/${proto}/${addr}`)
    } catch (error) {
        console.log(error)
    }
}

/** 计算设备是否在线 */
const isDeviceOnline = (device: DeviceInfo) => {
    return device.connected && device.connected > 0
}

enum DeviceActions {
    /** 编辑描述 */
    EDIT_DESCRIPTION,
    /** 删除设备 */
    DELETE,
}

const DEVICE_OPTIONS = (device: DeviceInfo) => {
    if (isDeviceOnline(device)) {
        return [
            new SelectOptions(DeviceActions.EDIT_DESCRIPTION, t('device.editDescription')),
        ]
    } else {
        return [
            new SelectOptions(DeviceActions.EDIT_DESCRIPTION, t('device.editDescription')),
            new SelectOptions(DeviceActions.DELETE, t('device.deleteDevice')),
        ]
    }
}

const handleAction = async (action: DeviceActions, device: DeviceInfo) => {
    switch (action) {
    case DeviceActions.EDIT_DESCRIPTION:
        handleEditDescription(device.id, device.description)
        break
    case DeviceActions.DELETE:
        baseCustomModal({
            type: 'confirm',
            title: t('device.deleteDevice'),
            content: t('device.deleteDeviceConfirmTips'),
            onOk: async () => {
                await reqDeleteDevice({ deviceId: device.id })
                deviceStore.getDeviceList()
                message.success(t('common.success'))
            },
        })
        break
    }
}

/** 修改描述 */
const editDescriptionOpen = ref(false)

const editingDeviceId = ref<string>('')
const currentDescription = ref<string>('')
    
const handleEditDescription = (deviceId: string, description: string) => {
    editingDeviceId.value = deviceId
    currentDescription.value = description
    editDescriptionOpen.value = true
}
const handleEditDescriptionApply = () => {
    deviceStore.getDeviceList()
    message.success(t('common.success'))
}
</script> 

<style lang="scss" scoped>
.device-list-view {
    height: 100%;
    .header {
        height: 36px;
        margin-bottom: 16px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .content {
        overflow-x: hidden;
        overflow-y: auto;
        height: calc(100% - 92px);
    }
    .pagination {
        height: 40px;
    }

    .disabled {
        cursor: not-allowed;
        color: var(--gl-color-text-disabled);
    }
}
</style>