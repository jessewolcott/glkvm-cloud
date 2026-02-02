<!--
 * @Author: LPY
 * @Date: 2025-06-13 10:41:50
 * @LastEditors: LPY
 * @LastEditTime: 2025-07-18 16:32:06
 * @FilePath: /kvm-cloud-frontend/src/views/error/errorPage.vue
 * @Description: 404页面
-->
<template>
    <div class="http404-container">
        <div class="http404">
            <div class="info">
                <div class="info-sorry">
                    <span>{{ $t('errorPage.sorry') }}</span>
                </div>

                <div v-html="useSafeI18n().getSafeHtml(showCommonInfo.desc)" class="info-text" />

                <div class="info-btn">
                    <BaseButton v-if="showCommonInfo.btnList.includes('backHome')" size="small" type="primary" @click="goHomeFn">
                        {{ $t('errorPage.backHome') }}
                    </BaseButton>

                    <BaseButton v-if="showCommonInfo.btnList.includes('refresh')" size="small" class="refresh" @click="refreshFn">
                        {{ $t('errorPage.tryRefresh') }}
                    </BaseButton>
                </div>
            </div>

            <div class="image">
                <div class="error-code">
                    {{ showCommonInfo.code }}
                </div>
            </div>
        </div>
        <!-- 800px -->
        <div class="http404-800">
            <div class="image">
                <div class="error-code">
                    {{ showCommonInfo.code }}
                </div>
            </div>
            <div class="info">
                <div class="info-sorry">
                    <span>{{ $t('errorPage.sorry') }}</span>
                </div>

                <div v-html="useSafeI18n().getSafeHtml(showCommonInfo.desc)" class="info-text" />

                <div class="info-btn">
                    <BaseButton v-if="showCommonInfo.btnList.includes('backHome')" type="primary" size="small" @click="goHomeFn">
                        {{ $t('errorPage.backHome') }}
                    </BaseButton>

                    <BaseButton v-if="showCommonInfo.btnList.includes('refresh')" size="small" class="refresh" @click="refreshFn">
                        {{ $t('errorPage.tryRefresh') }}
                    </BaseButton>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import { useRouter, useRoute } from 'vue-router'
import { computed } from 'vue'
import { PageErrorStatus, PageErrorStatusMap } from '@/models/error'
import { useSafeI18n } from '@/hooks/useSafeI18n'

const router = useRouter()
const route = useRoute()

const type = route.query.type as PageErrorStatus

const showCommonInfo = computed(() => {
    // 传了type参数则显示对应的错误信息，否则显示默认的404
    const errorType = type || PageErrorStatus.NOT_FOUND
    return PageErrorStatusMap.get(errorType)
})

const refreshFn = () => location.reload()
const goHomeFn = () => router.push('/')
</script>

<style lang="scss" scoped>
.http404-container {
    min-width: 100vw;
    min-height: 100vh;
    background-color: var(--gl-color-bg-surface1);
    display: flex;
    align-items: center;
    .info {
        .info-sorry {
            color: var(--gl-color-text-level1);
            line-height: 36px;
            font-weight: 500;
        }

        .info-text {
            font-weight: 400;
        }

        .refresh {
            margin-left: 24px;
        }
    }
}

@media (min-width: 1366px) {
    .http404-800 {
        display: none;
    }

    .http404 {
        width: 100%;
        display: flex;
        justify-content: center;

        .info {
            width: 440px;
            margin-right: 64px;

            .info-sorry {
                height: 58px;
                font-size: 48px;
            }

            .info-text {
                font-size: 24px;
                line-height: 36px;
                margin: 20px 0 60px 0;
                color: var(--gl-color-text-level1);
            }
        }

        .image {
            width: 400px;
            height: 290px;
            background: url('@/assets/images/error-page.png') no-repeat;
            background-position: center;
            background-size: 100% 100%;
            .error-code{
                font-size: 94px;
                font-weight: bold;
                margin-top: 108px;
                // 字间距
                letter-spacing: -7.2px;
                // 设置字体
                font-family: 'Bahnschrift';
                color: var(--gl-color-text-level1);
                padding-left: 24px;
            }
        }
    }
}

@media (max-width: 1365px) {
    .http404 {
        display: none;
    }

    .http404-container {
        display: flex;
        justify-content: center;

        .http404-800 {
            width: 360px;

            .image {
                margin: 0 auto;
                width: 300px;
                overflow: hidden;
                height: 215px;
                background: url('@/assets/images/error-page.png') no-repeat;
                background-size: 100% 100%;
                 .error-code{
                    font-size: 60px;
                    font-weight: bold;
                    margin-top: 88.4px;
                    // 字间距
                    letter-spacing: -2.88px;
                    // 设置字体
                    font-family: 'Bahnschrift';
                    color: var(--gl-color-text-level1);
                    padding-left: 22px;
                }
            }

            .info {
                .info-sorry {
                    margin: 20px 0;
                    height: 48px;
                    font-size: 40px;
                    text-align: center;
                }

                .info-text {
                    font-size: 20px;
                    text-align: center;
                    line-height: 30px;
                    color: var(--gl-color-text-level1);
                }

                .info-btn {
                    margin-top: 60px;
                    display: flex;
                    justify-content: center;
                }
            }
        }
    }
}
</style>