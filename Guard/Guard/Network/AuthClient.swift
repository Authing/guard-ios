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
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/sms/send";
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
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/login/phone-code";
            let body: NSDictionary = ["phone" : phone, "code" : code]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let userInfo = createUserInfo(data)
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
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/login/account";
            let encryptedPassword = Util.encryptPassword(password)
            let body: NSDictionary = ["account" : account, "password" : encryptedPassword]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let userInfo = createUserInfo(data)
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
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/ecConn/oneAuth/login";
            let body: NSDictionary = ["token" : token, "accessToken" : accessToken]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let userInfo = createUserInfo(data)
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
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/register/phone-code";
            let encryptedPassword = Util.encryptPassword(password)
            let body: NSDictionary = ["phone" : phone, "password" : encryptedPassword, "code" : code]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let userInfo = createUserInfo(data)
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
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/register/email";
            let encryptedPassword = Util.encryptPassword(password)
            let body: NSDictionary = ["email" : email, "password" : encryptedPassword]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let loginUrl: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/login/account";
                    let loginBody: NSDictionary = ["account" : email, "password" : encryptedPassword]
                    Guardian.post(urlString: loginUrl, body: loginBody) { code, message, data in
                        if (code == 200) {
                            let userInfo = createUserInfo(data)
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
    
    public static func sendResetPasswordEmail(email: String, completion: @escaping(Int, String?) -> Void) {
        sendEmail(email: email, scene: "RESET_PASSWORD", completion: completion)
    }
    
    public static func sendMFAEmail(email: String, completion: @escaping(Int, String?) -> Void) {
        sendEmail(email: email, scene: "MFA_VERIFY", completion: completion)
    }
    
    public static func sendEmail(email: String, scene: String, completion: @escaping(Int, String?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())")
                return
            }
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/email/send";
            let body: NSDictionary = ["email" : email, "scene" : scene]
            Guardian.post(urlString: url, body: body) { code, message, data in
                completion(code, message)
            }
        }
    }
    
    public static func resetPasswordByEmail(email: String, newPassword: String, code: String, completion: @escaping(Int, String?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())")
                return
            }
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/password/reset/email";
            let encryptedPassword = Util.encryptPassword(newPassword)
            let body: NSDictionary = ["email" : email, "code" : code, "newPassword" : encryptedPassword]
            Guardian.post(urlString: url, body: body) { code, message, data in
                completion(code, message)
            }
        }
    }
    
    public static func resetPasswordByPhone(phone: String, newPassword: String, code: String, completion: @escaping(Int, String?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())")
                return
            }
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/password/reset/sms";
            let encryptedPassword = Util.encryptPassword(newPassword)
            let body: NSDictionary = ["phone" : phone, "code" : code, "newPassword" : encryptedPassword]
            Guardian.post(urlString: url, body: body) { code, message, data in
                completion(code, message)
            }
        }
    }
    
    public static func getCurrentUserInfo(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/users/me";
            Guardian.get(urlString: url) { code, message, data in
                if (code == 200) {
                    let userInfo = createUserInfo(data)
                    completion(code, message, userInfo)
                } else {
                    completion(code, message, nil)
                }
            }
        }
    }
    
    public static func logout(completion: @escaping(Int, String?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())")
                return
            }
            
            UserManager.removeUser()
            HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
            completion(200, "ok")
        }
    }
    
    public static func loginByWechat(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
  
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/connection/social/wechat:mobile/\(config!.userPoolId!)/callback?code=\(code)&app_id=\(Authing.getAppId())";
            Guardian.get(urlString: url) { code, message, data in
                if (code == 200) {
                    let userInfo = createUserInfo(data)
                    completion(code, message, userInfo)
                } else {
                    completion(code, message, nil)
                }
            }
        }
    }

    public static func createUserInfo(_ data: NSDictionary?, _ save: Bool = true) -> UserInfo? {
        guard data != nil else {
            return nil
        }
        
        let userInfo: UserInfo = UserInfo.parse(data: data)
        if (save) {
            UserManager.saveUser(userInfo)
        }
        return userInfo
    }
}
