/*
 * @Author: LPY
 * @Date: 2025-06-09 16:37:00
 * @LastEditors: LPY
 * @LastEditTime: 2025-11-12 16:19:19
 * @FilePath: \glkvm-cloud\ui\src\models\user.ts
 * @Description: 用户相关类型声明
 */

/** 登录参数 (Login parameters) */
export interface LoginParams {
    username?: string;
    password: string; 
    authMethod?: 'ldap' | 'legacy';
}

/** 认证配置 (Authentication configuration) */
export interface AuthConfig {
    ldapEnabled: boolean;
    legacyPassword: boolean;
    oidcEnabled: boolean;
}