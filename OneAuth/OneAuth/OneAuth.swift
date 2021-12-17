//
//  OneAuth.swift
//  OneAuth
//
//  Created by Lance Mao on 2021/12/15.
//

import Foundation
import Guard

open class OneAuth {
    
    static var bizId: String = "74ae90bd84f74b69a88b578bbbbcdcfd"
    
    public static func start(_ completion: @escaping(Int, String?, UserInfo?)->Void) {
        NTESQuickLoginManager.sharedInstance().register(withBusinessID: bizId)
        
        NTESQuickLoginManager.sharedInstance().getPhoneNumberCompletion { result in
            let success: Bool = result["success"] as! Bool
            if (success) {
                let token: String? = result["token"] as? String
                self.startLogin(token, completion)
            } else {
                let error: String = result["desc"] as! String
                print("Error oneauth getPhoneNumber \(error)")
                completion(500, error, nil)
            }
        }
    }
    
    private static func startLogin(_ token: String?, _ completion: @escaping(Int, String?, UserInfo?)->Void) {
        NTESQuickLoginManager.sharedInstance().cucmctAuthorizeLoginCompletion { result in
            let success: Bool = result["success"] as! Bool
            if (success) {
                let ak: String = result["accessToken"] as! String
                self.getAuthingToken(token!, ak, completion)
            } else {
                let error: String = result["desc"] as! String
                print("Error oneauth cucmctAuthorize \(error)")
                completion(500, error, nil)
            }
        }
    }
    
    private static func getAuthingToken(_ token: String, _ ak: String, _ completion: @escaping(Int, String?, UserInfo?)->Void) {
        AuthClient.loginByOneAuth(token: token, accessToken: ak) { code, message, userInfo in
            completion(code, message, userInfo)
        }
    }
}
