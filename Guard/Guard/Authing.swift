//
//  Authing.swift
//  Guard
//
//  Created by Lance Mao on 2021/11/23.
//

import Foundation

typealias ConfigCompletion = (Config?) -> Void

public class Authing {
    private static var sSchema = "https"
    private static var sHost = "authing.cn"
    private static var sAppId = ""
    private static var sConfig: Config? = nil
    private static var isGettingConfig: Bool = false
    private static var configListeners = [ConfigCompletion]()
    private static var sCurrentUser: UserInfo?
    
    public static func start(_ appid: String) {
        sAppId = appid
        requestPublicConfig()
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
    
    public static func getConfig(completion: @escaping(Config?)->Void) {
        // add listener first. otherwise callback might be fired in the other thread
        // and this listener is missed
        if (isGettingConfig) {
            configListeners.append(completion);
        }
        
        if (sConfig != nil) {
            configListeners.removeAll()
            completion(sConfig)
        }
    }
    
    public static func setupWechat(_ appid: String, universalLink: String) {
        let ret = WXApi.registerApp(appid, universalLink: universalLink)
        if (!ret) {
            print("set up wechat failed!")
        }
    }
    
    public static func setupAlipay(_ appid: String, customScheme: String) {
        Alipay.appid = appid
        Alipay.customScheme = customScheme
    }
    
    public static func autoLogin(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        if (getCurrentUser() == nil) {
            completion(500, "no user logged in", nil)
        } else {
            AuthClient.getCurrentUser { code, message, userInfo in
                if (code != 200) {
                    UserManager.removeUser()
                    sCurrentUser = nil
                    completion(code, message, nil)
                } else {
                    AuthClient.updateIdToken(completion: completion)
                }
            }
        }
    }
    
    public static func getCurrentUser() -> UserInfo? {
        if (sCurrentUser == nil) {
            sCurrentUser = UserManager.getUser()
        }
        return sCurrentUser
    }
    
    public static func saveUser(_ userInfo: UserInfo?) {
        sCurrentUser = userInfo
        // TODO save to user defaults then Core Data
        UserManager.saveUser(sCurrentUser)
    }
    
    private static func requestPublicConfig() {
        isGettingConfig = true
        sConfig = nil
        let url = "https://console." + sHost + "/api/v2/applications/" + sAppId + "/public-config"
        Guardian.request(config: nil, urlString: url, method: "get", body: nil) { code, message, jsonData in
            if (code == 200) {
                sConfig = Config()
                sConfig!.data = jsonData

                fireCallback()
            } else {
                print("error when getting public cofig:\(message!)")
                fireCallback()
            }
        }
    }
    
    private static func fireCallback() {
        DispatchQueue.main.async() {
            for completion in configListeners {
                completion(sConfig)
            }
            isGettingConfig = false
            configListeners.removeAll()
        }
    }
}
