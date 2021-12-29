//
//  AuthClient.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import Foundation

public class AuthClient {
    
    public static func sendSms(phone: String, completion: @escaping(Int, String?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())")
                return
            }
            let url: String = "https://" + (config?.identifier)! + "." + Authing.getHost() + "/api/v2/sms/send";
            let body: NSDictionary = ["phone" : phone]
            Guardian.post(urlString: url, body: body) { code, message, data in
                completion(code, message)
            }
        }
    }
    
    public static func loginByPhoneCode(phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
            let url: String = "https://" + (config?.identifier)! + "." + Authing.getHost() + "/api/v2/login/phone-code";
            let body: NSDictionary = ["phone" : phone, "code" : code]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let userInfo: UserInfo = createUserInfo(data!)
                    completion(code, message, userInfo)
                } else {
                    completion(code, message, nil)
                }
            }
        }
    }
    
    public static func loginByAccount(account: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
            let url: String = "https://" + (config?.identifier)! + "." + Authing.getHost() + "/api/v2/login/account";
            let encryptedPassword = Util.encryptPassword(password)
            let body: NSDictionary = ["account" : account, "password" : encryptedPassword]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let userInfo: UserInfo = createUserInfo(data!)
                    completion(code, message, userInfo)
                } else {
                    completion(code, message, nil)
                }
            }
        }
    }
    
    public static func loginByOneAuth(token: String, accessToken: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
            let url: String = "https://" + (config?.identifier)! + "." + Authing.getHost() + "/api/v2/ecConn/oneAuth/login";
//            let url: String = "https://developer-beta.authing.cn/stats/ydtoken"
            let body: NSDictionary = ["token" : token, "accessToken" : accessToken]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let userInfo: UserInfo = createUserInfo(data!)
                    completion(code, message, userInfo)
                } else {
                    completion(code, message, nil)
                }
            }
        }
    }
    
    public static func registerByPhoneCode(phone: String, password: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
            let url: String = "https://" + (config?.identifier)! + "." + Authing.getHost() + "/api/v2/register/phone-code";
            let encryptedPassword = Util.encryptPassword(password)
            let body: NSDictionary = ["phone" : phone, "password" : encryptedPassword, "code" : code]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let userInfo: UserInfo = createUserInfo(data!)
                    completion(code, message, userInfo)
                } else {
                    completion(code, message, nil)
                }
            }
        }
    }
    
    public static func registerByEmail(email: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
            let url: String = "https://" + (config?.identifier)! + "." + Authing.getHost() + "/api/v2/register/email";
            let encryptedPassword = Util.encryptPassword(password)
            let body: NSDictionary = ["email" : email, "password" : encryptedPassword]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let loginUrl: String = "https://" + (config?.identifier)! + "." + Authing.getHost() + "/api/v2/login/account";
                    let loginBody: NSDictionary = ["account" : email, "password" : encryptedPassword]
                    Guardian.post(urlString: loginUrl, body: loginBody) { code, message, data in
                        if (code == 200) {
                            let userInfo: UserInfo = createUserInfo(data!)
                            completion(code, message, userInfo)
                        } else {
                            completion(code, message, nil)
                        }
                    }
                } else {
                    completion(code, message, nil)
                }
            }
        }
    }
    
    public static func createUserInfo(_ data: NSDictionary) -> UserInfo {
        let userInfo: UserInfo = UserInfo.parse(data: data)
        return userInfo
    }
}
