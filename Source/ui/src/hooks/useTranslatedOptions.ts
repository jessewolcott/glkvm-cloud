/*
 * @Author: LPY
 * @Date: 2025-06-09 16:58:28
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-09 16:58:32
 * @FilePath: /kvm-cloud-frontend/src/hooks/useTranslatedOptions.ts
 * @Description: 选项统一翻译处理
 */
import { computed } from 'vue'
import useLanguage from './useLanguage'
import type { SelectOptions } from 'gl-web-main'

export const useTranslatedOptions = <T>(options: SelectOptions<T>[]) => {
    const { t } = useLanguage()
    return computed(() => {
        return options.map(option => {
            return {
                ...option,
                label: t(option.label),
            }
        })    
    })
}