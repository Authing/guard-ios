//
//  AuthClient.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import Foundation

public class AuthClient {
    
    // MARK: Basic authentication APIs
    public static func registerByEmail(email: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["email" : email, "password" : encryptedPassword, "forceLogin" : true]
        Guardian.post("/api/v2/register/email", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func registerByUserName(username: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["username" : username, "password" : encryptedPassword, "forceLogin" : true]
        Guardian.post("/api/v2/register/username", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func registerByPhoneCode(phone: String, password: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["phone" : phone, "password" : encryptedPassword, "code" : code, "forceLogin" : true]
        Guardian.post("/api/v2/register/phone-code", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func loginByAccount(account: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["account" : account, "password" : encryptedPassword]
        Guardian.post("/api/v2/login/account", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func loginByLDAP(username: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["username" : username, "password" : encryptedPassword]
        Guardian.post("/api/v2/login/ldap", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func loginByAD(username: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["username" : username, "password" : encryptedPassword]
        Guardian.post("/api/v2/login/ad", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func loginByPhoneCode(phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["phone" : phone, "code" : code]
        Guardian.post("/api/v2/login/phone-code", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func loginByOneAuth(token: String, accessToken: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["token" : token, "accessToken" : accessToken]
        Guardian.post("/api/v2/ecConn/oneAuth/login", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func getCurrentUser(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Guardian.get("/api/v2/users/me") { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func logout(completion: @escaping(Int, String?) -> Void) {
        Guardian.get("/api/v2/logout?app_id=\(Authing.getAppId())") { code, message, data in
            UserManager.removeUser()
            HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
            completion(200, "ok")
        }
    }
    
    public static func sendSms(phone: String, completion: @escaping(Int, String?) -> Void) {
        Guardian.post("/api/v2/sms/send", ["phone" : phone]) { code, message, data in
            completion(code, message)
        }
    }
    
    public static func sendResetPasswordEmail(email: String, completion: @escaping(Int, String?) -> Void) {
        sendEmail(email: email, scene: "RESET_PASSWORD", completion: completion)
    }
    
    public static func sendMFAEmail(email: String, completion: @escaping(Int, String?) -> Void) {
        sendEmail(email: email, scene: "MFA_VERIFY", completion: completion)
    }
    
    public static func sendEmail(email: String, scene: String, completion: @escaping(Int, String?) -> Void) {
        let body: NSDictionary = ["email" : email, "scene" : scene]
        Guardian.post("/api/v2/email/send", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public static func getCustomUserData(userInfo: UserInfo, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["targetType" : "USER", "targetId" : userInfo.userId as Any]
        Guardian.post("/api/v2/udvs/get", body) { code, message, data in
            if (code == 200) {
                userInfo.customData = data?["result"] as? [NSMutableDictionary]
            }
            completion(code, message, userInfo)
        }
    }
    
    public static func setCustomUserData(customData: NSDictionary, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        let items = NSMutableArray()
        for (key, value) in customData {
            let item = ["definition": key, "value": value]
            items.add(item)
        }
        let body: NSDictionary = ["udfs" : items]
        Guardian.post("/api/v2/udfs/values", body) { code, message, data in
            completion(code, message, data)
        }
    }
    
    public static func uploadAvatar(image: UIImage, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Guardian.uploadImage(image, completion: { code, result in
            if (code == 200 && result != nil) {
                AuthClient.updateProfile(["photo" : result!], completion: completion)
            } else {
                completion(code, result, nil)
            }
        })
    }
    
    public static func resetPasswordByEmail(email: String, newPassword: String, code: String, completion: @escaping(Int, String?) -> Void) {
        let encryptedPassword = Util.encryptPassword(newPassword)
        let body: NSDictionary = ["email" : email, "code" : code, "newPassword" : encryptedPassword]
        Guardian.post("/api/v2/password/reset/email", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public static func resetPasswordByPhone(phone: String, newPassword: String, code: String, completion: @escaping(Int, String?) -> Void) {
        let encryptedPassword = Util.encryptPassword(newPassword)
        let body: NSDictionary = ["phone" : phone, "code" : code, "newPassword" : encryptedPassword]
        Guardian.post("/api/v2/password/reset/sms", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public static func resetPasswordByFirstTimeLoginToken(token: String, password: String, completion: @escaping(Int, String?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["token" : token, "password" : encryptedPassword]
        Guardian.post("/api/v2/users/password/reset-by-first-login-token", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public static func updateProfile(_ object: NSDictionary, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Guardian.post("/api/v2/users/profile/update", object) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func updatePassword(_ newPassword: String, _ oldPassword: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["newPassword" : Util.encryptPassword(newPassword)]
        if (oldPassword != nil) {
            body.setValue(Util.encryptPassword(oldPassword!), forKey: "oldPassword")
        }
        Guardian.post("/api/v2/password/update", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func bindPhone(phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["phone" : phone, "phoneCode" : code]
        Guardian.post("/api/v2/users/phone/bind", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func unbindPhone(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Guardian.post("/api/v2/users/phone/unbind", [:]) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func bindEmail(email: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["email" : email, "emailCode" : code]
        Guardian.post("/api/v2/users/email/bind", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func unbindEmail(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Guardian.post("/api/v2/users/email/unbind", [:]) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func updateIdToken(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Guardian.post("/api/v2/users/refresh-token", [:]) { code, message, data in
            createUserInfo(Authing.getCurrentUser(), code, message, data, completion: completion)
        }
    }
    
    public static func getSecurityLevel(completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        Guardian.get("/api/v2/users/me/security-level", completion: completion)
    }
    
    public static func listApplications(page: Int = 1, limit: Int = 10, completion: @escaping(Int, String?, NSArray?) -> Void) {
        Guardian.get("/api/v2/users/me/applications/allowed?page=\(String(page))&limit=\(String(limit))") { code, message, data in
            if (code == 200) {
                completion(code, message, data?["list"] as? NSArray)
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public static func listOrgs(page: Int = 1, limit: Int = 10, completion: @escaping(Int, String?, NSArray?) -> Void) {
        if let userId = Authing.getCurrentUser()?.userId {
            Guardian.get("/api/v2/users/\(userId)/orgs") { code, message, data in
                if (code == 200) {
                    completion(code, message, data?["data"] as? NSArray)
                } else {
                    completion(code, message, nil)
                }
            }
        } else {
            completion(2020, "not logged in", nil)
        }
    }
    
    public static func listRoles(namespace: String? = nil, completion: @escaping(Int, String?, NSArray?) -> Void) {
        Guardian.get("/api/v2/users/me/roles\(namespace == nil ? "" : "?namespace=" + namespace!)") { code, message, data in
            if (code == 200) {
                completion(code, message, data?["data"] as? NSArray)
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public static func listAuthorizedResources(namespace: String = "default", resourceType: String? = nil, completion: @escaping(Int, String?, NSArray?) -> Void) {
        let body: NSDictionary = ["namespace" : namespace]
        if (resourceType != nil) {
            body.setValue(Util.encryptPassword(resourceType!), forKey: "resourceType")
        }
        Guardian.post("/api/v2/users/resource/authorized", body) { code, message, data in
            if (code == 200) {
                completion(code, message, data?["list"] as? NSArray)
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public static func deleteAccount(completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        Guardian.delete("/api/v2/users/delete", completion: completion)
    }
    
    // MARK: Social APIs
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
            
            let body: NSDictionary = ["connId" : conId!, "code" : code]
            Guardian.post("/api/v2/ecConn/wechatMobile/authByCode", body) { code, message, data in
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
            
            let body: NSDictionary = ["connId" : conId!, "code" : code]
            Guardian.post("/api/v2/ecConn/alipay/authByCode", body) { code, message, data in
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
            let url: String = "/connection/social/apple/\(userPoolId!)/callback?app_id=\(Authing.getAppId())";
            let body: NSDictionary = ["code" : code]
            Guardian.post(url, body) { code, message, data in
                createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    // MARK: MFA APIs
    public static func mfaCheck(phone: String?, email: String?, completion: @escaping(Int, String?, Bool?) -> Void) {
        var body: NSDictionary? = nil
        if (phone != nil) {
            body = ["phone" : phone!]
        } else if (email != nil) {
            body = ["email" : email!]
        }
        Guardian.post("/api/v2/applications/mfa/check", body) { code, message, data in
            completion(code, message, data?["data"] as? Bool)
        }
    }
    
    public static func mfaVerifyByPhone(phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["phone" : phone, "code" : code]
        Guardian.post("/api/v2/applications/mfa/sms/verify", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func mfaVerifyByEmail(email: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["email" : email, "code" : code]
        Guardian.post("/api/v2/applications/mfa/email/verify", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public static func mfaVerifyByOTP(code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["authenticatorType" : "totp", "totp" : code]
        Guardian.post("/api/v2/mfa/totp/verify", body) { code, message, data in
            createUserInfo(code, message, data, completion: completion)
        }
    }
    
    // MARK: Scan APIs
    public static func markQRCodeScanned(ticket: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        Guardian.post("/api/v2/qrcode/scanned", ["random" : ticket], completion: completion)
    }
    
    public static func loginByScannedTicket(ticket: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        Guardian.post("/api/v2/qrcode/confirm", ["random" : ticket], completion: completion)
    }

    // MARK: Util APIs
    public static func createUserInfo(_ code: Int, _ message: String?, _ data: NSDictionary?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        createUserInfo(nil, code, message, data, completion: completion)
    }
        
    public static func createUserInfo(_ user: UserInfo?, _ code: Int, _ message: String?, _ data: NSDictionary?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let userInfo = user ?? UserInfo()
        if (code == 200) {
            userInfo.parse(data: data)
            Authing.saveUser(userInfo)
            getCustomUserData(userInfo: userInfo, completion: completion)
        } else if (code == Const.EC_MFA_REQUIRED) {
            Authing.saveUser(userInfo)
            userInfo.mfaData = data
            completion(code, message, userInfo)
        } else if (code == Const.EC_FIRST_TIME_LOGIN) {
            userInfo.firstTimeLoginToken = data?["token"] as? String
            completion(code, message, userInfo)
        } else {
            completion(code, message, nil)
        }
    }
}
