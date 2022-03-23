//
//  Authing.swift
//  Guard
//
//  Created by Lance Mao on 2021/11/23.
//

import Foundation

typealias ConfigCompletion = (Config?) -> Void

public class Guard {
    
    public static let DEFAULT_PUBLIC_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4xKeUgQ+Aoz7TLfAfs9+paePb5KIofVthEopwrXFkp8OCeocaTHt9ICjTT2QeJh6cZaDaArfZ873GPUn00eOIZ7Ae+TiA2BKHbCvloW3w5Lnqm70iSsUi5Fmu9/2+68GZRH9L7Mlh8cFksCicW2Y2W2uMGKl64GDcIq3au+aqJQIDAQAB"
    
    public typealias AuthCompletion = (Int, String?, UserInfo?) -> Void
    
    public static var sConfig: Config? = nil
    
    public enum NotifyName: String {
        ///企业微信通知 用于 Guard 向 WeCom 发送点击事件
        case notify_wecom_register = "RegisterNotificationName"
        ///企业微信通知 用于 WeCom 向 Guard 返回回调信息
        case notify_wecom_Receive = "ReceiveNotificationName"
        case notify_wechat
    }
    
    private static var sSchema = "https"
    private static var sHost = "authing.cn"
    private static var sAppId = ""
    private static var sPublicKey = DEFAULT_PUBLIC_KEY
    private static var sCurrentUser: UserInfo?
    
    public static func start(_ appid: String) {
        sAppId = appid
        sConfig = Config(appId: appid)
        SDKUsageTask.report();
    }
    
    public static func getAppId() -> String {
        return sAppId
    }
    
    public static func setSchema(schema: String) {
        sSchema = schema
    }
    
    public static func getSchema() -> String {
        return sSchema
    }
    
    public static func setHost(host: String) {
        sHost = host
    }
    
    public static func getHost() -> String {
        return sHost
    }
    
    public static func getPublicKey() -> String {
        return sPublicKey
    }
    
    public static func setOnPremiseInfo(host: String, publicKey: String) {
        sHost = host
        sPublicKey = publicKey
    }
    
    public static func getConfig(completion: @escaping(Config?)->Void) {
        if let c = sConfig {
            c.getConfig(completion: completion)
        } else {
            completion(nil)
        }
    }
    
    public static func getConfigObject() -> Config? {
        return sConfig
    }
    
    public static func setupWechat(_ appid: String, universalLink: String) {
        let ret = WXApi.registerApp(appid, universalLink: universalLink)
        if (!ret) {
            print("set up wechat failed!")
        }
    }
    
//    public static func setupAlipay(_ appid: String, customScheme: String) {
//        Alipay.appid = appid
//        Alipay.customScheme = customScheme
//    }
    
    public static func autoLogin(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        sCurrentUser = UserManager.getUser()
        if sCurrentUser != nil {
            AuthClient().getCurrentUser { code, message, userInfo in
                if (code != 200) {
                    UserManager.removeUser()
                    sCurrentUser = nil
                    completion(code, message, nil)
                } else {
                    AuthClient().updateIdToken(completion: completion)
                }
            }
        } else {
            completion(500, "no user logged in", nil)
        }
    }
    
    public static func getCurrentUser() -> UserInfo? {
        return sCurrentUser
    }
    
    public static func saveUser(_ userInfo: UserInfo?) {
        sCurrentUser = userInfo
        // TODO save to user defaults then Core Data
        UserManager.saveUser(sCurrentUser)
    }
}
