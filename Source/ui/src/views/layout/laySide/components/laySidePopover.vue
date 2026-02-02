<!--
 * @Author: LPY
 * @Date: 2025-06-16 11:29:20
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-16 11:49:07
 * @FilePath: /kvm-cloud-frontend/src/views/layout/laySide/components/laySidePopover.vue
 * @Description: 侧边栏弹出框
-->
<template>
    <div ref="popover" class="popover">
        <div v-show="visible" ref="contentWrapper" class="content-wrapper" :class="{[`position-${position}`]: true}" :style="{'--height': heightVar}">
            <div class="content">
                <!-- <div class="arrow" /> -->
                <slot name="content" :close="close" />
            </div>
        </div>
        <!-- span标签增加display: inline-block; 解决包裹元素高度一致的问题 -->
        <span ref="triggerWrapper" style="display: inline-block;">
            <slot />
        </span>
    </div>
</template>

<script>
export default {
    name: 'GlPopover',
    components: {},

    props: {
        position: {
            type: String,
            default: 'right',
            validator (value) {
                return ['top', 'bottom', 'left', 'right'].indexOf(value) >= 0
            },
        },
        trigger: {
            type: String,
            default: 'hover',
            validator (value) {
                return ['click', 'hover', 'focus'].indexOf(value) >= 0
            },
        },
    },

    data () {
        return {
            visible: false,
            timer: null,
            heightVar: '30px',
        }
    },

    computed: {},

    mounted () {
        const popover = this.$refs.popover
        const contentWrapper = this.$refs.contentWrapper
        const triggerWrapper = this.$refs.triggerWrapper
        const triggerWrapperChild = triggerWrapper.children[0]
        if (this.trigger === 'click') {
            popover.addEventListener('click', this.onClick)
        } else if (this.trigger === 'hover') {
            triggerWrapperChild.addEventListener('mouseenter', this.open)// 添加hover监听事件
            triggerWrapperChild.addEventListener('mouseleave', this.hoverDelay)// 取消hover监听事件

            contentWrapper.addEventListener('mouseenter', () => clearTimeout(this.timer))
            contentWrapper.addEventListener('mouseleave', this.close)// 取消hover监听事件
        } else {
            popover.addEventListener('mousedown', this.open)// 添加hover监听事件
            popover.addEventListener('mouseup', this.close)// 取消hover监听事件
        }
    },

    beforeUnmount () { // 页面销毁的时候去掉监听
        const popover = this.$refs.popover
        const contentWrapper = this.$refs.contentWrapper
        const triggerWrapper = this.$refs.triggerWrapper
        const triggerWrapperChild = triggerWrapper.children[0]

        if (this.trigger === 'click') {
            popover.removeEventListener('click', this.open())
        } else if (this.trigger === 'hover') {
            triggerWrapperChild.removeEventListener('mouseenter', this.open)// 添加hover监听事件
            triggerWrapperChild.removeEventListener('mouseleave', this.hoverDelay)// 取消hover监听事件

            contentWrapper.removeEventListener('mouseenter', () => clearTimeout(this.timer))
            contentWrapper.removeEventListener('mouseleave', this.close)// 取消hover监听事件
        } else {
            popover.removeEventListener('mousedown', this.open())
            popover.removeEventListener('mouseup', this.close())
        }
    },

    methods: {
        positionContent () {
            document.body.appendChild(this.$refs.contentWrapper)
            const { contentWrapper, triggerWrapper } = this.$refs
            const {
                width, height, top, left,
            } = triggerWrapper.getBoundingClientRect()
            this.heightVar = (contentWrapper.offsetHeight / 2) + 'px'
            const positions = {
                top: {
                    top: top + window.scrollY,
                    left: left + window.scrollX,
                },
                bottom: {
                    top: top + height + window.scrollY,
                    left: left + window.scrollX,
                },
                left: {
                    top: top + window.scrollY,
                    left: left + window.scrollX,
                },
                right: {
                    top: top + window.scrollY - (contentWrapper.offsetHeight / 2) + 28,
                    left: left + width + window.scrollX + 14,
                },
            }

            // 判断是否超出视口高度
            if (this.isOverHeight(positions[this.position].top, contentWrapper.offsetHeight)) {
                positions[this.position].top = positions[this.position].top - (contentWrapper.offsetHeight / 2)
            }

            contentWrapper.style.left = positions[this.position].left + 'px'
            contentWrapper.style.top = positions[this.position].top + 'px'
        },
        onClickDocument (e) { // 如果点击在popover 则让popover自己去处理，document不管
            if (this.$refs.contentWrapper && this.$refs.contentWrapper.contains(e.target)) { return }
            this.close()
        },
        open () {
            this.visible = true
            setTimeout(() => {
                this.positionContent()
                document.addEventListener('click', this.onClickDocument)
            })
        },
        close () {
            this.visible = false
            document.removeEventListener('click', this.onClickDocument)
        },
        onClick (event) {
            if (this.$refs.triggerWrapper.contains(event.target)) { // 找到点击事件的元素
                if (this.visible) {
                    this.close()
                } else {
                    this.open()
                }
            }
        },
        hoverDelay () {
            this.timer = setTimeout(() => {
                this.close()
            }, 100)
        },
        /** 判断是否超出视口高度 */
        isOverHeight (contentWrapperClientHeight, contentWrapperHeight) {
            return document.documentElement.clientHeight < contentWrapperClientHeight + contentWrapperHeight
        },
    },
}
</script>

<style lang="scss" scoped>
.content-wrapper {
  position: fixed !important;

  background-color: var(--gl-color-bg-surface1);
  padding: 10px;
  border-radius: 12px;
  box-shadow: 0px 1px 10px 0px rgba(0, 0, 0, 0.05);
  z-index: 2000;
}

.content {
  position: relative;
}

.content:after {
  content: '';
  position: absolute;
  top: -10px;
  left: -9px;

  width: 60px;
  height: calc(var(--height) * 2);
  background-color: var(--gl-color-bg-surface1);
  border-radius: 12px;
  z-index: -1;
}

</style>