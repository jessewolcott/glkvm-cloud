/*
 * @Description:
 * @Author: warren
 * @LastEditors: warren
 * @Date: 2023-12-21 11:48:25
 * @LastEditTime: 2024-03-11 09:49:00
 */
/* eslint-env node */
require('@rushstack/eslint-patch/modern-module-resolution')

module.exports = {
    root: true,
    extends: [
        'plugin:vue/vue3-essential',
        'eslint:recommended',
        '@vue/eslint-config-typescript',
    ],
    parserOptions: {
        ecmaVersion: 'latest',
    },
    rules: {
        'keyword-spacing': ['error', { before: true, after: true }],
        'space-before-function-paren': ['error', 'always'],
        indent: ['error', 4],
        semi: ['error', 'never'],
        quotes: ['error', 'single'],
        'quote-props': [2, 'as-needed'],
        'comma-dangle': ['error', 'always-multiline'],
        'max-len': ['error', { code: 160 }],
        'max-lines': ['error', { max: 600, skipBlankLines: true, skipComments: true }],
        'vue/html-indent': ['error', 4, { baseIndent: 1 }],
        'vue/block-order': ['error', {
            order: ['template', 'script', 'style'],
        }],
        'vue/max-attributes-per-line': ['error', {
            singleline: {
                max: 12,
            },
            multiline: {
                max: 1,
            },
        }],
        'vue/attribute-hyphenation': ['error', 'never', {
            ignore: [],
        }],
        'vue/multi-word-component-names': ['error', {
            ignores: [],
        }],
    },
}
