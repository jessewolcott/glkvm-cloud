/*
 * @Author: LPY
 * @Date: 2025-06-03 10:36:35
 * @LastEditors: LPY
 * @LastEditTime: 2025-08-22 11:20:58
 * @FilePath: \glkvm-cloud\web-ui\src\models\request.ts
 * @Description: 请求相关类型声明
 */
export enum RequestErrorCodeEnum {
  /** ------------------------------------------------ 通用错误码 ------------------------------------------------ */
  SUCCESS = 0,
  /** 系统调用失败 */
  FAILED = -1,
  /** 请重新登录确认用户身份 */
  SEND_EMAIL_OR_PHONE_FAILED = -999,
  /** 服务器异常 */
  SERVER_ERROR_OLD = -1001,
  /** token 异常 */
  INVALID_TOKEN_OLD_1 = -1002,
  /** 没有权限 */
  PERMISSION_ERROR_OLD = -1003,
  /** token 失效 */
  INVALID_TOKEN_OLD_2 = -1004,
  /** 参数丢失 */
  MISS_PARAM = -1005,
  /** 重复操作 */
  DUPLICATE_OPERATION = -1006,
  /** 输入参数错误 */
  INPUT_PARAM_ERROR = -1007,
  /** 服务器忙，请稍后再试 */
  INVALID_TOKEN_OLD_3 = -1008,
  /** 消息过期 */
  MESSAGE_EXPIRED_ERROR = -1009,
  /** 账号已在其它地方登录 */
  ACCOUNT_LOGIN_ELSEWHERE = -1010,
  /** 登录过期 */
  AUTHENTICATION_TOKEN_EXPIRED = -1011,
  /** 验证密码错误 */
  VALIDATE_PASSWORD_ERR = -1012,
  /** 密码特殊符号错误 */
  PASSWORD_SPECIAL_SYMBOLS_ERR = -1013,
  /** 密码强度错误 */
  PASSWORD_STRENGTH_ERR = -1014,
  /** 请求忙错误 */
  REQUEST_BUSY_ERROR_OLD = -1015,
  /** 数据用户不匹配 */
  DATA_USER_NOT_MATCH = -1021,
  /** xss攻击 */
  DATA_XSS_CHECK_FAILED = -1022,
  /** 授权超时 */
  AUTH_TIME_OUT = -1023,
  /** 登录账号密码错误 */
  USERNAME_OR_PASSWORD_ERROR = -2001,
  /** 用户不存在 */
  USER_NOT_EXIST = -2002,
  /** 密码不一致 */
  USER_PASSWORD_NOT_MATCH_OLD = -2003,
  /** 密码错误 */
  USER_PASSWORD_ERROR = -2004,
  /** 该用户名已被注册 */
  USER_NAME_EXISTS = -2005,
  /** 该邮箱已被注册 */
  USER_EMAIL_EXISTS = -2006,
  /** 邮箱验证码错误 */
  USER_EMAIL_CODE_ERROR = -2007,
  /** 邮箱错误 */
  USER_EMAIL_INCORRECT = -2008,
  /** 邮箱验证码已过期 */
  USER_EMAIL_EXPIRED = -2009,
  /** 账户需进行两步验证 */
  USER_TWO_FAC_AUTH = -2010,
  /** 两步验证码错误 */
  USER_2FA_ERROR = -2011,
  /** 密码多次错误，禁止登录 */
  BLOCKED_BY_WRONG_PASSWORD = -2012,
  /** 发送邮件验证码失败 */
  USER_EMAIL_NOT_YOURS = -2013,
  /** 手机验证码已过期 */
  USER_PHONE_EXPIRED = -2014,
  /** 手机验证码错误 */
  USER_PHONE_CODE_ERROR = -2015,
  /** 当前手机号不是你的 */
  USER_PHONE_NOT_YOURS = -2016,
  /** 手机号已存在 */
  USER_PHONE_EXISTS = -2017,
  /** 手机号不存在 */
  USER_PHONE_NOT_EXISTS = -2018,
  /** 登录次数过多，账号已被锁定，请稍后再试 */
  USERNAME_OR_PASSWORD_WITH_COUNT_ERROR = -2019,
  /** 验证码发送超过限制条数 */
  LIMIT_CONTROL = -2020,
  /** 登录区域不匹配 */
  REGION_INFO_INCORRECT = -2021,
  /** 验证代码计数错误 */
  VERIFICATION_CODE_COUNT_ERROR = -2022,
  /**  */

 
  /** 系统错误，多出现于系统重启，及捕获到未定义的异常 */
  SERVER_ERROR = 10000001,
  /** token无效 */
  INVALID_TOKEN = 10000002,
  /** 权限错误 */
  PERMISSION_ERROR = 10000003,
  /** 数据错误 */
  DATA_ERROR = 10000004,
  /** 设备离线 */
  DEVICE_OFFLINE = 10000005,
  /** 参数错误 */
  PARAM_ERROR = 10000006,
  /** 需要进行人机验证 */
  NEED_RECAPTCHA = 10000007,
  /** 人机验证未通过错误 */
  RECAPTCHA_ERROR = 10000008,
  /** 频繁提交，用于限流 */
  REQUEST_BUSY_ERROR = 10000015,
  /** 请求类型错误，用于返回json无法满足需求的请求 */
    MEDIA_TYPE_ERROR = 10000035,
  /** 查询时间范围超限 */
  TIME_RANGE_ERROR = 10000036,
  /** 重复数据 */
  DUPLICATE_ENTRY = 10000038,
  /** 参数错误 */
  PARAM_TYPE_ERROR = 10000039,
  /** 数据依赖 */
  DATA_DEPEND = 10000040,
  /** 信息错误 */
  INFO_INCORRECT = 10000041,
  /** token过期 */
  EXPIRED_TOKEN = 10000042,
  /** 不支持的文件格式 */
  FILE_TYPE_NOT_SUPPORTED = 10000043,
  /** 主题不能为空 */
  SUBJECT_NOT_NULL = 10000044,
  /** 描述不能为空 */
  DESCRIPTION_NOT_NULL = 10000045,
  /** 发送邮件失败 */
  EMAIL_SEND_ERROR = 10000046,
  /** 上传图片校验异常 */
  UPLOAD_IMAGE_CHECK_EXCEPTION = 10000047,
  /** 上传图片失败 */
  UPLOAD_IMAGE_FAIL = 10000048,
  /** 请求方法不合法（与设定的方法不一致） */
  REQUEST_METHOD_ERROR = 10000049,
  /** 邮箱格式不正确 */
  INCORRECT_MAILBOX_FORMAT = 10000050,
  /** 重复请求验证码 */
  REPEAT_REQUEST_VERIFICATION_CODE = 10000052,
  

  /** ------------------------------------------------ 云平台用户相关错误码 ------------------------------------------------ */
  /** 要修改的用户数据不存在 */
  USER_DATA_TO_BE_MODIFIED_NOT_EXIST = 10001001,
  /** 用户对象信息为空 */
  USER_OBJECT_INFO_EMPTY = 10001002,
  /** 用户ID不能为空 */
  USER_ID_NOT_NULL = 10001003, 
  /** 用户发送模式为空 */
  USER_SEND_MODE_EMPTY = 10001004,
  /** 收件人ID为空 */
  USER_RECIPIENT_ID_EMPTY = 10001005,
  /** 用户发送状态空 */
  USER_SEND_STATUS_EMPTY = 10001006,
  /** 用户标识为空 */
  USER_ID_EMPTY = 10001007,
  /** 用户名为空 */
  USER_USERNAME_EMPTY = 10001008,
  /** 用户电话空 */
  USER_PHONE_EMPTY = 10001009,
  /** 用户电子邮件空 */
  USER_EMAIL_EMPTY = 10001010,
  /** 用户更新电子邮件空 */
  USER_UPDATE_EMAIL_EMPTY = 10001011,
  /** 更新用户token空 */
  USER_UPDATE_USER_TOKEN_EMPTY = 10001012,
  /** 用户代码为空 */
  USER_CODE_EMPTY = 10001013,
  /** 用户输入用户信息 */
  USER_ENTER_USER_INFO = 10001014,
  /** 用户帐户为空 */
  USER_ACCOUNT_EMPTY = 10001015,
  /** 密码为空 */
  USER_PASSWORD_EMPTY = 10001016,
  /** 用户不存在 */
  USER_NOT_EXISTS = 10001019,
  /** 用户标识为空 */
  USER_USER_ID_EMPTY = 10001020,
  /** 用户角色为空 */
  USER_USER_ROLE_EMPTY = 10001021,
  /**  用户不能删除自己  */
  USER_CANNOT_DELETE_YOURSELF = 10001023,
  /** 用户不能删除管理员 */
  USER_CANNOT_DELETE_ADMINISTRATOR = 10001024,
  /** 用户非法邮件地址 */
  USER_ILLEGAL_MAIL_ADDRESS = 10001027,
  /** 用户非法电话号码 */
  USER_ILLEGAL_PHONE_NUMBER = 10001028,
  /** 用户角色空 */
  USER_ROLES_EMPTY = 10001029,
  /** 用户密码为空 */
  USER_RE_PASSWORD_EMPTY = 10001032,
  /** 用户非法用户名 */
  USER_ILLEGAL_USERNAME = 10001033,
  /** 用户密码不匹配 */
  USER_PASSWORD_NOT_MATCH = 10001034,
  /** 用户用户名存在 */
  USER_USERNAME_EXISTS = 10001035,
  /** 用户选择角色 */
  USER_SELECT_ROLE = 10001041,
  /** 用户不存在 */
  USER_USER_NOT_EXIST = 10001043,
  /** 用户密码重置链接过期 */
  USER_PASSWORD_RESET_LINK_EXPIRED = 10001044,
  /** 用户非法角色 */
  USER_ILLEGAL_ROLE = 10001045,
  /** 电子邮件验证码错误 */
  EMAIL_CAPTCHA_CODE_ERROR = 10001046,
  /** 电子邮件验证码过期 */
  EMAIL_CAPTCHA_CODE_EXPIRED = 10001047,
  /** 短信发送失败 */
  SMS_SENDING_FAILED = 10001048,
  /** 电子邮件不能被修改 */
  EMAIL_CANNOT_BE_MODIFIED = 10001049,
  /** 帐户注销链接过期 */
  ACCOUNT_CANCELLATION_LINK_EXPIRED = 10001050,
  /** 邮箱不属于该用户名 */
  CLOUD_EMAIL_NOT_MATCH_USER = 10019001,
  /** CLOUD用户不存在 */
  CLOUD_USER_NOT_EXIST = 10019002,

  /** ------------------------------------------------ 项目独有错误码 ------------------------------------------------ */
}

export const RequestErrorCodeMap = new Map([
    /** ------------------------------------------------ 通用错误码 ------------------------------------------------ */
    [RequestErrorCodeEnum.FAILED, 'FAILED'],
    [RequestErrorCodeEnum.SEND_EMAIL_OR_PHONE_FAILED, 'SEND_EMAIL_OR_PHONE_FAILED'],
    [RequestErrorCodeEnum.SERVER_ERROR_OLD, 'SERVER_ERROR'],
    [RequestErrorCodeEnum.INVALID_TOKEN_OLD_1, 'INVALID_TOKEN'],
    [RequestErrorCodeEnum.PERMISSION_ERROR_OLD, 'PERMISSION_ERROR'],
    [RequestErrorCodeEnum.INVALID_TOKEN_OLD_2, 'INVALID_TOKEN'],
    [RequestErrorCodeEnum.MISS_PARAM, 'MISS_PARAM'],
    [RequestErrorCodeEnum.DUPLICATE_OPERATION, 'DUPLICATE_OPERATION'],
    [RequestErrorCodeEnum.INPUT_PARAM_ERROR, 'INPUT_PARAM_ERROR'],
    [RequestErrorCodeEnum.INVALID_TOKEN_OLD_3, 'INVALID_TOKEN'],
    [RequestErrorCodeEnum.MESSAGE_EXPIRED_ERROR, 'MESSAGE_EXPIRED_ERROR'],
    [RequestErrorCodeEnum.ACCOUNT_LOGIN_ELSEWHERE, 'ACCOUNT_LOGIN_ELSEWHERE'],
    [RequestErrorCodeEnum.AUTHENTICATION_TOKEN_EXPIRED, 'AUTHENTICATION_TOKEN_EXPIRED'],
    [RequestErrorCodeEnum.VALIDATE_PASSWORD_ERR, 'VALIDATE_PASSWORD_ERR'],
    [RequestErrorCodeEnum.PASSWORD_SPECIAL_SYMBOLS_ERR, 'PASSWORD_SPECIAL_SYMBOLS_ERR'],
    [RequestErrorCodeEnum.PASSWORD_STRENGTH_ERR, 'PASSWORD_STRENGTH_ERR'],
    [RequestErrorCodeEnum.REQUEST_BUSY_ERROR_OLD, 'REQUEST_BUSY_ERROR'],
    [RequestErrorCodeEnum.DATA_USER_NOT_MATCH, 'DATA_USER_NOT_MATCH'],
    [RequestErrorCodeEnum.DATA_XSS_CHECK_FAILED, 'DATA_XSS_CHECK_FAILED'],
    [RequestErrorCodeEnum.AUTH_TIME_OUT, 'AUTH_TIME_OUT'],
    [RequestErrorCodeEnum.USERNAME_OR_PASSWORD_ERROR, 'USERNAME_OR_PASSWORD_ERROR'],
    [RequestErrorCodeEnum.USER_NOT_EXIST, 'USER_NOT_EXIST'],
    [RequestErrorCodeEnum.USER_PASSWORD_NOT_MATCH_OLD, 'USER_PASSWORD_NOT_MATCH'],
    [RequestErrorCodeEnum.USER_PASSWORD_ERROR, 'USER_PASSWORD_ERROR'],
    [RequestErrorCodeEnum.USER_NAME_EXISTS, 'USER_NAME_EXISTS'],
    [RequestErrorCodeEnum.USER_EMAIL_EXISTS, 'USER_EMAIL_EXISTS'],
    [RequestErrorCodeEnum.USER_EMAIL_CODE_ERROR, 'USER_EMAIL_CODE_ERROR'],
    [RequestErrorCodeEnum.USER_EMAIL_INCORRECT, 'USER_EMAIL_INCORRECT'],
    [RequestErrorCodeEnum.USER_EMAIL_EXPIRED, 'USER_EMAIL_EXPIRED'],
    [RequestErrorCodeEnum.USER_TWO_FAC_AUTH, 'USER_TWO_FAC_AUTH'],
    [RequestErrorCodeEnum.USER_2FA_ERROR, 'USER_2FA_ERROR'],
    // [RequestErrorCodeEnum.BLOCKED_BY_WRONG_PASSWORD, 'BLOCKED_BY_WRONG_PASSWORD'],
    [RequestErrorCodeEnum.USER_EMAIL_NOT_YOURS, 'USER_EMAIL_NOT_YOURS'],
    [RequestErrorCodeEnum.USER_PHONE_EXPIRED, 'USER_PHONE_EXPIRED'],
    [RequestErrorCodeEnum.USER_PHONE_CODE_ERROR, 'USER_PHONE_CODE_ERROR'],
    [RequestErrorCodeEnum.USER_PHONE_NOT_YOURS, 'USER_PHONE_NOT_YOURS'],
    [RequestErrorCodeEnum.USER_PHONE_EXISTS, 'USER_PHONE_EXISTS'],
    [RequestErrorCodeEnum.USER_PHONE_NOT_EXISTS, 'USER_PHONE_NOT_EXISTS'],
    [RequestErrorCodeEnum.USERNAME_OR_PASSWORD_WITH_COUNT_ERROR, 'USERNAME_OR_PASSWORD_WITH_COUNT_ERROR'],
    [RequestErrorCodeEnum.LIMIT_CONTROL, 'LIMIT_CONTROL'],
    [RequestErrorCodeEnum.REGION_INFO_INCORRECT, 'REGION_INFO_INCORRECT'],
    [RequestErrorCodeEnum.VERIFICATION_CODE_COUNT_ERROR, 'VERIFICATION_CODE_COUNT_ERROR'],
    [RequestErrorCodeEnum.SERVER_ERROR, 'SERVER_ERROR'],
    [RequestErrorCodeEnum.INVALID_TOKEN, 'INVALID_TOKEN'],
    [RequestErrorCodeEnum.PERMISSION_ERROR, 'PERMISSION_ERROR'],
    [RequestErrorCodeEnum.DATA_ERROR, 'DATA_ERROR'],
    [RequestErrorCodeEnum.DEVICE_OFFLINE, 'DEVICE_OFFLINE'],
    [RequestErrorCodeEnum.PARAM_ERROR, 'PARAM_ERROR'],
    [RequestErrorCodeEnum.NEED_RECAPTCHA, 'NEED_RECAPTCHA'],
    [RequestErrorCodeEnum.RECAPTCHA_ERROR, 'RECAPTCHA_ERROR'],
    [RequestErrorCodeEnum.REQUEST_BUSY_ERROR, 'REQUEST_BUSY_ERROR'],
    // [RequestErrorCodeEnum.MEDIA_TYPE_ERROR, 'MEDIA_TYPE_ERROR'],
    // [RequestErrorCodeEnum.TIME_RANGE_ERROR, 'TIME_RANGE_ERROR'],
    [RequestErrorCodeEnum.DUPLICATE_ENTRY, 'DUPLICATE_ENTRY'],
    // [RequestErrorCodeEnum.PARAM_TYPE_ERROR, 'PARAM_TYPE_ERROR'],
    [RequestErrorCodeEnum.DATA_DEPEND, 'DATA_DEPEND'],
    [RequestErrorCodeEnum.INFO_INCORRECT, 'INFO_INCORRECT'],
    // [RequestErrorCodeEnum.EXPIRED_TOKEN, 'EXPIRED_TOKEN'],
    // [RequestErrorCodeEnum.FILE_TYPE_NOT_SUPPORTED, 'FILE_TYPE_NOT_SUPPORTED'],
    // [RequestErrorCodeEnum.SUBJECT_NOT_NULL, 'SUBJECT_NOT_NULL'],
    // [RequestErrorCodeEnum.DESCRIPTION_NOT_NULL, 'DESCRIPTION_NOT_NULL'],
    // [RequestErrorCodeEnum.EMAIL_SEND_ERROR, 'EMAIL_SEND_ERROR'],
    [RequestErrorCodeEnum.UPLOAD_IMAGE_CHECK_EXCEPTION, 'UPLOAD_IMAGE_CHECK_EXCEPTION'],
    [RequestErrorCodeEnum.UPLOAD_IMAGE_FAIL, 'UPLOAD_IMAGE_FAIL'],
    // [RequestErrorCodeEnum.REQUEST_METHOD_ERROR, 'REQUEST_METHOD_ERROR'],
    // [RequestErrorCodeEnum.INCORRECT_MAILBOX_FORMAT, 'INCORRECT_MAILBOX_FORMAT'],
    [RequestErrorCodeEnum.REPEAT_REQUEST_VERIFICATION_CODE, 'REPEAT_REQUEST_VERIFICATION_CODE'],
    [RequestErrorCodeEnum.USER_DATA_TO_BE_MODIFIED_NOT_EXIST, 'USER_DATA_TO_BE_MODIFIED_NOT_EXIST'],
    [RequestErrorCodeEnum.USER_OBJECT_INFO_EMPTY, 'USER_OBJECT_INFO_EMPTY'],
    [RequestErrorCodeEnum.USER_ID_NOT_NULL, 'USER_ID_NOT_NULL'],
    [RequestErrorCodeEnum.USER_SEND_MODE_EMPTY, 'USER_SEND_MODE_EMPTY'],
    [RequestErrorCodeEnum.USER_RECIPIENT_ID_EMPTY, 'USER_RECIPIENT_ID_EMPTY'],
    [RequestErrorCodeEnum.USER_SEND_STATUS_EMPTY, 'USER_SEND_STATUS_EMPTY'],
    [RequestErrorCodeEnum.USER_ID_EMPTY, 'USER_ID_EMPTY'],
    [RequestErrorCodeEnum.USER_USERNAME_EMPTY, 'USER_USERNAME_EMPTY'],
    [RequestErrorCodeEnum.USER_PHONE_EMPTY, 'USER_PHONE_EMPTY'],
    [RequestErrorCodeEnum.USER_EMAIL_EMPTY, 'USER_EMAIL_EMPTY'],
    [RequestErrorCodeEnum.USER_UPDATE_EMAIL_EMPTY, 'USER_UPDATE_EMAIL_EMPTY'],
    [RequestErrorCodeEnum.USER_UPDATE_USER_TOKEN_EMPTY, 'USER_UPDATE_USER_TOKEN_EMPTY'],
    [RequestErrorCodeEnum.USER_CODE_EMPTY, 'USER_CODE_EMPTY'],
    [RequestErrorCodeEnum.USER_ENTER_USER_INFO, 'USER_ENTER_USER_INFO'],
    [RequestErrorCodeEnum.USER_ACCOUNT_EMPTY, 'USER_ACCOUNT_EMPTY'],
    [RequestErrorCodeEnum.USER_PASSWORD_EMPTY, 'USER_PASSWORD_EMPTY'],
    [RequestErrorCodeEnum.USER_NOT_EXISTS, 'USER_NOT_EXISTS'],
    [RequestErrorCodeEnum.USER_USER_ID_EMPTY, 'USER_USER_ID_EMPTY'],
    [RequestErrorCodeEnum.USER_USER_ROLE_EMPTY, 'USER_USER_ROLE_EMPTY'],
    [RequestErrorCodeEnum.USER_CANNOT_DELETE_YOURSELF, 'USER_CANNOT_DELETE_YOURSELF'],
    [RequestErrorCodeEnum.USER_CANNOT_DELETE_ADMINISTRATOR, 'USER_CANNOT_DELETE_ADMINISTRATOR'],
    [RequestErrorCodeEnum.USER_ILLEGAL_MAIL_ADDRESS, 'USER_ILLEGAL_MAIL_ADDRESS'],
    [RequestErrorCodeEnum.USER_ILLEGAL_PHONE_NUMBER, 'USER_ILLEGAL_PHONE_NUMBER'],
    [RequestErrorCodeEnum.USER_ROLES_EMPTY, 'USER_ROLES_EMPTY'],
    [RequestErrorCodeEnum.USER_RE_PASSWORD_EMPTY, 'USER_RE_PASSWORD_EMPTY'],
    [RequestErrorCodeEnum.USER_ILLEGAL_USERNAME, 'USER_ILLEGAL_USERNAME'],
    [RequestErrorCodeEnum.USER_PASSWORD_NOT_MATCH, 'USER_PASSWORD_NOT_MATCH'],
    [RequestErrorCodeEnum.USER_USERNAME_EXISTS, 'USER_USERNAME_EXISTS'],
    [RequestErrorCodeEnum.USER_SELECT_ROLE, 'USER_SELECT_ROLE'],
    [RequestErrorCodeEnum.USER_USER_NOT_EXIST, 'USER_USER_NOT_EXIST'],
    [RequestErrorCodeEnum.USER_PASSWORD_RESET_LINK_EXPIRED, 'USER_PASSWORD_RESET_LINK_EXPIRED'],
    [RequestErrorCodeEnum.USER_ILLEGAL_ROLE, 'USER_ILLEGAL_ROLE'],
    [RequestErrorCodeEnum.EMAIL_CAPTCHA_CODE_ERROR, 'EMAIL_CAPTCHA_CODE_ERROR'],
    [RequestErrorCodeEnum.EMAIL_CAPTCHA_CODE_EXPIRED, 'EMAIL_CAPTCHA_CODE_EXPIRED'],
    // [RequestErrorCodeEnum.SMS_SENDING_FAILED, 'SMS_SENDING_FAILED'],
    // [RequestErrorCodeEnum.EMAIL_CANNOT_BE_MODIFIED, 'EMAIL_CANNOT_BE_MODIFIED'],
    [RequestErrorCodeEnum.ACCOUNT_CANCELLATION_LINK_EXPIRED, 'ACCOUNT_CANCELLATION_LINK_EXPIRED'],
    [RequestErrorCodeEnum.CLOUD_EMAIL_NOT_MATCH_USER, 'CLOUD_EMAIL_NOT_MATCH_USER'],
    [RequestErrorCodeEnum.CLOUD_USER_NOT_EXIST, 'CLOUD_USER_NOT_EXIST'],

    /** ------------------------------------------------ 项目独有错误码 ------------------------------------------------ */
])

export const NotNeedHandledRequestErrorCodeList = [
    /** ------------------------------------------------ 通用错误码 ------------------------------------------------ */
    RequestErrorCodeEnum.USER_TWO_FAC_AUTH,
    RequestErrorCodeEnum.AUTHENTICATION_TOKEN_EXPIRED,
    RequestErrorCodeEnum.BLOCKED_BY_WRONG_PASSWORD,
    RequestErrorCodeEnum.NEED_RECAPTCHA,
    
    /** ------------------------------------------------ 项目独有错误码 ------------------------------------------------ */
]

