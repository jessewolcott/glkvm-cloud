/*
 * @Author: shufei.han
 * @Date: 2024-08-27 09:18:43
 * @LastEditors: shufei.han
 * @LastEditTime: 2024-10-18 14:29:11
 * @FilePath: \gl-cloud-frontend\src\hooks\usePageLink.js
 * @Description: 用于处理分页相关的逻辑
 */
import type { AnyObject, TableDataResponse } from 'gl-web-main'
import { computed, ref } from 'vue'

export const GLOBAL_PAGE_SIZE = 'GLOBAL_PAGE_SIZE'

interface PageLinkArgs extends AnyObject {
    page?: number
    size?: number
}

/** 默认页码 */
export const DEFAULT_PAGE_SIZE = 10

/**
 * @description 用于分页请求的参数生成器以及相关方法的封装
 */
export class PageLink {
    public total: number
    public page: number
    public size: number
    public others: PageLinkArgs
    static getGlobalPageSize () {
        return Number(localStorage.getItem(GLOBAL_PAGE_SIZE)) || DEFAULT_PAGE_SIZE
    }

    static setGlobalPageSize (size: number) {
        localStorage.setItem(GLOBAL_PAGE_SIZE, size.toString())
    }

    /**
     * @param {{page?: number; size?: number; ...args: any}} args
    */
    constructor (args: PageLinkArgs = {}) {
        /**
         * @type {number}
         * @memberof PageLink
         */
        this.total = 0
        const { page = 1, size = PageLink.getGlobalPageSize(), ...others } = args
        this.page = page
        this.size = size
        this.others = others || {}
    }

    /** 设置其他参数 */
    setParams (params: PageLinkArgs) {
        Object.assign(this.others, params || {})
    }

    /** 自动生成发送到后台请求的getter */
    get params () {
        const { page, size, others } = this
        return { page, size, ...others }
    }

    /** 自动计算pagination有关数据 */
    get pagination () {
        const { page, size, total } = this
        return { page, size, total }
    }

    changePage (page) {
        this.page = page
    }

    /**
     * 重置页面到第一页。
     *
     * 此方法调用 `changePage` 函数，将其页面参数设置为1，以回到列表的第一页。
     * 这通常在用户需要重新开始浏览列表，或者在某些情况下需要重置当前的浏览状态时被调用。
     */
    resetPage () {
        this.changePage(1)
    }

    /**  */
    nextPage () {
        this.page++
    }

    prevPage () {
        this.page--
    }

    setTotal (total) {
        this.total = total
    }

    /**
     * 设置响应数据的相关信息。
     *
     * 本函数主要用于处理从后端请求返回的数据，特别是分页相关信息的设置。
     * 它通过调用其他方法来更新UI或数据模型，以反映新获取的数据状态。
     * 设置后台请求回来的有关数据（主要是pagination有关
     *
     * @param {Object} data - 后端请求返回的数据对象。该对象应包含有关数据总数的信息。
     */
    setRespData (data: TableDataResponse) {
        this.setTotal(data.total)
    }

    setPagination (value = {}) {
        Object.assign(this, value)
    }
}
/**
 * 钩子函数：用于处理分页相关的逻辑
 * 封装了PageLink对象的操作，并在分页参数变化时触发回调
 *
 * @param {Function} onChange - 当分页参数发生变化时可调用的回调函数
 */
export default function usePageLink (onChange, params = {}) {
    // 初始化pageLink实例
    const pageLink = ref(new PageLink(params))

    // 定义pagination计算属性，用于同步pagination的读取和更新
    const pagination = computed({
        get () {
            // 返回当前pageLink实例的pagination属性
            return pageLink.value.pagination
        },
        set (value) {
            // 更新pageLink实例的pagination属性，并触发onChange回调
            pageLink.value.setPagination(value)
            onChange?.()
        },
    })

    // 返回pageLink实例和pagination计算属性供外部使用
    return {
        pageLink,
        pagination,
    }
}
