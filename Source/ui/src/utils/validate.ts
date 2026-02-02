/** eslint-disable max-len */

/**
 * validate phone
 * @param phone
 * @returns {boolean}
 */
export function isValidPhone (phone) {
    const reg = /^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$/
    return reg.test(phone)
}

/** 合法 username */
/**
 * 
 * @param name 
 * @returns 返回true或者字符串（i18n索引），如果返回true则代表校验成功
 */
export function isValidUsername (name: string = '') {
    if (name.length < 5 || name.length > 15) {
        return 'usernameLengthError'
    }
    const regCheckFirstCharacter = /^[0-9a-zA-Z]$/
    const strFirstCharacter = name.charAt(0)
    if (!regCheckFirstCharacter.test(strFirstCharacter)) {
        return 'usernameFirstCharacterValidateError'
    }
    const reg = /^[0-9a-zA-Z][0-9a-zA-Z_.-]+$/
    if (!reg.test(name)) {
        return 'usernameSpecialCharacterValidateError'
    }
    return true
}

// 校验用户名合法性方法
export const validateUsername = (value:string) => {
    const result = isValidUsername(value)
    // const { t } = i18n.global
    if (result === 'usernameLengthError') {
        return Promise.reject('login.usernameLengthValidateError')
    } else if (result === 'usernameFirstCharacterValidateError') {
        return Promise.reject('login.usernameFirstCharacterValidateError')
    } else if (result === 'usernameSpecialCharacterValidateError') {
        return Promise.reject('login.usernameSpecialCharacterValidateError')
    } else if (result === true) {
        // return Promise.resolve()
        return Promise.resolve()
    }
}

/**
 * validate two factor Authenticator code
 * @param code
 * @returns {boolean}
 */
export function isValidateTwoFACode (code) {
    if (!code || (code && code.length !== 6)) {
        return false
    }
    const re = /^[0-9]*$/
    return re.test(code)
}

/** 合法url 必须带 http 或 https */
export function validateURL (text: string) {
    const regExp = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/i
    return regExp.test(text)
}

/** 小写字母 */
export function validateLowerCase (str: string) {
    const reg = /^[a-z]+$/
    return reg.test(str)
}

/** 大写字母 */
export function validateUpperCase (str: string) {
    const reg = /^[A-Z]+$/
    return reg.test(str)
}

/** 大小写字母 */
export function validateAlphabets (str: string) {
    const reg = /^[A-Za-z]+$/
    return reg.test(str)
}

/**
 * validate email
 * @param email
 * @returns {boolean}
 */
export function isValidateEmail (email: string): boolean {
    const re = 
    /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    return re.test(email)
}

/**
 * 校验 mail to
 * @param {*} str 校验字符
 * @returns Boolean
 */
export function validateMailTo (str: string) {
    const re = /^mailto:.{1,30}@.{1,40}$/
    return re.test(str)
}

/**
 * validate phone
 * @param phone
 * @returns {boolean}
 */
export function isValidPhoneNumber (phone: string): boolean {
    const reg = /^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$/
    return reg.test(phone)
}

export function isValidateEmailCode (code: string) {
    const re = /^[0-9]{6}$/
    return re.test(code)
}

/*
validate ip with subnet mask
eg: 192.168.1.0/24
*/
export function validateIPSubnetMask (ip: string) {
    const reg = /([1-9]|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])(\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])){3}\/\d+/
    return reg.test(ip)
}

/** 验证端口1 - 65535 不能有 65530 */
export function validatePortS2S (port: string) {
    // 正则表达式匹配范围 1-65535，且不等于 65530
    const validPortRegex = /^(?!65530$)([1-9]\d{0,4}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$/
    return validPortRegex.test(port)
}

/** 验证端口1 - 65535  */
export function validatePort (port: string) {
    const reg = /^([1-9](\d{0,3}))$|^([1-5]\d{4})$|^(6[0-4]\d{3})$|^(65[0-4]\d{2})$|^(655[0-2]\d)$|^(6553[0-5])$/
    return reg.test(port)
}

/**
 * validate two factor Authenticator code
 * @param code
 * @returns {boolean}
 */
export function isValidTwoFACode (code: string): boolean {
    if (code && code.length !== 6) {
        return false
    }
    const re = /^[0-9]*$/
    return re.test(code)
}

/*
validate LAN ip
127.  0.0.0 – 127.255.255.255     127.0.0.0 /8
 10.  0.0.0 –  10.255.255.255      10.0.0.0 /8
172. 16.0.0 – 172. 31.255.255    172.16.0.0 /12
192.168.0.0 – 192.168.255.255   192.168.0.0 /16
https://stackoverflow.com/questions/2814002/private-ip-address-identifier-in-regular-expression
*/
export function validateLanIP (ip: string) {
    const reg = /(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/
    return reg.test(ip)
}

// 至少需要大写字母、小写字母、数字、符号其中的两项
// eslint-disable-next-line max-len
const passwordSecurityReg = /((?=.*[!@#$%&*()+=,.\x2d\x5c\x5b\x5d\x5e?{}:"'`~])(?=.*\d))|((?=.*[!@#$%&*()+=,.\x2d\x5c\x5b\x5d\x5e?{}:"'`~])(?=.*[a-z]))|((?=.*[!@#$%&*()+=,.\x5f\x2d\x5c\x5b\x5d\x5e?{}:"'`~])(?=.*[A-Z]))|((?=.*\d)(?=.*[a-z]))|((?=.*\d)(?=.*[A-Z]))|((?=.*[a-z])(?=.*[A-Z]))/
// 允许字符，英文、数字、英文特殊字符
const allowCharacterReg = /^[!@#$%&*()+=,.\x5f\x2d\x5c\x5b\x5d\x5e\x7c?{}:"'`~a-zA-Z0-9]+$/
const checkPasswordMap = [
    {}, // 占位
    {
        allowCharacterReg,
        passwordSecurityReg,
    },
]
export const checkAllowCharacter = (value: string, index = 1) => { /** 验证是否为允许的字符 */
    if (index <= 0) {
        return allowCharacterReg.test(value)
    }
    return checkPasswordMap[index].allowCharacterReg.test(value)
}
export const checkPasswordSecurity = (value: string, index = 1) => { /** 验证是否符合字符种类 */
    if (index <= 0) {
        return true
    }
    return checkPasswordMap[index].passwordSecurityReg.test(value)
}
export enum PwdCheckType {
    CHECK_CHAR,
    CHECK_SECURITY
}
/** 校验密码 */
export const checkPassword = (type: PwdCheckType, value: any) => {
    if (type === PwdCheckType.CHECK_CHAR) {
        return checkAllowCharacter(value)
    } else {
        return checkPasswordSecurity(value)
    }
}

/** 表单校验密码公共方法 */
export const validatePasswordCommonFn = (value: string = '') => {
    // 校验长度是否不对 
    const lengthValid = value.length >= 10 && value.length <= 32
    // 校验字符规则是否满足
    const charValid = checkPassword(PwdCheckType.CHECK_CHAR, value)
    // 校验安全规则是否满足 
    const securityValid = checkPassword(PwdCheckType.CHECK_SECURITY, value)
    const validateInfos = [
        {valid: lengthValid, tip: 'login.passwordTips'},
        {valid: charValid, tip: 'login.allowPasswordTips'},
        {valid: securityValid, tip: 'login.securityPasswordTips'},
    ]
    return validateInfos
}
/** 表单校验密码确认公共方法 */
export const validateConfirmPasswordCommonFn = (password: string, confirmPassword: string) => {
    if (password === confirmPassword) {
        return Promise.resolve()
    } else {
        return Promise.reject('validate.confirmPasswordValidateError')
    }
}

// 校验子网掩码
export const validateNetmask = (ip: string) => {
    // eslint-disable-next-line max-len
    const reg = /^(254|252|248|240|224|192|128)\.0\.0\.0$|^(255\.(254|252|248|240|224|192|128|0)\.0\.0)$|^(255\.255\.(254|252|248|240|224|192|128|0)\.0)$|^(255\.255\.255\.(254|252|248|240|224|192|128|0))$/
    return reg.test(ip)
}
// 校验IP地址方法
export const validateIP = (ip: string) => {
    const reg = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/
    return reg.test(ip)
}
// ipv6 CIDR 正则
export const validateIPV6CIDR = (ip: string) => {
    const reg = /^(([0-9a-fA-F]{1,4}:){7,7}([0-9a-fA-F]{1,4}|:)|([0-9a-fA-F]{1,4}:){1,6}(:[0-9a-fA-F]{1,4}|:)|([0-9a-fA-F]{1,4}:){1,5}((:[0-9a-fA-F]{1,4}){1,2}|:)|([0-9a-fA-F]{1,4}:){1,4}((:[0-9a-fA-F]{1,4}){1,3}|:)|([0-9a-fA-F]{1,4}:){1,3}((:[0-9a-fA-F]{1,4}){1,4}|:)|([0-9a-fA-F]{1,4}:){1,2}((:[0-9a-fA-F]{1,4}){1,5}|:)|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6}|:)|:((:[0-9a-fA-F]{1,4}){1,7}|:))\/((?:[0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8]))$/
    return reg.test(ip)
}
// 校验IPV6地址方法
export const validateIPV6 = (ip: string) => {
    const reg = /^(^([0-9a-fA-F]{1,4}:){7,7}([0-9a-fA-F]{1,4}|:)|([0-9a-fA-F]{1,4}:){1,6}(:[0-9a-fA-F]{1,4}|:)|([0-9a-fA-F]{1,4}:){1,5}((:[0-9a-fA-F]{1,4}){1,2}|:)|([0-9a-fA-F]{1,4}:){1,4}((:[0-9a-fA-F]{1,4}){1,3}|:)|([0-9a-fA-F]{1,4}:){1,3}((:[0-9a-fA-F]{1,4}){1,4}|:)|([0-9a-fA-F]{1,4}:){1,2}((:[0-9a-fA-F]{1,4}){1,5}|:)|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6}|:)|:((:[0-9a-fA-F]{1,4}){1,7}|:))$/
    return reg.test(ip)
}

// 校验域名方法
export const validateDomain = (domain: string) => {
    const reg = /^([a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+)$/
    return reg.test(domain)
}

// 校验是否包含中文和中文字符
export const validateZh = (str: string) => {
    const reg = /([\u4E00-\u9FA5]|[\uFE30-\uFFA0])/gi
    return reg.test(str)
}

// 校验正整数
export const validatePositiveInteger = (str: string) => {
    const reg = /^[1-9]\d*$/
    return reg.test(str)
}
