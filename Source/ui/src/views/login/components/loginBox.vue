<!--
 * @Author: LPY
 * @Date: 2025-06-09 11:19:35
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-20 16:53:39
 * @FilePath: /kvm-cloud-frontend/src/views/login/components/loginBox.vue
 * @Description: 登录注册统一box
-->
<template>
    <div class="login-box" :style="{ 'margin-top': route.query.bindToken ? '20px' : '32px' }">
        <div v-if="props.showLogo" class="login-box-logo">
            <img src="@/assets/svg/login-logo.svg">
        </div>
        <slot></slot>
    </div>
</template>

<script setup lang="ts">
import { useRoute } from 'vue-router'

const route = useRoute()

const props = withDefaults(defineProps<{
  // 是否展示顶部logo
  showLogo?: boolean
}>(), {
    showLogo: true,
})
</script>

<style scoped lang="scss">
.login-box {
  width: 460px;
  background-color: var(--gl-color-bg-surface1);
  border-radius: 24px;
  padding: 36px 32px;

  display: flex;
  flex-direction: column;
  align-items: center;

  margin: 32px 0;

  .login-box-logo {
    width: 70px;
    height: 70px;
    min-height: 70px;
    min-width: 70px;

    img {
      display: block;
      width: 100%;
      height: 100%;
    }
  }
}
</style>