//
//  AuthClient.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

public class AuthClient: Client {
    
    // MARK: Basic authentication APIs
    public func registerByEmail(email: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.registerByEmail(authData: nil, email: email, password: password, completion: completion)
    }
    
    public func registerByEmailCode(email: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.registerByEmailCode(authData: nil, email: email, code: code, completion: completion)
    }
    
    public func registerByUserName(username: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.registerByUserName(authData: nil, username: username, password: password, completion: completion)
    }
    
    public func registerByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, password: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.registerByPhoneCode(authData: nil, phoneCountryCode: phoneCountryCode, phone: phone, code: code, password: password, completion: completion)
    }
    
    public func registerByEmail(authData: AuthRequest?, email: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["email" : email, "password" : encryptedPassword, "forceLogin" : true]
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
    
    public func registerByEmailCode(authData: AuthRequest?, email: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["email" : email, "code" : code, "forceLogin" : true]
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
    
    public func registerByUserName(authData: AuthRequest?, username: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["username" : username, "password" : encryptedPassword, "forceLogin" : true]
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
    
    public func registerByPhoneCode(authData: AuthRequest?, phoneCountryCode: String? = nil, phone: String, code: String, password: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["phone" : phone, "code" : code, "forceLogin" : true]
        if password != nil {
            body.setValue(Util.encryptPassword(password!), forKey: "password")
        }
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
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
    
    public func loginByAccount(account: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        loginByAccount(authData: nil, account: account, password: password, completion: completion)
    }

    public func loginByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        loginByPhoneCode(authData: nil, phoneCountryCode: phoneCountryCode, phone: phone, code: code, completion: completion)
    }
    
    public func loginByEmail(email: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        loginByEmail(authData: nil, email: email, code: code, completion: completion)
    }
            
    public func loginByAccount(authData: AuthRequest?, account: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["account" : account, "password" : encryptedPassword]
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
    
    public func loginByPhoneCode(authData: AuthRequest?, phoneCountryCode: String? = nil, phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSMutableDictionary = ["phone" : phone, "code" : code]
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
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
    
    public func loginByEmail(authData: AuthRequest?, email: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["email" : email, "code" : code]
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
    
    public func loginByOneAuth(token: String, accessToken: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body: NSDictionary = ["token" : token, "accessToken" : accessToken]
        post("/api/v2/ecConn/oneAuth/login", body) { code, message, data in
            self.createUserInfo(code, message, data, completion: completion)
        }
    }
    
    public func getCurrentUser(user: UserInfo? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        get("/api/v2/users/me") { code, message, data in
            self.createUserInfo(user, code, message, data, completion: completion)
        }
    }
    
    public func logout(completion: @escaping(Int, String?) -> Void) {
        get("/api/v2/logout?app_id=\(Authing.getAppId())") { code, message, data in
            Authing.saveUser(nil)
            HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
            completion(200, "ok")
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
            completion(2020, "not logged in", nil)
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
    
    public func deleteAccount(completion: @escaping(Int, String?) -> Void) {
        delete("/api/v2/users/delete") { code, message, data in
            if (code == 200) {
                Authing.saveUser(nil)
                HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
            }
            completion(code, message)
        }
    }
    
    // MARK: Social APIs

    public func loginByWechat(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        self.loginByWechat(authData: nil, code, completion: completion)
    }
    
    public func loginByWechat(authData: AuthRequest? = nil, _ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
    
        getConfig { config in
            guard let conf = config else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "wechat:mobile") else {
                completion(500, "No wechat connection. Please set up in console for \(Authing.getAppId())", nil)
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
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
                return
            }
  
            guard let conId = conf.getConnectionId(type: "wechatwork:mobile") else {
                completion(500, "No wechat connection. Please set up in console for \(Authing.getAppId())", nil)
                return
            }
            
            let body: NSDictionary = ["connId" : conId, "code" : code]
            self.post("/api/v2/ecConn/wechat-work/authByCode", body) { code, message, data in
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
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
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
    
    // MARK: MFA APIs
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
    
    // MARK: Scan APIs
    public func markQRCodeScanned(ticket: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v2/qrcode/scanned", ["random" : ticket], completion: completion)
    }
    
    public func loginByScannedTicket(ticket: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v2/qrcode/confirm", ["random" : ticket], completion: completion)
    }
    
    public func cancelByScannedTicket(ticket: String, completion: @escaping(Int, String?, NSDictionary?) -> Void) {
        post("/api/v2/qrcode/cancel", ["random" : ticket], completion: completion)
    }

    // MARK: Util APIs
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
            
            if userInfo.userId != nil {
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
        } else {
            completion(code, message, nil)
        }
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
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    public func request(config: Config?, urlString: String, method: String, body: NSDictionary?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
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
        request.addValue("guard-ios", forHTTPHeaderField: "x-authing-request-from")
        request.addValue(Const.SDK_VERSION, forHTTPHeaderField: "x-authing-sdk-version")
        request.addValue(Util.getLangHeader(), forHTTPHeaderField: "x-authing-lang")
        
        request.httpShouldHandleCookies = false
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Guardian request network error:\(error!.localizedDescription)")
                completion(500, error!.localizedDescription, nil)
                return
            }
            
            guard data != nil else {
                print("data is null when requesting \(urlString)")
                completion(500, "no data from server", nil)
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
                    print("data is not json when requesting \(urlString)")
                    completion(500, "only accept json data", nil)
                    return
                }
                
                guard statusCode == 200 || statusCode == 201 else {
                    print("Guardian request network error. Status code:\(statusCode.description). url:\(urlString)")
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
                print("parsing json error when requesting \(urlString)")
                completion(500, urlString, nil)
            }
        }.resume()
    }
    
    public func uploadImage(_ image: UIImage, completion: @escaping (Int, String?) -> Void) {
        getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/upload?folder=photos";
                self._uploadImage(urlString, image, completion: completion)
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())")
            }
        }
    }
    
    public func uploadFaceImage(_ image: UIImage,_ isPrivate: Bool = true, completion: @escaping (Int, String?) -> Void) {
        getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/upload?folder=photos&private=\(isPrivate)";
                self._uploadImage(urlString, image, true, completion: completion)
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())")
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
                completion(500, "network error \(url!)")
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
            guard jsonData != nil else {
                completion(500, "response not json \(url!)")
                return
            }
            
            guard let json = jsonData as? [String: Any] else {
                completion(500, "illegal json \(url!)")
                return
            }
            
            guard let code = json["code"] as? Int else {
                completion(500, "no response code \(url!)")
                return
            }
            
            if isFaceImage == true{
                guard let data = json["data"] as? NSDictionary else {
                    completion(500, "no response data \(url!)")
                    return
                }
                
                if let u = data["key"] as? String {
                    completion(200, u)
                } else {
                    completion(500, "response data has no url field \(url!)")
                    return
                }
            } else {
                guard code == 200 else {
                    completion(code, json["message"] as? String)
                    return
                }
                
                guard let data = json["data"] as? NSDictionary else {
                    completion(500, "no response data \(url!)")
                    return
                }
                
                if let u = data["url"] as? String {
                    completion(200, u)
                } else {
                    completion(500, "response data has no url field \(url!)")
                    return
                }
            }

        }).resume()
    }
}
