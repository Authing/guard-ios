//
//  AuthClient.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import Foundation

public class AuthClient: Client {
        
    //MARK: ---------- Register APIs ----------
    public func registerByEmail(email: String, password: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.registerByEmail(authData: nil, email: email, password: password, context, completion: completion)
    }
    
    public func registerByEmailCode(email: String, code: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.registerByEmailCode(authData: nil, email: email, code: code, context, completion: completion)
    }
    
    public func registerByUserName(username: String, password: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.registerByUserName(authData: nil, username: username, password: password, context, completion: completion)
    }
    
    
    public func registerByPhone(phoneCountryCode: String? = nil,phone: String, password: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.registerByPhone(authData: nil, phoneCountryCode: phoneCountryCode, phone: phone, password: password, context, completion: completion)
    }
    
    public func registerByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, password: String? = nil, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.registerByPhoneCode(authData: nil, phoneCountryCode: phoneCountryCode, phone: phone, code: code, password: password, context, completion: completion)
    }
    
    public func registerByExtendedFields(extendedFields: String, account: String, password: String, _ postUserInfoPipeline: Bool? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.registerByExtendedFields(authData: nil, extendedFields: extendedFields, account: account, password: password, completion: completion)
    }
    
    public func registerByEmail(authData: AuthRequest?, email: String, password: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSMutableDictionary = ["email" : email, "password" : encryptedPassword, "forceLogin" : true]
        if context != nil {
            body.setValue(context, forKey: "context")
        }
        post("/api/v2/register/email", body) { code, message, data in
            if authData == nil{
                self.createUserInfo(code, message, data, completion: completion)
            } else {
                self.createUserInfo(code, message, data) { code, msg, userInfo in
                    if code == 200{
                        authData?.token = userInfo?.token
                        OIDCClient(authData).authByToken(userInfo: userInfo, completion: completion)
                    } else {
                        completion(code, message, userInfo)
                    }
                }
            }
        }
    }
    
    public func registerByEmailCode(authData: AuthRequest?, email: String, code: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["email" : email, "code" : code, "forceLogin" : true]
        if context != nil {
            body.setValue(context, forKey: "context")
        }
        post("/api/v2/register/email-code", body) { code, message, data in
            if authData == nil{
                self.createUserInfo(code, message, data, completion: completion)
            } else {
                self.createUserInfo(code, message, data) { code, msg, userInfo in
                    if code == 200{
                        authData?.token = userInfo?.token
                        OIDCClient(authData).authByToken(userInfo: userInfo, completion: completion)
                    } else {
                        completion(code, message, userInfo)
                    }
                }
            }
        }
    }
    

    public func registerByUserName(authData: AuthRequest?, username: String, password: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSMutableDictionary = ["username" : username, "password" : encryptedPassword, "forceLogin" : true]
        if context != nil {
            body.setValue(context, forKey: "context")
        }
        post("/api/v2/register/username", body) { code, message, data in
            if authData == nil{
                self.createUserInfo(code, message, data, completion: completion)
            } else {
                self.createUserInfo(code, message, data) { code, msg, userInfo in
                    if code == 200{
                        authData?.token = userInfo?.token
                        OIDCClient(authData).authByToken(userInfo: userInfo, completion: completion)
                    } else {
                        completion(code, message, userInfo)
                    }
                }
            }
        }
    }
    
    public func registerByPhone(authData: AuthRequest?, phoneCountryCode: String? = nil, phone: String, password: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["account" : phone,
                                         "password" : Util.encryptPassword(password)]
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        post("/api/v2/register-phone", body) { code, message, data in
            if authData == nil{
                self.createUserInfo(code, message, data, completion: completion)
            } else {
                self.createUserInfo(code, message, data) { code, msg, userInfo in
                    if code == 200{
                        authData?.token = userInfo?.token
                        OIDCClient(authData).authByToken(userInfo: userInfo, completion: completion)
                    } else {
                        completion(code, message, userInfo)
                    }
                }
            }
        }
    }
    
    public func registerByPhoneCode(authData: AuthRequest?, phoneCountryCode: String? = nil, phone: String, code: String, password: String? = nil, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["phone" : phone, "code" : code, "forceLogin" : true]
        if password != nil {
            body.setValue(Util.encryptPassword(password!), forKey: "password")
        }
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        if context != nil {
            body.setValue(context, forKey: "context")
        }
        post("/api/v2/register/phone-code", body) { code, message, data in
            if authData == nil{
                self.createUserInfo(code, message, data, completion: completion)
            } else {
                self.createUserInfo(code, message, data) { code, msg, userInfo in
                    if code == 200{
                        authData?.token = userInfo?.token
                        OIDCClient(authData).authByToken(userInfo: userInfo, completion: completion)
                    } else {
                        completion(code, message, userInfo)
                    }
                }
            }
        }
    }
    
    public func registerByExtendedFields(authData: AuthRequest?, extendedFields: String, account: String, password: String, _ postUserInfoPipeline: Bool? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["account" : account,
                                         "password" : Util.encryptPassword(password)]

        post("/api/v2/register-\(extendedFields)", body) { code, message, data in
            if authData == nil{
                self.createUserInfo(code, message, data, completion: completion)
            } else {
                self.createUserInfo(code, message, data) { code, msg, userInfo in
                    if code == 200{
                        authData?.token = userInfo?.token
                        OIDCClient(authData).authByToken(userInfo: userInfo, completion: completion)
                    } else {
                        completion(code, message, userInfo)
                    }
                }
            }
        }
    }
    
    //MARK: ---------- Login APIs ----------
    public func loginByAccount(account: String, password: String, _ autoRegister: Bool = false, _ context: String? = nil, _ captchaCode: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        loginByAccount(authData: nil, account: account, password: password, autoRegister, context, captchaCode, completion: completion)
    }

    public func loginByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, _ autoRegister: Bool = false, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        loginByPhoneCode(authData: nil, phoneCountryCode: phoneCountryCode, phone: phone, code: code, autoRegister, context, completion: completion)
    }
    
    public func loginByEmail(email: String, code: String, _ autoRegister: Bool = false, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        loginByEmail(authData: nil, email: email, code: code, autoRegister, context, completion: completion)
    }
            
    public func loginByAccount(authData: AuthRequest?, account: String, password: String, _ autoRegister: Bool = false, _ context: String? = nil, _ captchaCode: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSMutableDictionary = ["account" : account, "password" : encryptedPassword, "autoRegister": autoRegister]
        if context != nil {
            body.setValue(context, forKey: "context")
        }
        if captchaCode != nil {
            body.setValue(captchaCode, forKey: "captchaCode")
        }
        post("/api/v2/login/account", body) { code, message, data in
            if authData == nil{
                self.createUserInfo(code, message, data, completion: completion)
            } else {
                self.createUserInfo(code, message, data) { code, msg, userInfo in
                    if code == 200{
                        authData?.token = userInfo?.token
                        OIDCClient(authData).authByToken(userInfo: userInfo, completion: completion)
                    } else {
                        completion(code, message, userInfo)
                    }
                }
            }
        }
    }
    
    public func loginByPhoneCode(authData: AuthRequest?, phoneCountryCode: String? = nil, phone: String, code: String, _ autoRegister: Bool = false, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["phone" : phone, "code" : code, "autoRegister": autoRegister]
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        if context != nil {
            body.setValue(context, forKey: "context")
        }
        post("/api/v2/login/phone-code", body) { code, message, data in
            if authData == nil{
                self.createUserInfo(code, message, data, completion: completion)
            } else {
                self.createUserInfo(code, message, data) { code, msg, userInfo in
                    if code == 200{
                        authData?.token = userInfo?.token
                        OIDCClient(authData).authByToken(userInfo: userInfo, completion: completion)
                    } else {
                        completion(code, message, userInfo)
                    }
                }
            }
        }
    }
    
    public func loginByEmail(authData: AuthRequest?, email: String, code: String, _ autoRegister: Bool = false, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["email" : email, "code" : code, "autoRegister": autoRegister]
        if context != nil {
            body.setValue(context, forKey: "context")
        }
        post("/api/v2/login/email-code", body) { code, message, data in
            if authData == nil{
                self.createUserInfo(code, message, data, completion: completion)
            } else {
                self.createUserInfo(code, message, data) { code, msg, userInfo in
                    if code == 200{
                        authData?.token = userInfo?.token
                        OIDCClient(authData).authByToken(userInfo: userInfo, completion: completion)
                    } else {
                        completion(code, message, userInfo)
                    }
                }
            }
        }
    }
//
//    public func loginByLDAP(username: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
//        let encryptedPassword = Util.encryptPassword(password)
//        let body: NSDictionary = ["username" : username, "password" : encryptedPassword]
//        post("/api/v2/login/ldap", body) { code, message, data in
//            self.createUserInfo(code, message, data, completion: completion)
//        }
//    }
//
//    public func loginByAD(username: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
//        let encryptedPassword = Util.encryptPassword(password)
//        let body: NSDictionary = ["username" : username, "password" : encryptedPassword]
//        post("/api/v2/login/ad", body) { code, message, data in
//            self.createUserInfo(code, message, data, completion: completion)
//        }
//    }
    
    //MARK: ---------- Security ----------
    public func getSecurityCaptcha(completion: @escaping(Int, String?, Data?) -> Void) {
        getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/security/captcha";
                self.request(config: config, urlString: urlString, method: "GET", body: nil, completion: completion)
            } else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
            }
        }
    }
    // MARK: ---------- User APIs ----------
    public func getCurrentUser(user: UserInfo? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        get("/api/v2/users/me") { code, message, data in
            self.createUserInfo(user, code, message, data, completion: completion)
        }
    }
    
    public func logout(completion: @escaping(Int, String?) -> Void) {
        get("/api/v2/logout?app_id=\(Authing.getAppId())") { code, message, data in
            Authing.saveUser(nil)
            HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
            completion(code, message)
        }
    }
    
    public func sendSms(phone: String, phoneCountryCode: String? = nil, completion: @escaping(Int, String?) -> Void) {
        let body: NSMutableDictionary = ["phone" : phone]
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        post("/api/v2/sms/send", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public func sendResetPasswordEmail(email: String, completion: @escaping(Int, String?) -> Void) {
        sendEmail(email: email, scene: "RESET_PASSWORD", completion: completion)
    }
    
    public func sendMFAEmail(email: String, completion: @escaping(Int, String?) -> Void) {
        sendEmail(email: email, scene: "MFA_VERIFY", completion: completion)
    }
    
    public func sendEmail(email: String, scene: String, completion: @escaping(Int, String?) -> Void) {
        let body: NSDictionary = ["email" : email, "scene" : scene]
        post("/api/v2/email/send", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public func sendLoginEmail(email: String, scene: String, completion: @escaping(Int, String?) -> Void) {
        let body: NSDictionary = ["email" : email, "scene" : scene]
        post("/api/v2/email/send-email", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public func getCustomUserData(userInfo: UserInfo, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["targetType" : "USER", "targetId" : userInfo.userId as Any]
        post("/api/v2/udvs/get", body) { code, message, data in
            if (code == 200) {
                userInfo.customData = data?["result"] as? [NSMutableDictionary]
            }
            completion(code, message, userInfo)
        }
    }
    
    public func setCustomUserData(customData: NSDictionary, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        let items = NSMutableArray()
        for (key, value) in customData {
            let item = ["definition": key, "value": value]
            items.add(item)
        }
        let body: NSDictionary = ["udfs" : items]
        post("/api/v2/udfs/values", body) { code, message, data in
            completion(code, message, data)
        }
    }
    
    public func uploadAvatar(image: UIImage, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        uploadImage(image, completion: { code, result in
            if (code == 200 && result != nil) {
                self.updateProfile(object: ["photo" : result!], completion: completion)
            } else {
                completion(code, result, nil)
            }
        })
    }
    
    public func resetPasswordByPhone(phone: String, code: String, newPassword: String, completion: @escaping(Int, String?) -> Void) {
        let encryptedPassword = Util.encryptPassword(newPassword)
        let body: NSDictionary = ["phone" : phone, "code" : code, "newPassword" : encryptedPassword]
        post("/api/v2/password/reset/sms", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public func resetPasswordByEmail(email: String, code: String, newPassword: String, completion: @escaping(Int, String?) -> Void) {
        let encryptedPassword = Util.encryptPassword(newPassword)
        let body: NSDictionary = ["email" : email, "code" : code, "newPassword" : encryptedPassword]
        post("/api/v2/password/reset/email", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public func resetPasswordByFirstTimeLoginToken(token: String, password: String, completion: @escaping(Int, String?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["token" : token, "password" : encryptedPassword]
        post("/api/v2/users/password/reset-by-first-login-token", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public func updateProfile(object: NSDictionary, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        post("/api/v2/users/profile/update", object) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func updatePassword(newPassword: String, oldPassword: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["newPassword" : Util.encryptPassword(newPassword)]
        if (oldPassword != nil) {
            body.setValue(Util.encryptPassword(oldPassword!), forKey: "oldPassword")
        }
        post("/api/v2/password/update", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func bindPhone(phoneCountryCode: String? = nil, phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["phone" : phone, "phoneCode" : code]
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        post("/api/v2/users/phone/bind", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func unbindPhone(completion: @escaping(Int, String?, UserInfo?) -> Void) {

        post("/api/v2/users/phone/unbind", [:]) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func bindEmail(email: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["email" : email, "emailCode" : code]
        post("/api/v2/users/email/bind", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func unbindEmail(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        post("/api/v2/users/email/unbind", [:]) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func updateIdToken(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        post("/api/v2/users/refresh-token", [:]) { code, message, data in
            self.createUserInfo(Authing.getCurrentUser(), code, message, data, completion: completion)
        }
    }
    
    public func getSecurityLevel(completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        get("/api/v2/users/me/security-level", completion: completion)
    }
    
    public func listApplications(page: Int = 1, limit: Int = 10, completion: @escaping(Int, String?, NSArray?) -> Void) {
        get("/api/v2/users/me/applications/allowed?page=\(String(page))&limit=\(String(limit))") { code, message, data in
            if (code == 200) {
                completion(code, message, data?["list"] as? NSArray)
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public func listOrgs(completion: @escaping(Int, String?, NSArray?) -> Void) {
        if let userId = Authing.getCurrentUser()?.userId {
            get("/api/v2/users/\(userId)/orgs") { code, message, data in
                if (code == 200) {
                    completion(code, message, data?["data"] as? NSArray)
                } else {
                    completion(code, message, nil)
                }
            }
        } else {
            completion(ErrorCode.login.rawValue, ErrorCode.login.errorMessage(), nil)
        }
    }
    
    public func listRoles(namespace: String? = nil, completion: @escaping(Int, String?, NSArray?) -> Void) {
        get("/api/v2/users/me/roles\(namespace == nil ? "" : "?namespace=" + namespace!)") { code, message, data in
            if (code == 200) {
                completion(code, message, data?["data"] as? NSArray)
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public func listAuthorizedResources(namespace: String = "default", resourceType: String? = nil, completion: @escaping(Int, String?, NSArray?) -> Void) {
        let body: NSDictionary = ["namespace" : namespace]
        if (resourceType != nil) {
            body.setValue(Util.encryptPassword(resourceType!), forKey: "resourceType")
        }
        post("/api/v2/users/resource/authorized", body) { code, message, data in
            if (code == 200) {
                completion(code, message, data?["list"] as? NSArray)
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public func checkPassword(password: String, completion: @escaping(Int, String?) -> Void) {
        let cs = NSCharacterSet(charactersIn: "=+").inverted
        let encryptedPassword = Util.encryptPassword(password).addingPercentEncoding(withAllowedCharacters: cs)!
        get("/api/v2/users/password/check?password=\(encryptedPassword)") { code, message, data in
            completion(code, message)
        }
    }
    
    public func checkAccount(paramsName: String, paramsValue: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        
        get("/api/v2/users/is-user-exists?" + paramsName + "=" + paramsValue, completion: completion)
    }
    
    public func feedBack(contact: String, type: Int, description: String, images: [String], completion: @escaping(Int, String?) -> Void) {
        let body: NSMutableDictionary = ["appId" : Authing.getAppId(), "phone" : contact, "type": type, "description": description]
        if (images.count != 0) {
            body.setValue(images, forKey: "images")
        }
        post("/api/v2/feedback", body) { code, message, data in
            completion(code, message)
        }
    }
    
    public func deleteAccount(completion: @escaping(Int, String?) -> Void) {
        delete("/api/v2/users/delete") { code, message, data in
            if (code == 200) {
                Authing.saveUser(nil)
                HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
            }
            completion(code, message)
        }
    }
    
    // MARK: ---------- Social APIs ----------
    public func loginByWechat(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.loginByWechat(authData: nil, code, completion: completion)
    }
    
    public func loginByWechat(authData: AuthRequest? = nil, _ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
    
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "wechat:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "code" : code]
            self.post("/api/v2/ecConn/wechatMobile/authByCode", body) { code, message, data in
                if authData == nil{
                    self.createUserInfo(code, message, data, completion: completion)
                } else {
                    self.createUserInfo(code, message, data) { code, msg, userInfo in
                        if code == 200{
                            authData?.token = userInfo?.token
                            OIDCClient(authData).authByToken(userInfo: userInfo, completion: completion)
                        } else {
                            completion(code, message, userInfo)
                        }
                    }
                }
            }
        }
    }

    
    public func loginByWeCom(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "wechatwork:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "code" : code]
            self.post("/api/v2/ecConn/wechat-work/authByCode", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginbyWeComAgency(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "wechatwork:agency:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "code" : code]
            self.post("/api/v2/ecConn/wechat-work-agency/authByCode", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByLark(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard config != nil else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            let conId: String? = config?.getConnectionId(type: "lark-internal") == nil ? config?.getConnectionId(type: "lark-public") : config?.getConnectionId(type: "lark-internal")
            guard conId != nil else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId!, "code" : code]
            self.post("/api/v2/ecConn/lark/authByCode", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
//    public func loginByAlipay(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
//        Authing.getConfig { config in
//            guard config != nil else {
//                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
//                return
//            }
//  
//            let conId: String? = config?.getConnectionId(type: "alipay")
//            guard conId != nil else {
//                completion(500, "No alipay connection. Please set up in console for \(Authing.getAppId())", nil)
//                return
//            }
//            
//            let body: NSDictionary = ["connId" : conId!, "code" : code]
//            post("/api/v2/ecConn/alipay/authByCode", body) { code, message, data in
//                self.createUserInfo(code, message, data, completion: completion)
//            }
//        }
//    }
    
    public func loginByApple(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        
//        getConfig { config in
//            guard config != nil else {
//                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
//                return
//            }
//
//            let conId: String? = config?.getConnectionId(type: "apple")
//            guard conId != nil else {
//                completion(500, "No wechat connection. Please set up in console for \(Authing.getAppId())", nil)
//                return
//            }
//
//            let body: NSDictionary = ["connId" : conId!, "code" : code]
//            self.post("/api/v2/ecConn/apple/authByCode", body) { code, message, data in
//                self.createUserInfo(code, message, data, completion: completion)
//            }
//        }
        
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }

            let userPoolId: String? = conf.userPoolId
            let url: String = "/connection/social/apple/\(userPoolId!)/callback?app_id=\(Authing.getAppId())";
            let body: NSDictionary = ["code" : code]
            self.post(url, body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByGoogle(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "google:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "code" : code]
            self.post("/api/v2/ecConn/google/authByCode", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByFacebook(_ accessToken: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            guard let conId = conf.getConnectionId(type: "facebook:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "access_token" : accessToken]
            self.post("/api/v2/ecConn/facebook/authByAccessToken", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByMiniprogram(code: String, phoneInfoCode: String?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
              
            guard let conId = conf.getConnectionId(type: "wechat:miniprogram:app-launch") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSMutableDictionary = ["connId": conId, "iv" : "", "encryptedData" : "", "code": code]
            if phoneInfoCode != nil {
                body.setValue(phoneInfoCode, forKey: "phoneInfoCode")
            }
            
            self.post("/api/v2/ecConn/wechatminiprogramapplaunch/authByCode", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByTencent(_ accessToken: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            guard let conId = conf.getConnectionId(type: "qq:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "access_token" : accessToken]
            self.post("/api/v2/ecConn/QQConnect/authByAccessToken", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByWeibo(_ accessToken: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            guard let conId = conf.getConnectionId(type: "weibo:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "access_token" : accessToken]
            self.post("/api/v2/ecConn/weibo/authByAccessToken", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByBaidu(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "baidu:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "code" : code]
            self.post("/api/v2/ecConn/baidu/authByCode", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByBaiduByAccessToken(_ accessToken: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "baidu:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "access_token" : accessToken]
            self.post("/api/v2/ecConn/baidu/authByAccessToken", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByLinkedin(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "linkedin:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "code" : code]
            self.post("/api/v2/ecConn/linkedin/authByCode", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByDingTalk(_ code: String, _ isSnsCode: Bool = true, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "dingtalk:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "code" : code, "isSnsCode" : isSnsCode]
            self.post("/api/v2/ecConn/dingtalk/authByCode", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    public func loginByDouyin(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "douyin:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "code" : code]
            self.post("/api/v2/ecConn/douyin/authByCode", body) { code, message, data in
                self.createUserInfo(code, message, data, completion: completion)
            }
        }
    }
    
    
    public func loginByOneAuth(token: String, accessToken: String, _ netWork: Int? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["token" : token, "accessToken" : accessToken]
        if netWork != nil {
            body.setValue(netWork, forKey: "netWork")
        }
        post("/api/v2/ecConn/oneAuth/login", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    // MARK: ---------- Scoial Identity Binding APIs ----------
    public func getDataByWechatlogin(authData: AuthRequest? = nil, code: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        getConfig { config in
            guard let conf = config else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "wechat:mobile") else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            guard let appid = config?.appId else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
                return
            }
            
            var dic: NSMutableDictionary = ["scope": AuthRequest().scope ?? ""]
            if authData != nil {
                dic = ["scope": authData?.scope ?? ""]
            }
            if context != nil {
                dic.setValue(context, forKey: "context")
            }
            
            let body: NSDictionary = ["connId" : conId, "code" : code, "appId" : appid, "options": dic]

            self.post("/api/v2/ecConn/wechatMobile/authByCodeIdentity", body) { code, message, data in
                if code == 200 {
                    self.createUserInfo(code, message, data) { code, message, userInfo in
                        self.getCurrentUser(user: userInfo, completion: completion)
                    }
                } else {
                    self.createUserInfo(code, message, data, completion: completion)
                }
            }
        }
    }
    
    public func bindWechatWithRegister(key: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        
        let body: NSDictionary = ["action": "create-federation-account",
                                 "key": key]
        self.post("/api/v2/ecConn/wechatMobile/register", body) { code, message, data in
            if code == 200 {
                if let jsonData = data {
                    self.createUserInfo(code, message, jsonData) { code, message, userInfo in
                        self.getCurrentUser(user: userInfo, completion: completion)
                    }
                } else {
                    completion(ErrorCode.socialBinding.rawValue, ErrorCode.socialBinding.errorMessage(), nil)
                }
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public func bindWechatByAccount(account: String, password: String, key: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        
        let encryptedPassword = Util.encryptPassword(password)
        
        let body: NSDictionary = ["action": "bind-identity-by-password",
                                  "account": account,
                                  "password": encryptedPassword,
                                  "key": key]
        self.post("/api/v2/ecConn/wechatMobile/byAccount", body) { code, message, data in
            if code == 200 {
                if let jsonData = data {
                    self.createUserInfo(code, message, jsonData) { code, message, userInfo in
                        self.getCurrentUser(user: userInfo, completion: completion)
                    }
                } else {
                    completion(ErrorCode.socialBinding.rawValue, ErrorCode.socialBinding.errorMessage(), nil)
                }
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public func bindWechatByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, key: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
                
        let body: NSMutableDictionary = ["action": "bind-identity-by-phone-code",
                                  "phone": phone,
                                  "code": code,
                                  "key": key]
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        self.post("/api/v2/ecConn/wechatMobile/byPhoneCode", body) { code, message, data in
            if code == 200 {
                if let jsonData = data {
                    self.createUserInfo(code, message, jsonData) { code, message, userInfo in
                        self.getCurrentUser(user: userInfo, completion: completion)
                    }
                } else {
                    completion(ErrorCode.socialBinding.rawValue, ErrorCode.socialBinding.errorMessage(), nil)
                }
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public func bindWechatByEmailCode(email: String, code: String, key: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
                
        let body: NSMutableDictionary = ["action": "bind-identity-by-email-code",
                                  "email": email,
                                  "code": code,
                                  "key": key]

        self.post("/api/v2/ecConn/wechatMobile/byEmailCode", body) { code, message, data in
            if code == 200 {
                if let jsonData = data {
                    self.createUserInfo(code, message, jsonData) { code, message, userInfo in
                        self.getCurrentUser(user: userInfo, completion: completion)
                    }
                } else {
                    completion(ErrorCode.socialBinding.rawValue, ErrorCode.socialBinding.errorMessage(), nil)
                }
            } else {
                completion(code, message, nil)
            }
        }
    }
    

    public func bindWechatBySelectedAccountId(accountId: String, key: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
                
        let body: NSMutableDictionary = ["action": "bind-identity-by-selection",
                                  "accountId": accountId,
                                  "key": key]

        self.post("/api/v2/ecConn/wechatMobile/select", body) { code, message, data in
            if code == 200 {
                if let jsonData = data {
                    self.createUserInfo(code, message, jsonData) { code, message, userInfo in
                        self.getCurrentUser(user: userInfo, completion: completion)
                    }
                } else {
                    completion(ErrorCode.socialBinding.rawValue, ErrorCode.socialBinding.errorMessage(), nil)
                }
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public func bindWechatByAccountId(accountId: String, key: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["action": "bind-identity-by-account-id",
                                  "accountId": accountId,
                                  "key": key]

        self.post("/api/v2/ecConn/wechatMobile/byAccountId", body) { code, message, data in
            if code == 200 {
                if let jsonData = data {
                    self.createUserInfo(code, message, jsonData) { code, message, userInfo in
                        self.getCurrentUser(user: userInfo, completion: completion)
                    }
                } else {
                    completion(ErrorCode.socialBinding.rawValue, ErrorCode.socialBinding.errorMessage(), nil)
                }
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    // MARK: ---------- MFA APIs ----------

    public func mfaCheck(phone: String?, email: String?, completion: @escaping(Int, String?, Bool?) -> Void) {
        var body: NSDictionary? = nil
        if (phone != nil) {
            body = ["phone" : phone!]
        } else if (email != nil) {
            body = ["email" : email!]
        }
        post("/api/v2/applications/mfa/check", body) { code, message, data in
            completion(code, message, data?["data"] as? Bool)
        }
    }
    
    public func mfaVerifyByPhone(phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["phone" : phone, "code" : code]
        post("/api/v2/applications/mfa/sms/verify", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func mfaVerifyByEmail(email: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["email" : email, "code" : code]
        post("/api/v2/applications/mfa/email/verify", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func mfaAssociateByOTP(completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        let body: NSDictionary = ["authenticatorType" : "totp", "source" : "SELF"]
        post("/api/v2/mfa/totp/associate", body, completion: completion)
    }
    
    public func mfaAssociateConfirmByOTP(code: String,completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        let body: NSDictionary = ["authenticatorType" : "totp", "totp" : code, "source" : "SELF"]
        post("/api/v2/mfa/totp/associate/confirm", body, completion: completion)
    }
    
    public func mfaAssociteByRecoveryCode(code: String,completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["authenticatorType" : "totp", "recoveryCode" : code]
        post("/api/v2/mfa/totp/recovery", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func mfaDeleteOTP(completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        delete("/api/v2/mfa/totp/associate", completion: completion)
    }
        
    public func mfaVerifyByOTP(code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["authenticatorType" : "totp", "totp" : code]
        post("/api/v2/mfa/totp/verify", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func mfaAssociateByFace(photoKeyA: String, photoKeyB: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["photoA" : photoKeyA, "photoB" : photoKeyB, "isExternalPhoto": false]
        post("/api/v2/mfa/face/associate", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func mfaVerifyByFace(photoKey: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["type" : "face", "photo" : photoKey]
        post("/api/v2/mfa/face/verify", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func mfaUnbindFactor(factorId: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v3/reset-factor", ["factorId" : factorId], completion: completion)
    }
    
    public func unbindMFAPhone(completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v2/mfa/phone/unbind", [:], completion: completion)
    }
    
    public func unbindMFAEmail(completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v2/mfa/email/unbind", [:], completion: completion)
    }
    
    // MARK: ---------- Scan APIs ----------
    public func markQRCodeScanned(ticket: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v2/qrcode/scanned", ["random" : ticket], completion: completion)
    }
    
    public func loginByScannedTicket(ticket: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v2/qrcode/confirm", ["random" : ticket], completion: completion)
    }
    
    public func cancelByScannedTicket(ticket: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v2/qrcode/cancel", ["random" : ticket], completion: completion)
    }
    
    public func loginByQRCode(qrcodeId: String, action: String = "APP_LOGIN", completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v3/qrcode-app-login", ["qrcodeId" : qrcodeId, "action": action], completion: completion)
    }
    
    public func loginByPushNotification(pushCodeId: String, action: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v3/change-pushcode-status", ["pushCodeId" : pushCodeId, "action": action], completion: completion)
    }
    
    public func createDevice(completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        
        post("/api/v3/create-device", ["uniqueId" : Util.getDeviceID(),
                                       "type": "Mobile",
                                       "name": UIDevice.current.name,
                                       "version": UIDevice.current.systemVersion,
                                       "producer": "apple",
                                       "os": UIDevice.current.systemName], completion: completion)
    }
    
    public func bind(cid: String ,completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        
        post("/api/v3/user-bind-app", ["cid": cid], completion: completion)
    }
    
    public func unbind(cid: String ,completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v3/user-unbind-app", ["cid": cid], completion: completion)
    }

    // MARK: ---------- WebAuthn ----------
    public func getWebauthnRegistrationParam(completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        get("/api/v3/webauthn/registration", completion: completion)
    }

    public func webauthnRegistration(ticket: String,
                                     credentialId: String,
                                     rawId: String,
                                     attestationObject: String,
                                     clientDataJSON: String,
                                     authenticatorCode: String,
                                     completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        
        let body: NSDictionary = ["ticket" : ticket,
                                  "registrationCredential" : ["id" : credentialId,
                                                              "rawId": rawId,
                                                              "response":["attestationObject": attestationObject,
                                                                                              "clientDataJSON": clientDataJSON],
                                                              "type": "public-key"],
                                  "authenticatorCode": authenticatorCode]
        
        post("/api/v3/webauthn/registration", body, completion: completion)
    }
    
    public func getWebauthnAuthenticationParam(completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        get("/api/v3/webauthn/authentication", completion: completion)
    }

    public func webauthnAuthentication(ticket: String,
                                       credentialId: String,
                                       rawId: String,
                                       authenticatorData: String,
                                       userHandle: String,
                                       clientDataJSON: String,
                                       signature: String,
                                       completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        
        let body: NSDictionary = ["ticket" : ticket,
                                  "authenticationCredential" : ["id" : credentialId,
                                                                "rawId": rawId,
                                                                "response": ["authenticatorData": authenticatorData,
                                                                             "userHandle": userHandle,
                                                                             "clientDataJSON": clientDataJSON,
                                                                             "signature": signature],
                                                                "type": "public-key"]]

        post("/api/v3/webauthn/authentication", body, completion: completion)
    }
    
    public func webauthnRemoveCredential(credentialID: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v3/webauthn/remove-credential/\(credentialID)", [:], completion: completion)
    }
    
    public func webauthnAuthenticatorDevice(authenticatorCode: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v3/webauthn/page-authenticator-device", ["authenticatorCode": authenticatorCode], completion: completion)
    }
    
    public func checkWebauthnVaildCredentitals(credentialIds: [String], authenticatorCode: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v3/webauthn/check-valid-credentials-by-credIds", ["credentialIds": credentialIds, "authenticatorCode": authenticatorCode], completion: completion)
    }
    
    //MARK: ---------- subEvent ----------
    public func subEvent(eventCode: String, completion: @escaping (String?) -> Void) {
        if let currentUser = Authing.getCurrentUser(),
           let token = currentUser.accessToken {
            let eventUri = "\(Authing.getWebsocketHost())/events/v1/authentication/sub?code=\(eventCode)&token=\(token)"
            if #available(iOS 13.0, *) {
                AuthingWebsocketClient().initWebSocket(urlString: eventUri, completion: completion)
            }
        }
    }
    
    //MARK: ---------- pubEvent ----------
    public func pubEvent(eventType: String, eventData: NSDictionary, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        
        guard let data = try? JSONSerialization.data(withJSONObject: eventData, options: []) else {
            ALog.d(AuthClient.self, "eventData is not json when requesting pubEvent")
            completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage(), nil)
            return
        }
        
        guard let str = String(data: data, encoding: .utf8) else {
            ALog.d(AuthClient.self, "eventData is not json when requesting pubEvent")
            completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage(), nil)
            return
        }
        
        post("/api/v3/pub-userEvent", ["eventType": eventType, "eventData": str], completion: completion)
    }
    
    // MARK: ---------- Util APIs ----------
    public func createUserInfo(_ code: Int, _ message: String?, _ data: NSDictionary?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        createUserInfo(nil, code, message, data, completion: completion)
    }
        
    public func createUserInfo(_ user: UserInfo?, _ code: Int, _ message: String?, _ data: NSDictionary?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let userInfo = user ?? UserInfo()
        if code == 200 {
            userInfo.parse(data: data)
            
            // only save user for 'root', otherwise we might be in console
            if config == nil || config?.appId == Authing.getAppId() {
                Authing.saveUser(userInfo)
            } else {
                ALog.i(Self.self, "requesting app ID: \(config!.appId ?? "") root app ID: \(Authing.getAppId())")
            }
            
            if userInfo.userId != nil && userInfo.idToken != nil {
                getCustomUserData(userInfo: userInfo, completion: completion)
            } else {
                completion(code, message, userInfo)
            }
        } else if code == Const.EC_MFA_REQUIRED {
            Authing.saveUser(userInfo)
            userInfo.mfaData = data
            completion(code, message, userInfo)
        } else if code == Const.EC_FIRST_TIME_LOGIN {
            userInfo.firstTimeLoginToken = data?["token"] as? String
            completion(code, message, userInfo)
        } else if code == Const.EC_BINDING_CREATE_ACCOUNT ||
                    code == Const.EC_ONLY_BINDING_ACCOUNT ||
                    code == Const.EC_MULTIPLE_ACCOUNT {
            userInfo.socialBindingData = data
            completion(code, message, userInfo)
        } else {
            completion(code, message, nil)
        }
    }
    
    public func get(_ endPoint: String, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        request(endPoint: endPoint, method: "GET", body: nil, completion: completion)
    }
    
    public func post(_ endPoint: String, _ body: NSDictionary?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        request(endPoint: endPoint, method: "POST", body: body, completion: completion)
    }
    
    public func delete(_ endPoint: String, _ body: NSDictionary? = nil, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        request(endPoint: endPoint, method: "DELETE", body: body, completion: completion)
    }
    
    private func request(endPoint: String, method: String, body: NSDictionary?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))\(endPoint)";
                self.request(config: config, urlString: urlString, method: method, body: body, completion: completion)
            } else {
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
            }
        }
    }
    
    private func request(config: Config?, urlString: String, method: String, body: NSDictionary?) -> URLRequest {
        let url:URL! = URL(string:urlString)
        var request = URLRequest(url: url)
        request.httpMethod = method
        if method == "POST" && body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let httpBody = try? JSONSerialization.data(withJSONObject: body!, options: []) {
                request.httpBody = httpBody
            }
        }

        if let currentUser = Authing.getCurrentUser() {
            if let token = currentUser.idToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else if let mfaToken = currentUser.mfaToken {
                request.addValue("Bearer \(mfaToken)", forHTTPHeaderField: "Authorization")
            }
        }
        request.timeoutInterval = 60
        if let userPoolId = config?.userPoolId {
            request.addValue(userPoolId, forHTTPHeaderField: "x-authing-userpool-id")
        }
        if let appid = config?.appId {
            request.addValue(appid, forHTTPHeaderField: "x-authing-app-id")
        }
        
        if let ua = config?.userAgent {
            request.addValue(ua, forHTTPHeaderField: "User-Agent")
        }
        request.addValue("Guard-iOS@\(Const.SDK_VERSION)", forHTTPHeaderField: "x-authing-request-from")
        request.addValue(Const.SDK_VERSION, forHTTPHeaderField: "x-authing-sdk-version")
        request.addValue(Util.getLangHeader(), forHTTPHeaderField: "x-authing-lang")
        request.httpShouldHandleCookies = true
        return request
    }
    
    public func request(config: Config?, urlString: String, method: String, body: NSDictionary?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        let session = URLSession.shared
        if body?.object(forKey: "captchaCode") != nil, let url: URL = URL(string:urlString) {
            session.configuration.httpCookieStorage?.setCookies(Util.cookies, for: url, mainDocumentURL: url)
        }
        session.dataTask(with: self.request(config: config, urlString: urlString, method: method, body: body)) { (data, response, error) in
            guard error == nil else {
                ALog.d(AuthClient.self, "Guardian request network error:\(error!.localizedDescription)")
                completion(ErrorCode.netWork.rawValue, ErrorCode.netWork.errorMessage(), nil)
                return
            }
            
            guard data != nil else {
                ALog.d(AuthClient.self, "data is null when requesting \(urlString)")
                completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage(), nil)
                return
            }
            
            do {
                let httpResponse = response as? HTTPURLResponse
                let statusCode: Int = (httpResponse?.statusCode)!
                
                // some API e.g. getCustomUserData returns json array
                if (statusCode == 200 || statusCode == 201) {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSArray {
                        let res: NSDictionary = ["result": jsonArray]
                        completion(200, "", res)
                        return
                    }
                }
                
                guard let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary else {
                    ALog.d(AuthClient.self, "data is not json when requesting \(urlString)")
                    completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage(), nil)
                    return
                }
                
                guard statusCode == 200 || statusCode == 201 else {
                    ALog.d(AuthClient.self, "Guardian request network error. Status code:\(statusCode.description). url:\(urlString)")
                    let message: String? = json["message"] as? String
                    completion(statusCode, message ?? "Network Error", json)
                    return
                }
                
                if (json["code"] as? Int == nil) {
                    completion(200, nil, json)
                } else {
                    let code: Int = json["code"] as! Int
                    let message: String? = json["message"] as? String
                    let jsonData: NSDictionary? = json["data"] as? NSDictionary
                    if (jsonData == nil) {
                        let result = json["data"]
                        if (result == nil) {
                            completion(code, message, nil)
                        } else {
                            completion(code, message, ["data": result!])
                        }
                    } else {
                        completion(code, message, jsonData)
                    }
                }
            } catch {
                ALog.d(AuthClient.self, "parsing json error when requesting \(urlString)")
                completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage(), nil)
            }
        }.resume()
    }
    
    public func uploadImage(_ image: UIImage, completion: @escaping (Int, String?) -> Void) {
        getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/upload?folder=photos";
                self._uploadImage(urlString, image, completion: completion)
            } else {
                ALog.d(AuthClient.self, "Cannot get config. app id:\(Authing.getAppId())")
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage())
            }
        }
    }
    
    public func uploadFaceImage(_ image: UIImage,_ isPrivate: Bool = true, completion: @escaping (Int, String?) -> Void) {
        getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/upload?folder=photos&private=\(isPrivate)";
                self._uploadImage(urlString, image, true, completion: completion)
            } else {
                ALog.d(AuthClient.self, "Cannot get config. app id:\(Authing.getAppId())")
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage())
            }
        }
    }
    
    private func _uploadImage(_ urlString: String, _ image: UIImage, _ isFaceImage: Bool? = false, completion: @escaping (Int, String?) -> Void) {
        let url = URL(string: urlString)
        let boundary = UUID().uuidString
        let session = URLSession.shared
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"personal.png\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            guard error == nil else {
                ALog.d(AuthClient.self, "network error \(url!)")
                completion(ErrorCode.netWork.rawValue, ErrorCode.netWork.errorMessage())
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
            guard jsonData != nil else {
                ALog.d(AuthClient.self, "response not json \(url!)")
                completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                return
            }
            
            guard let json = jsonData as? [String: Any] else {
                ALog.d(AuthClient.self, "illegal json \(url!)")
                completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                return
            }
            
            guard let code = json["code"] as? Int else {
                ALog.d(AuthClient.self, "no response code \(url!)")
                completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                return
            }
            
            if isFaceImage == true{
                guard let data = json["data"] as? NSDictionary else {
                    ALog.d(AuthClient.self, "no response code \(url!)")
                    completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                    return
                }
                
                if let u = data["key"] as? String {
                    completion(200, u)
                } else {
                    ALog.d(AuthClient.self, "response data has no url field \(url!)")
                    completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                    return
                }
            } else {
                guard code == 200 else {
                    completion(code, json["message"] as? String)
                    return
                }
                
                guard let data = json["data"] as? NSDictionary else {
                    ALog.d(AuthClient.self, "no response data \(url!)")
                    completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                    return
                }
                
                if let u = data["url"] as? String {
                    completion(200, u)
                } else {
                    ALog.d(AuthClient.self, "response data has no url field \(url!)")
                    completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                    return
                }
            }

        }).resume()
    }
    
    private func request(config: Config?, urlString: String, method: String, body: NSDictionary?, completion: @escaping (Int, String?, Data?) -> Void) {
        URLSession.shared.dataTask(with: self.request(config: config, urlString: urlString, method: method, body: body)) { (data, response, error) in
            guard error == nil else {
                ALog.d(AuthClient.self, "Guardian request network error:\(error!.localizedDescription)")
                completion(ErrorCode.netWork.rawValue, ErrorCode.netWork.errorMessage(), nil)
                return
            }
            
            guard data != nil else {
                ALog.d(AuthClient.self, "data is null when requesting \(urlString)")
                completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage(), nil)
                return
            }
            do {
                let url = response?.url
                let httpResponse = response as? HTTPURLResponse
                let fields = httpResponse?.allHeaderFields as? [String: String]
//                else { return nil }
                Util.cookies = HTTPCookie.cookies(withResponseHeaderFields: fields!, for: url!)

//                let httpResponse = response as? HTTPURLResponse
                let statusCode: Int = (httpResponse?.statusCode)!
                
                // some API e.g. getCustomUserData returns json array
                if (statusCode == 200 || statusCode == 201) {
                    return completion(200, "", data)
                } else {
                    ALog.d(AuthClient.self, "Guardian request network error. Status code:\(statusCode.description). url:\(urlString)")
                    completion(statusCode, "Network Error", nil)
                }
            }
        }.resume()
    }
    

}

