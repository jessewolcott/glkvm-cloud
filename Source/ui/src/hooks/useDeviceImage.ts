import { DeviceModel } from '@/models/device'
import { useBase64Image, UseBase64Images } from './useBase64Image'
import { computed } from 'vue'

export function useDeviceImage (model?: DeviceModel) { 

    const { data: rm1Pic } = useBase64Image(UseBase64Images.RM1_ICON)
    const { data: rm10Pic } = useBase64Image(UseBase64Images.RM10_ICON)
    const { data: rm1PePic } = useBase64Image(UseBase64Images.RM1_PE_ICON)

    const deviceImgMap = new Map([
        [DeviceModel.RM1, rm1Pic],
        [DeviceModel.RM10, rm10Pic],
        [DeviceModel.RM1PE, rm1PePic],
    ])

    /** 展示的图片 */
    const deviceImage = computed(() => {
        return getImg()    
    })

    const getImg = (deviceModel = model) => {
        return deviceImgMap.get(deviceModel)    
    }

    return {
        deviceImage,
        getImg,
    }
}