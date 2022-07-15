//
//  UserManager.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

open class UserManager {
    
    private static let KEY_USER_TOKEN = "authing_user_token"
    private static let KEY_ACCESS_TOKEN = "authing_access_token"
    private static let KEY_REFRESH_TOKEN = "authing_refresh_token"
    
    public static func saveUser(_ userInfo: UserInfo?) {
        if (userInfo == nil) {
            removeUser()
        } else {
            let defaults = UserDefaults.standard
            defaults.set(userInfo?.idToken, forKey: UserManager.KEY_USER_TOKEN)
            if let at = userInfo?.accessToken {
                defaults.set(at, forKey: UserManager.KEY_ACCESS_TOKEN)
            }
            if let rt = userInfo?.refreshToken {
                defaults.set(rt, forKey: UserManager.KEY_REFRESH_TOKEN)
            }
            defaults.synchronize()
        }
    }
    
    public static func getUser() -> UserInfo? {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: UserManager.KEY_USER_TOKEN)
        if (token == nil) {
            return nil
        }
        
        let userInfo: UserInfo = UserInfo()
        userInfo.token = token
        userInfo.raw = userInfo.raw ?? [:]
        userInfo.raw?["access_token"] = defaults.string(forKey: UserManager.KEY_ACCESS_TOKEN)
        userInfo.raw?["refresh_token"] = defaults.string(forKey: UserManager.KEY_REFRESH_TOKEN)
        return userInfo
    }
    
    public static func removeUser() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: UserManager.KEY_USER_TOKEN)
        defaults.removeObject(forKey: UserManager.KEY_ACCESS_TOKEN)
        defaults.removeObject(forKey: UserManager.KEY_REFRESH_TOKEN)
    }
}
