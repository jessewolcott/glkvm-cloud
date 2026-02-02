/*
 * @Author: LPY
 * @Date: 2025-06-13 11:46:04
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-13 12:10:37
 * @FilePath: /kvm-cloud-frontend/src/hooks/useSafeI18n.ts
 * @Description: 安全文本渲染组件，统一进行xss过滤
 */
import xss from 'xss'
import { t } from './useLanguage'

// 默认XSS配置
const defaultXssOptions = {
    whiteList: {
        a: ['target', 'href', 'title'],
        abbr: ['title'],
        address: [],
        area: ['shape', 'coords', 'href', 'alt'],
        article: [],
        aside: [],
        audio: [
            'autoplay',
            'controls',
            'crossorigin',
            'loop',
            'muted',
            'preload',
            'src',
        ],
        b: [],
        bdi: ['dir'],
        bdo: ['dir'],
        big: [],
        blockquote: ['cite'],
        br: [],
        caption: [],
        center: [],
        cite: [],
        code: [],
        col: ['align', 'valign', 'span', 'width'],
        colgroup: ['align', 'valign', 'span', 'width'],
        dd: [],
        del: ['datetime'],
        details: ['open'],
        div: [],
        dl: [],
        dt: [],
        em: [],
        figcaption: [],
        figure: [],
        font: ['color', 'size', 'face'],
        footer: [],
        h1: [],
        h2: [],
        h3: [],
        h4: [],
        h5: [],
        h6: [],
        header: [],
        hr: [],
        i: [],
        img: ['src', 'alt', 'title', 'width', 'height', 'loading'],
        ins: ['datetime'],
        kbd: [],
        li: [],
        mark: [],
        nav: [],
        ol: [],
        p: [],
        pre: [],
        s: [],
        section: [],
        small: [],
        span: [],
        sub: [],
        summary: [],
        sup: [],
        strong: [],
        strike: [],
        table: ['width', 'border', 'align', 'valign'],
        tbody: ['align', 'valign'],
        td: ['width', 'rowSpan', 'colspan', 'align', 'valign'],
        tfoot: ['align', 'valign'],
        th: ['width', 'rowSpan', 'colspan', 'align', 'valign'],
        thead: ['align', 'valign'],
        tr: ['rowSpan', 'align', 'valign'],
        tt: [],
        u: [],
        ul: [],
        video: [
            'autoplay',
            'controls',
            'crossorigin',
            'loop',
            'muted',
            'playsInline',
            'poster',
            'preload',
            'src',
            'height',
            'width',
        ],
    },
    stripIgnoreTag: true,
    stripIgnoreTagBody: ['script', 'style'],
    escapeHtml (html: string) {
        return html.replace(/</g, '').replace(/>/g, '')
    },
}

export function useSafeI18n (customXssOptions = {}) {
    const xssOptions = { ...defaultXssOptions, ...customXssOptions }

    const getSafeHtml = (path: string, params = {}, emitFn = undefined) => {
        const translatedText = t(path, params)
        const filteredText = xss(translatedText, xssOptions)
        if (emitFn) emitFn(filteredText)
        return filteredText
    }

    return {
        getSafeHtml,
    }
}