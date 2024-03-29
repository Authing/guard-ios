//
//  UserInfo.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

open class UserInfo: NSObject {
    
    @objc public var raw: NSMutableDictionary?
    @objc public var mfaData: NSDictionary? {
        didSet {
            if let mfas = mfaData?["applicationMfa"] as? [NSDictionary] {
                for mfa in mfas {
                    mfaPolicy?.append((mfa["mfaPolicy"] as? String)!)
                }
            }
            if let enabled = mfaData?["faceMfaEnabled"] as? Bool {
                faceMfaEnabled = enabled
            }
            if let enabled = mfaData?["totpMfaEnabled"] as? Bool {
                totpMfaEnabled = enabled
            }
        }
    }
    @objc public var socialBindingData: NSDictionary? {
        didSet {
        }
    }
    @objc public var customData: [NSMutableDictionary]?
    @objc public var identities: [NSDictionary]?
    @objc public var userId: String?
    @objc public var username: String?
    @objc public var password: String?
    @objc public var email: String?
    @objc public var phone: String?
    @objc public var photo: String? {
        get {
            return raw?["photo"] as? String ?? raw?["picture"] as? String
        }
    }
    @objc public var  nickname: String? {
        get {
            return raw?["nickname"] as? String ?? raw?["nickname"] as? String
        }
    }
    @objc public var  name: String? {
        get {
            return raw?["name"] as? String ?? raw?["name"] as? String
        }
    }
    @objc public var  createdAt: String? {
        get {
            return raw?["createdAt"] as? String ?? raw?["createdAt"] as? String
        }
    }
    @objc public var  birthdate: String? {
        get {
            return raw?["birthdate"] as? String ?? raw?["birthdate"] as? String
        }
    }
    @objc public var  address: String? {
        get {
            return raw?["address"] as? String ?? raw?["address"] as? String
        }
    }
    @objc public var  gender: String? {
        get {
            return raw?["gender"] as? String ?? raw?["gender"] as? String
        }
    }
    @objc public var  company: String? {
        get {
            return raw?["company"] as? String ?? raw?["company"] as? String
        }
    }
    
    @objc public var  userPoolId: String? {
        get {
            return raw?["userPoolId"] as? String ?? raw?["userPoolId"] as? String
        }
    }
    
    @objc public var token: String?
    @objc public var idToken: String? { // used as id token
        get {
            return raw?["id_token"] as? String ?? token
        }
    }
    @objc public var accessToken: String? {
        get {
            return raw?["access_token"] as? String
        }
    }
    
    @objc public var accessTokenId: String? {
        get {
            if let at = raw?["access_token"] as? String {
                return self.getAccessTokenId(accessToken: at)
            }
            return nil
        }
    }
    
    @objc public var refreshToken: String? {
        get {
            return raw?["refresh_token"] as? String
        }
    }
    @objc public var mfaToken: String? {
        get {
            return mfaData?["mfaToken"] as? String
        }
    }
    @objc public var mfaPhone: String? {
        get {
            return mfaData?["mfaPhone"] as? String
        }
    }
    @objc public var mfaEmail: String? {
        get {
            return mfaData?["mfaEmail"] as? String
        }
    }
    
    @objc public var faceMfaEnabled:Bool = false
    
    @objc public var totpMfaEnabled:Bool = false
    
    @objc public var mfaPolicy: [String]? = []
    
    @objc public var firstTimeLoginToken: String? = nil
    
    @objc public var loginsCount: Int = 0
    
    open func parse(data: NSDictionary?) {
        var userData = data
        if let entity = data?["userEntity"] as? NSDictionary {
            userData = entity.mutableCopy() as? NSMutableDictionary
        }
        
        if (raw == nil) {
            raw = userData?.mutableCopy() as? NSMutableDictionary
        } else {
            if let dic = userData {
                for (key, value) in dic {
                    if let k = key as? String {
                        raw!.setValue(value, forKey: k)
                    }
                }
            }
        }
        
        userId = raw?["id"] as? String
        if userId == nil {
            userId = raw?["sub"] as? String
        }
        username = raw?["username"] as? String
        password = raw?["password"] as? String
        email = raw?["email"] as? String
        phone = raw?["phone"] as? String
        token = raw?["token"] as? String
        identities = raw?["identities"] as? [NSDictionary]
        loginsCount = raw?["loginsCount"] as? Int ?? 0
        
    }

    public func getUserName() -> String? {
        return username
    }
    
    public func getEmail() -> String? {
        return email
    }
    
    public func getPhone() -> String? {
        return phone
    }
    
    public func getDisplayName() -> String? {
        if let n = nickname {
            return n
        } else if let n = raw?["preferredUsername"] as? String {
            return n
        } else if let n = name {
            return n
        } else if let n = username {
            return n
        } else if let n = phone {
            return n
        } else if let n = email {
            return n
        }
        return nil
    }
    
    public func getAccessTokenId(accessToken: String) -> String? {
        let strArr = accessToken.components(separatedBy: ".")
        var st = strArr[1]
         .replacingOccurrences(of: "_", with: "/")
         .replacingOccurrences(of: "-", with: "+")
         let remainder = strArr[1].count % 4
         if remainder > 0 {
             st = strArr[1].padding(toLength: strArr[1].count + 4 - remainder,
             withPad: "=",
             startingAt: 0)
         }
         guard let d = Data(base64Encoded: st, options: .ignoreUnknownCharacters) else{
             
             return nil
         }

        let jsonString = String(data: d, encoding: .utf8)
        if let data = jsonString?.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                return json?["jti"] as? String
            } catch {
                print("Something went wrong")
            }
        }
        
        return nil
    }
}
