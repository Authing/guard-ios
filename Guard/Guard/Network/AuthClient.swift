//
//  AuthClient.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import Foundation

public class AuthClient {
    public static func loginByAccount(account: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            let url: String = "https://" + (config?.identifier)! + "." + Authing.getHost() + "/api/v2/login/account";
            let encryptedPassword = Util.encryptPassword(password)
            let body: NSDictionary = ["account" : account, "password" : encryptedPassword]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let userInfo: UserInfo = createUserInfo(data!)
                    completion(code, message, userInfo)
                } else {
                    completion(code, message, nil)
                }
            }
        }
    }
    
    public static func loginByOneAuth(token: String, accessToken: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            let url: String = "https://" + (config?.identifier)! + "." + Authing.getHost() + "/api/v2/ecConn/oneAuth/login";
//            let url: String = "https://developer-beta.authing.cn/stats/ydtoken"
            let body: NSDictionary = ["token" : token, "accessToken" : accessToken]
            Guardian.post(urlString: url, body: body) { code, message, data in
                if (code == 200) {
                    let userInfo: UserInfo = createUserInfo(data!)
                    completion(code, message, userInfo)
                } else {
                    completion(code, message, nil)
                }
            }
        }
    }
    
    public static func createUserInfo(_ data: NSDictionary) -> UserInfo {
        let userInfo: UserInfo = UserInfo.parse(data: data)
        return userInfo
    }
}
