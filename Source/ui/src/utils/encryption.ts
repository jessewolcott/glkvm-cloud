/*
 * @Author: LPY
 * @Date: 2025-06-03 09:46:32
 * @LastEditors: LPY
 * @LastEditTime: 2025-06-03 16:22:39
 * @FilePath: /kvm-cloud-frontend/src/utils/encryption.ts
 * @Description: 请求加密
 */
import JsEncrypt from 'jsencrypt'

/** 加密数据 */
export const getEncryptionHex = function (value: string) {
    const publicKey = 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAItoR8lrBZ/ZaJZ3XvvgP8I31ImaTwbEPzPElmIZAasWoAzw3InqMVyeL7rTlFS3TFz3HMKBnrFlr463Bu19Tz0CAwEAAQ=='
    const encrypt = new JsEncrypt()
    encrypt.setPublicKey(publicKey)

    return encrypt.encrypt(value).toString()
}