/*
 * @Author: shufei.han
 * @Date: 2025-06-12 16:06:03
 * @LastEditors: shufei.han
 * @LastEditTime: 2025-06-16 17:44:19
 * @FilePath: \kvm-cloud-frontend\src\hooks\useBreadCrumb.ts
 * @Description: 面包屑
 */
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

export class BreadCrumbItem {
    constructor (public pathName: string, public title: string) {
    }
}

export function useBreadcrumb () {
    const route = useRoute()
    const router = useRouter()

    const breadcrumbs = route.meta.breadcrumbs

    const showBreadCrumb = computed(() => {
        return breadcrumbs && breadcrumbs.length > 0    
    })

    const isLatest = (index: number) => {
        return index === breadcrumbs.length - 1
    }

    const handleClick = (pathName: string, index: number) => {
        if (isLatest(index)) {
            return 
        }
        router.push({ name: pathName})
    }

    return {
        isLatest,
        breadcrumbs,
        showBreadCrumb,
        handleClick,
    }
}