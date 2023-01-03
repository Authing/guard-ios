//
//  Authing.swift
//  Guard
//
//  Created by Lance Mao on 2021/11/23.
//


typealias ConfigCompletion = (Config?) -> Void

public class Authing: NSObject {
    
    @objc public static let DEFAULT_PUBLIC_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4xKeUgQ+Aoz7TLfAfs9+paePb5KIofVthEopwrXFkp8OCeocaTHt9ICjTT2QeJh6cZaDaArfZ873GPUn00eOIZ7Ae+TiA2BKHbCvloW3w5Lnqm70iSsUi5Fmu9/2+68GZRH9L7Mlh8cFksCicW2Y2W2uMGKl64GDcIq3au+aqJQIDAQAB"
    
    public typealias AuthCompletion = (Int, String?, UserInfo?) -> Void
    
    @objc public static var sConfig: Config? = nil
    
    public enum NotifyName: String {
        /// wechat notification
        case notify_wechat = "wechatLoginOK"
        /// wecom register notification
        case notify_wecom_register = "WeComRegisterNotificationName"
        /// wecom receive notification
        case notify_wecom_receive = "WeComReceiveNotificationName"
        ///lark register notification
        case notify_lark_register = "LarkRegisterNotificationName"
        /// lark receive notification
        case notify_lark_receive = "LarkReceiveNotificationName"
    }
    
    private static var sSchema = "https"
    private static var sHost = "authing.cn"
    private static var pushClientId: String?
    private static var sAppId = ""
    private static var isOnPremises = false
    private static var sPublicKey = DEFAULT_PUBLIC_KEY
    private static var sCurrentUser: UserInfo?
    
    @objc public static func start(_ appid: String) {
                
        sAppId = appid
        sConfig = Config(appId: appid)
    }
    
    @objc public static func getAppId() -> String {
        return sAppId
    }
    
    @objc public static func setSchema(schema: String) {
        sSchema = schema
    }
    
    @objc public static func getSchema() -> String {
        return sSchema
    }
    
    @objc public static func setHost(host: String) {
        sHost = host
    }
    
    @objc public static func getHost() -> String {
        return sHost
    }
    
    @objc public static func getIsOnPremises() -> Bool {
        return isOnPremises
    }
    
    @objc public static func getPublicKey() -> String {
        return sPublicKey
    }
    
    @objc public static func setPushClientId(cid: String?) {
        pushClientId = cid
    }
    
    @objc public static func getPushClientId() -> String? {
        return pushClientId
    }
    
    
    @objc public static func setOnPremiseInfo(host: String, publicKey: String) {
        isOnPremises = true
        sHost = host
        sPublicKey = publicKey
    }
    
    @objc public static func getConfig(completion: @escaping(Config?)->Void) {
        if let c = sConfig {
            c.getConfig(completion: completion)
        } else {
            completion(nil)
        }
    }
    
    @objc public static func getConfigObject() -> Config? {
        return sConfig
    }
    
//    @objc public static func setupAlipay(_ appid: String, customScheme: String) {
//        Alipay.appid = appid
//        Alipay.customScheme = customScheme
//    }
    
    @objc public static func autoLogin(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        sCurrentUser = UserManager.getUser()
        if sCurrentUser == nil {
            completion(ErrorCode.login.rawValue, ErrorCode.login.errorMessage(), nil)
            return
        }
        
        if sCurrentUser?.refreshToken != nil {
            OIDCClient().getNewAccessTokenByRefreshToken(userInfo: sCurrentUser) { code, message, userInfo in
                if code == 200 {
                    AuthClient().getCurrentUser(user: sCurrentUser) { code, message, userInfo in
                        if (code != 200) {
                            clearUser(code, message, completion)
                        } else {
                            completion(code, message, userInfo)
                        }
                    }
                } else {
                    clearUser(code, message, completion)
                }
            }
        } else {
            AuthClient().getCurrentUser(user: sCurrentUser) { code, message, userInfo in
                if (code != 200) {
                    clearUser(code, message, completion)
                } else {
                    AuthClient().updateIdToken(completion: completion)
                }
            }
        }
    }
    
    @objc private static func clearUser(_ code: Int, _ message: String?, _ completion: @escaping(Int, String?, UserInfo?) -> Void) {
        UserManager.removeUser()
        sCurrentUser = nil
        completion(code, message, nil)
    }
    
    @objc public static func getCurrentUser() -> UserInfo? {
        return sCurrentUser
    }
    
    @objc public static func saveUser(_ userInfo: UserInfo?) {
        sCurrentUser = userInfo
        // TODO save to user defaults then Core Data
        UserManager.saveUser(sCurrentUser)
    }
}
