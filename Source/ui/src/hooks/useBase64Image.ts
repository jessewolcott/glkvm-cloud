/*
 * @Author: shufei.han
 * @Date: 2025-06-19 11:18:11
 * @LastEditors: LPY
 * @LastEditTime: 2025-07-17 15:04:37
 * @FilePath: /kvm-cloud-frontend/src/hooks/useBase64Image.ts
 * @Description: 获取base64图片(访问速度优化)
 */
import { reactive } from 'vue'
import rm1Icon from '@/assets/images/rm1.png'
import rm1PeIcon from '@/assets/images/rm1-pe.png'
import rm10Icon from '@/assets/images/rm10.png'
import onLineSrc from '@/assets/svg/device-card-online.svg'
import offLineSrc from '@/assets/svg/device-card-offline.svg'
import discoverFrameSrc from '@/assets/svg/discover-frame.svg'

export enum UseBase64Images {
    RM1_ICON = 'base64_rm1_icon',
    RM1_PE_ICON = 'base64_rm1_pe_icon',
    RM10_ICON = 'base64_rm10_icon',
    ONLINE_CARD_ICON = 'base64_online_icon',
    OFFLINE_CARD_ICON = 'base64_offline_icon',
    DISCOVER_FRAME_ICON = 'base64_discover_frame_icon',
}

export const Base64ImageMap = new Map([
    [UseBase64Images.RM1_ICON, rm1Icon],
    [UseBase64Images.RM1_PE_ICON, rm1PeIcon],
    [UseBase64Images.RM10_ICON, rm10Icon],
    [UseBase64Images.ONLINE_CARD_ICON, onLineSrc],
    [UseBase64Images.OFFLINE_CARD_ICON, offLineSrc],
    [UseBase64Images.DISCOVER_FRAME_ICON, discoverFrameSrc],
])
/** 判断是否是base64图片 */
export const isValidBase64Image = (base64: string) => {
    if (!base64) return false
    return base64.startsWith('data:image/')
}
/** 将图片转成base64 */
export function loadImageAndTRansferToBase64 (imgSrc: string) {
    const image = new Image()
    image.src = imgSrc

    return new Promise<string>((resolve, reject) => {
        image.onload = () => {
            const canvas = document.createElement('canvas')
            canvas.width = image.width
            canvas.height = image.height
            const ctx = canvas.getContext('2d')
            if (ctx) {
                ctx.drawImage(image, 0, 0)
                const base64 = canvas.toDataURL('image/png')
                resolve(base64)
            } else {
                reject()
            }
        }
        image.onerror = () => {
            reject()
        }
    })
}
/** 使用base64图片（基于localStorage） */
export function useBase64Image (type: UseBase64Images) {
    const imgSrc = Base64ImageMap.get(type)
    
    const data = reactive({
        src: null as string,
        finished: false,
    })

    const getImage = async () => {
        const base64 = localStorage.getItem(type)
        if (isValidBase64Image(base64)) {
            data.src = base64
            data.finished = true
        }
        try {
            const base64 = await loadImageAndTRansferToBase64(imgSrc)
            setImageToStorage(base64)
            data.src = base64
        } catch (error) {
            data.src = imgSrc
        }
        
        data.finished = true
    }

    const setImageToStorage = (base64Data: string) => {
        if (isValidBase64Image(base64Data)) {
            localStorage.setItem(type, base64Data)
        }
    }

    getImage()

    return { data, getImage, setImageToStorage }
}
