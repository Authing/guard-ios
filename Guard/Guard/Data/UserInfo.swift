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
            return mfaData?["phone"] as? String
        }
    }
    @objc public var mfaEmail: String? {
        get {
            return mfaData?["email"] as? String
        }
    }
    
    @objc public var faceMfaEnabled:Bool = false
    
    @objc public var mfaPolicy: [String]? = []
    
    @objc public var firstTimeLoginToken: String? = nil
    
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
}
