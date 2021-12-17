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
    
    public static func parse(data: NSDictionary?) -> UserInfo {
        var userInfo: UserInfo
        userInfo = UserInfo()
        userInfo.username = data!["username"] as? String
        userInfo.email = data!["email"] as? String
        userInfo.phone = data!["phone"] as? String
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
