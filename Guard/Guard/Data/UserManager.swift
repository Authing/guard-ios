//
//  UserManager.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

import Foundation

open class UserManager {
    
    private static let KEY_USER_TOKEN = "authing_user_token"
    
    public static func saveUser(_ userInfo: UserInfo?) {
        if (userInfo == nil) {
            removeUser()
        } else {
            let defaults = UserDefaults.standard
            defaults.set(userInfo?.idToken, forKey: KEY_USER_TOKEN)
        }
    }
    
    public static func getUser() -> UserInfo? {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: KEY_USER_TOKEN)
        if (token == nil) {
            return nil
        }
        
        let userInfo: UserInfo = UserInfo()
        userInfo.token = token
        return userInfo
    }
    
    public static func removeUser() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: KEY_USER_TOKEN)
    }
}
