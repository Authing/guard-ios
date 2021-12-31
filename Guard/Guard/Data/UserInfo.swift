//
//  UserInfo.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import Foundation

open class UserInfo {
    var username: String?
    var email: String?
    var phone: String?
    
    var token: String?
    
    public static func parse(data: NSDictionary?) -> UserInfo {
        let userInfo = UserInfo()
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
