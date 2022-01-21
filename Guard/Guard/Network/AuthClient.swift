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
                createUserInfo(code, message, data, completion: completion)
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
                createUserInfo(code, message, data, completion: completion)
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
                createUserInfo(code, message, data, completion: completion)
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
                createUserInfo(code, message, data, completion: completion)
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
                        createUserInfo(code, message, data, completion: completion)
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
    
    public static func resetPasswordByFirstTimeLoginToken(token: String, password: String, completion: @escaping(Int, String?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())")
                return
            }
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/users/password/reset-by-first-login-token";
            let encryptedPassword = Util.encryptPassword(password)
            let body: NSDictionary = ["token" : token, "password" : encryptedPassword]
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
                createUserInfo(code, message, data, completion: completion)
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
  
            let conId: String? = config?.getConnectionId(type: "wechat:mobile")
            guard conId != nil else {
                completion(500, "No wechat connection. Please set up in console for \(Authing.getAppId())", nil)
                return
            }
            
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/ecConn/wechatMobile/authByCode";
            let body: NSDictionary = ["connId" : conId!, "code" : code]
            Guardian.post(urlString: url, body: body) { code, message, data in
                createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public static func loginByAlipay(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
  
            let conId: String? = config?.getConnectionId(type: "alipay")
            guard conId != nil else {
                completion(500, "No alipay connection. Please set up in console for \(Authing.getAppId())", nil)
                return
            }
            
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/ecConn/alipay/authByCode";
            let body: NSDictionary = ["connId" : conId!, "code" : code]
            Guardian.post(urlString: url, body: body) { code, message, data in
                createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public static func loginByApple(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
  
            let userPoolId: String? = config?.userPoolId
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/connection/social/apple/\(userPoolId!)/callback?app_id=\(Authing.getAppId())";
            let body: NSDictionary = ["code" : code]
            Guardian.post(urlString: url, body: body) { code, message, data in
                createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public static func mfaCheck(phone: String?, email: String?, completion: @escaping(Int, String?, Bool?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", false)
                return
            }
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/applications/mfa/check";
            var body: NSDictionary? = nil
            if (phone != nil) {
                body = ["phone" : phone!]
            } else if (email != nil) {
                body = ["email" : email!]
            }
            Guardian.post(urlString: url, body: body) { code, message, data in
                completion(code, message, data?["data"] as? Bool)
            }
        }
    }
    
    public static func mfaVerifyByPhone(phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/applications/mfa/sms/verify";
            let body: NSDictionary = ["phone" : phone, "code" : code]
            Guardian.post(urlString: url, body: body) { code, message, data in
                createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public static func mfaVerifyByEmail(email: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/applications/mfa/email/verify";
            let body: NSDictionary = ["email" : email, "code" : code]
            Guardian.post(urlString: url, body: body) { code, message, data in
                createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public static func mfaVerifyByOTP(code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            guard config != nil else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
            let url: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/mfa/totp/verify";
            let body: NSDictionary = ["authenticatorType" : "totp", "totp" : code]
            Guardian.post(urlString: url, body: body) { code, message, data in
                createUserInfo(code, message, data, completion: completion)
            }
        }
    }

    public static func createUserInfo(_ code: Int, _ message: String?, _ data: NSDictionary?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        if (code == 200) {
            let userInfo: UserInfo = UserInfo.parse(data: data)
            Authing.saveUser(userInfo)
            completion(code, message, userInfo)
        } else if (code == Const.EC_MFA_REQUIRED) {
            let userInfo: UserInfo = UserInfo()
            Authing.saveUser(userInfo)
            userInfo.mfaData = data
            completion(code, message, userInfo)
        } else if (code == Const.EC_FIRST_TIME_LOGIN) {
            let userInfo: UserInfo = UserInfo()
            userInfo.firstTimeLoginToken = data?["token"] as? String
            completion(code, message, userInfo)
        } else {
            completion(code, message, nil)
        }
    }
}
