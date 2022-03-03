//
//  OIDCClient.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/2.
//

import Foundation

public class OIDCClient {
    public static func buildAuthorizeUrl(authRequest: AuthRequest, completion: @escaping (URL?) -> Void) {
        Authing.getConfig { config in
            if (config == nil) {
                completion(nil)
            } else {
                let url = "\(Authing.getSchema())://\(Util.getHost(config!))/oidc/auth?_authing_lang=\(Util.getLangHeader())"
                + "&app_id=" + authRequest.client_id
                + "&client_id=" + authRequest.client_id
                + "&nonce=" + authRequest.nonce
                + "&redirect_uri=" + authRequest.redirect_uri
                + "&response_type=" + authRequest.response_type
                + "&scope=" + authRequest.scope.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                + "&prompt=consent"
                + "&state=" + authRequest.state
                + "&code_challenge=" + authRequest.codeChallenge!
                + "&code_challenge_method=S256"
                completion(URL(string: url))
            }
        }
    }
    
    public static func authByCode(code: String, authRequest: AuthRequest, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let body = "client_id="+Authing.getAppId()
                    + "&grant_type=authorization_code"
                    + "&code=" + code
                    + "&scope=" + authRequest.scope
                    + "&prompt=" + "consent"
                    + "&code_verifier=" + authRequest.codeVerifier
                    + "&redirect_uri=" + authRequest.redirect_uri
        request(userInfo: nil, endPoint: "/oidc/token", method: "POST", body: body) { code, message, data in
            if (code == 200) {
                AuthClient.createUserInfo(code, message, data) { code, message, userInfo in
                    getUserInfoByAccessToken(userInfo: userInfo, completion: completion)
                }
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public static func getUserInfoByAccessToken(userInfo: UserInfo?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        request(userInfo: userInfo, endPoint: "/oidc/me", method: "GET", body: nil) { code, message, data in
            AuthClient.createUserInfo(userInfo, code, message, data, completion: completion)
        }
    }
    
    public static func getNewAccessTokenByRefreshToken(userInfo: UserInfo?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let rt = userInfo?.refreshToken ?? ""
        let body = "client_id=" + Authing.getAppId() + "&grant_type=refresh_token" + "&refresh_token=" + rt;
        request(userInfo: nil, endPoint: "/oidc/token", method: "POST", body: body) { code, message, data in
            if (code == 200) {
                AuthClient.createUserInfo(userInfo, code, message, data, completion: completion)
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public static func request(userInfo: UserInfo?, endPoint: String, method: String, body: String?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        Authing.getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))\(endPoint)"
                _request(userInfo: userInfo, config: config, urlString: urlString, method: method, body: body, completion: completion)
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    private static func _request(userInfo: UserInfo?, config: Config?, urlString: String, method: String, body: String?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if body != nil {
            request.httpBody = body!.data(using: .utf8)
        }
        if let currentUser = userInfo {
            if let at = currentUser.accessToken {
                request.addValue("Bearer \(at)", forHTTPHeaderField: "Authorization")
            }
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(500, "network error \(url!) \n\(error!)", nil)
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode: Int = (httpResponse?.statusCode)!
            
            if (data != nil) {
                if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                    completion(statusCode, "", jsonData as? NSDictionary)
                } else {
                    completion(statusCode, String(decoding: data!, as: UTF8.self), nil)
                }
            } else {
                completion(statusCode, "", nil)
            }
        }.resume()
    }
}
