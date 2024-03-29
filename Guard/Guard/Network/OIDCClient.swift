//
//  OIDCClient.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/2.
//

public class OIDCClient: NSObject {
    
    public var authRequest = AuthRequest()
    
    public init(_ authRequest: AuthRequest? = nil) {
        super.init()
        
        if let authData = authRequest {
            self.authRequest = authData
        }
        Authing.getConfig { config in
            if let conf = config {
                if conf.redirectUris?.count ?? 0 > 0 {
                    if let url = conf.redirectUris?.first { self.authRequest.redirect_uri = url }
                }
            }
        }
    }

    //MARK: ---------- Register APIs ----------
    public func registerByEmail(email: String, password: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        AuthClient().registerByEmail(authData: self.authRequest, email: email, password: password, context, completion: completion)
    }
    
    public func registerByEmailCode(email: String, code: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        AuthClient().registerByEmailCode(authData: self.authRequest, email: email, code: code, context, completion: completion)
    }
    
    public func registerByUserName(username: String, password: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        AuthClient().registerByUserName(authData: self.authRequest, username: username, password: password, context, completion: completion)
    }
   
   
   public func registerByPhone(phoneCountryCode: String? = nil,phone: String, password: String, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
      AuthClient().registerByPhone(authData: self.authRequest, phoneCountryCode: phoneCountryCode, phone: phone, password: password, context, completion: completion)
   }
    
    public func registerByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, password: String? = nil, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        AuthClient().registerByPhoneCode(authData: self.authRequest, phoneCountryCode: phoneCountryCode, phone: phone, code: code, password: password, context, completion: completion)
    }
   
   
   public func registerByExtendedFields(extendedFields: String, account: String, password: String, _ postUserInfoPipeline: Bool? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
      AuthClient().registerByExtendedFields(authData: self.authRequest, extendedFields: extendedFields, account: account, password: password, completion: completion)
   }

    //MARK: ---------- Login APIs ----------
    public func loginByAccount(account: String, password: String, _ autoRegister: Bool = false, _ context: String? = nil, _ captchaCode: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        AuthClient().loginByAccount(authData: self.authRequest ,account: account, password: password, autoRegister, context, captchaCode, completion: completion)
    }
    
    public func loginByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, _ autoRegister: Bool = false, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        AuthClient().loginByPhoneCode(authData: self.authRequest, phoneCountryCode: phoneCountryCode,  phone: phone, code: code, autoRegister, context, completion: completion)
    }
    
    public func loginByEmail(email: String, code: String, _ autoRegister: Bool = false, _ context: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        AuthClient().loginByEmail(authData: self.authRequest, email: email, code: code, autoRegister, context, completion: completion)
    }
    
    public func loginByWechat(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        AuthClient().loginByWechat(authData: self.authRequest, code, completion: completion)
    }
    
    //MARK: ---------- Util APIs ----------
    public func buildAuthorizeUrl(completion: @escaping (URL?) -> Void) {
        Authing.getConfig { config in
            if (config == nil) {
                completion(nil)
            } else {
               let secret = self.authRequest.client_secret
               var url = "\(Authing.getSchema())://\(Util.getHost(config!))/oidc/auth?"
               let nonce = "nonce=" + self.authRequest.nonce
               let scope = "&scope=" + (self.authRequest.scope.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
               let clientId = "&client_id=" + self.authRequest.client_id
               let redirect = "&redirect_uri=" + self.authRequest.redirect_uri
               let responseType = "&response_type=" + self.authRequest.response_type
               let prompt = "&prompt=consent"
               let state = "&state=" + self.authRequest.state
               let codeChallenge = (secret == nil ? "&code_challenge=" + self.authRequest.codeChallenge! + "&code_challenge_method=S256" : "");
               url = url + nonce + scope + clientId + redirect + responseType + prompt + state + codeChallenge
               
                completion(URL(string: url))
            }
        }
    }
    
    public func authByCode(code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        
        let secret = self.authRequest.client_secret
        let secretStr = (secret == nil ? "&code_verifier=" + self.authRequest.codeVerifier : "&client_secret=" + (secret ?? ""))

        let body = "client_id=" + Authing.getAppId()
                    + "&grant_type=authorization_code"
                    + "&code=" + code
                    + "&scope=" + self.authRequest.scope
                    + "&prompt=" + "consent"
                    + secretStr
                    + "&redirect_uri=" + self.authRequest.redirect_uri
        
        request(userInfo: nil, endPoint: "/oidc/token", method: "POST", body: body) { code, message, data in
            if (code == 200) {
                AuthClient().createUserInfo(code, message, data) { code, message, userInfo in
                    self.getUserInfoByAccessToken(userInfo: userInfo, completion: completion)
                }
            } else {
                completion(code, message, nil)
            }
        }
    }

    //    MARK: ---------- UserInfo API ----------
    public func authByToken(userInfo: UserInfo?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
       let secret = self.authRequest.client_secret
       let secretStr = (secret == nil ? "&code_verifier=" + self.authRequest.codeVerifier : "&client_secret=" + (secret ?? ""))
       
       let body = "client_id=" + Authing.getAppId()
       + "&grant_type=http://authing.cn/oidc/grant_type/authing_token"
       + "&token=" + (userInfo?.token ?? "")
       + "&scope=" + self.authRequest.scope.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
       + "&prompt=" + "consent"
       + secretStr
       + "&redirect_uri=\(self.authRequest.redirect_uri ?? "")"

       request(userInfo: nil, endPoint: "/oidc/token", method: "POST", body: body) { code, message, data in
         if (code == 200) {
             AuthClient().createUserInfo(userInfo, code, message, data, completion: completion)
         } else {
             completion(code, message, nil)
         }
       }
    }
        
    public func getUserInfoByAccessToken(userInfo: UserInfo?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        request(userInfo: userInfo, endPoint: "/oidc/me", method: "GET", body: nil) { code, message, data in
            if (code == 200) {
                AuthClient().createUserInfo(userInfo, code, message, data, completion: completion)
            } else {
                completion(code, message, nil)
            }
        }
    }

    public func getNewAccessTokenByRefreshToken(userInfo: UserInfo?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let rt = userInfo?.refreshToken ?? ""
        
        let secret = self.authRequest.client_secret
        let secretStr = (secret == nil ? "&code_verifier=" + self.authRequest.codeVerifier : "&client_secret=" + (secret ?? ""))

        let body = "client_id="
        + Authing.getAppId()
        + "&grant_type=refresh_token"
        + "&refresh_token=" + rt
        + secretStr

        request(userInfo: nil, endPoint: "/oidc/token", method: "POST", body: body) { code, message, data in
            if (code == 200) {
                AuthClient().createUserInfo(userInfo, code, message, data, completion: completion)
            } else {
                completion(code, message, nil)
            }
        }
    }

    public func request(userInfo: UserInfo?, endPoint: String, method: String, body: String?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        Authing.getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))\(endPoint)"
                self._request(userInfo: userInfo, config: config, urlString: urlString, method: method, body: body, completion: completion)
            } else {
               completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage(), nil)
            }
        }
    }
   
    private func _request(userInfo: UserInfo?, config: Config?, urlString: String, method: String, body: String?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(Util.getDeviceID(), forHTTPHeaderField: "x-authing-device-id")

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
               ALog.e(OIDCClient.self, "network error \(url!) \n\(error!)")

                completion(ErrorCode.netWork.rawValue, ErrorCode.netWork.errorMessage(), nil)
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode: Int = (httpResponse?.statusCode)!
            
            if (data != nil) {
                if statusCode == 200, let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
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

//MARK: ---------- URLSessionTaskDelegate ----------
extension OIDCClient: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

