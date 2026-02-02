/** 设备信息（列表） */
export interface DeviceInfo {
    id: string
    connected: number
    description: string
    group: string
    ipaddr: string
    proto: number
    uptime: number
}

/** 设备列表查询条件 */
export interface DeviceQuery {
    searchText: string
}

/** 执行命令参数 */
export interface ExecuteCommandParams {
    id: string
    group: string
    wait: number
    cmd: string
    params: string[]
    username: string
}

/** 执行命令表单参数 */
export interface ExecuteCommandFormData {
    username: string
    wait: number
    cmd: string
    params: string[]
}