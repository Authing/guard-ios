//
//  UserInfo.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import Foundation

open class UserInfo {
    
    public var raw: NSMutableDictionary?
    public var mfaData: NSDictionary? {
        didSet {
            if let mfas = mfaData?["applicationMfa"] as? [NSDictionary] {
                for mfa in mfas {
                    mfaPolicy?.append((mfa["mfaPolicy"] as? String)!)
                }
            }
        }
    }
    public var customData: [NSMutableDictionary]?
    
    public var userId: String?
    public var username: String?
    public var email: String?
    public var phone: String?
    public var token: String?
    public var mfaToken: String? {
        get {
            return mfaData?["mfaToken"] as? String
        }
    }
    public var mfaPhone: String? {
        get {
            return mfaData?["phone"] as? String
        }
    }
    public var mfaEmail: String? {
        get {
            return mfaData?["email"] as? String
        }
    }
    public var mfaPolicy: [String]? = []
    
    public var firstTimeLoginToken: String? = nil

    open func parse(data: NSDictionary?) {
        if (raw == nil) {
            raw = data?.mutableCopy() as? NSMutableDictionary
        } else {
            if let dic = data {
                for (key, value) in dic {
                    if let k = key as? String {
                        raw!.setValue(value, forKey: k)
                    }
                }
            }
        }
        
        userId = raw?["id"] as? String
        username = raw?["username"] as? String
        email = raw?["email"] as? String
        phone = raw?["phone"] as? String
        token = raw?["token"] as? String
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
}
