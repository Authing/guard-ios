//
//  UserInfo.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import Foundation

open class UserInfo {
    
    public var raw: NSDictionary?
    public var mfaData: NSDictionary? {
        didSet {
            if let mfas = mfaData?["applicationMfa"] as? [NSDictionary] {
                for mfa in mfas {
                    mfaPolicy?.append((mfa["mfaPolicy"] as? String)!)
                }
            }
        }
    }
    
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

    public static func parse(data: NSDictionary?) -> UserInfo {
        let userInfo = UserInfo()
        
        userInfo.raw = data
        
        userInfo.username = data?["username"] as? String
        userInfo.email = data?["email"] as? String
        userInfo.phone = data?["phone"] as? String
        userInfo.token = data?["token"] as? String
        
        return userInfo
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
