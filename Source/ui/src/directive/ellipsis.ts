/*
 * @Author: LPY
 * @Date: 2025-06-19 09:53:04
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-19 10:09:33
 * @FilePath: /kvm-cloud-frontend/src/directive/ellipsis.ts
 * @Description: 自定义超出文本显示省略号及tooltip提示
 */
import { DirectiveBinding, ObjectDirective } from 'vue'

let tooltipDom: HTMLDivElement | null = null

/** 鼠标移入事件 */
function handleMouseEnter (e: MouseEvent) {
    if (!(e.currentTarget instanceof HTMLElement)) return
  
    if (!tooltipDom) {
    // 创建浮层元素
        tooltipDom = document.createElement('div')
        // 将浮层插入到body中
        document.body.appendChild(tooltipDom)
    }
  
    const maxWidth = 600
    let cssText = `
        max-width: ${maxWidth}px;
        overflow: auto;
        position: fixed;
        background: var(--gl-color-bg-tooltip);
        color: var(--gl-color-text-white);
        border-radius: 4px;
        line-height: 20px;
        padding: 10px;
        display: block;
        font-size: 12px;
        z-index: 99999;
        word-break: break-all;
    `
  
    // 根据鼠标移入位置判断浮层位于左侧还是右侧，避免遮挡
    if (window.innerWidth - e.clientX < maxWidth) {
        cssText += `right:${window.innerWidth - e.clientX}px;`
    } else {
        cssText += `left:${e.clientX + 20}px;`
    }
  
    // 根据鼠标移入位置判断浮层位于上方还是下方，避免遮挡
    if (window.innerHeight - e.clientY < 600) {
        cssText += `bottom:${window.innerHeight - e.clientY}px;`
    } else {
        cssText += `top:${e.clientY}px;`
    }

    tooltipDom.style.cssText = cssText
    // 浮层中的文字
    tooltipDom.textContent = e.currentTarget.textContent
}

function removeTooltip () {
    // 隐藏浮层
    if (tooltipDom) {
        tooltipDom.style.display = 'none'
    }
}

function bindEvent (el: HTMLElement, binding: DirectiveBinding<boolean>) {
    // 先移除上一次绑定的事件
    el.removeEventListener('mouseenter', handleMouseEnter)
    el.removeEventListener('mouseleave', removeTooltip)

    if (binding.value === false) {
        return
    }
  
    // 给当前元素设置超出隐藏
    el.style.overflow = 'hidden'
    el.style.textOverflow = 'ellipsis'
    el.style.whiteSpace = 'nowrap'
  
    // 如果超出，绑定鼠标移入移出事件
    if (el.scrollWidth > el.offsetWidth) {
        el.addEventListener('mouseenter', handleMouseEnter)
        // 鼠标移出 将提示信息移除
        el.addEventListener('mouseleave', removeTooltip)
    }
}

const ellipsis: ObjectDirective<HTMLElement, boolean> = {
    mounted (el, binding) {
        bindEvent(el, binding)
    },
    updated (el, binding) {
        bindEvent(el, binding)
    },
    unmounted () {
    // 清理浮层
        if (tooltipDom && document.body.contains(tooltipDom)) {
            document.body.removeChild(tooltipDom)
            tooltipDom = null
        }
    },
}

export default ellipsis