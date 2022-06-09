//
//  AuthRequest.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/2.
//

import Foundation
import CommonCrypto

open class AuthRequest {
    public var client_id: String
    public var client_secret: String? = nil
    public var redirect_uri: String
    public var response_type: String
    public var scope: String
    public var nonce: String
    public var state: String
    public var uuid: String? = nil
    public var codeVerifier: String
    public var codeChallenge: String? = nil
    var token: String? = nil
    public var returnAuthorizationCode: Bool? = false
    
    public init() {
        client_id = Authing.getAppId()
        redirect_uri = "https://console.authing.cn/console/get-started/\(client_id)";
        response_type = "code";
        scope = "openid profile email phone username address offline_access role extended_fields";
        nonce = Util.randomString(length: 10)
        state = Util.randomString(length: 10)
        codeVerifier = Util.randomString(length: 43)
        codeChallenge = generateCodeChallenge(codeVerifier)
        returnAuthorizationCode = false
    }
    
    private func generateCodeChallenge(_ verifier: String) -> String? {
        if let inputData: NSData = verifier.data(using: .utf8) as NSData? {
            let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
            var hash = [UInt8](repeating: 0, count: digestLength)
            CC_SHA256(inputData.bytes, UInt32(inputData.count), &hash)
            let data = NSData(bytes: hash, length: digestLength)
            var result = data.base64EncodedString()
            
            // url safe
            result = result.replacingOccurrences(of: "+", with: "-")
            result = result.replacingOccurrences(of: "/", with: "_")
            result = result.replacingOccurrences(of: "=", with: "")
            return result
        }
        return nil
    }
    
    public func getScopesAsConsentBody() -> String{
        let scopes: [Substring] = scope.split(separator: " ")
        let scopesStrs: [String] = scopes.compactMap { "\($0)" }
        if scopes.count == 0{
            return scope
        }
        
        var scopeStr = ""
        for str: String in scopesStrs {
            scopeStr.append("consent[acceptedScopes][]=")
            scopeStr.append(str)
            scopeStr.append("&")
        }
        
        return scopeStr
    }
}
