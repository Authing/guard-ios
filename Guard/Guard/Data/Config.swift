//
//  Config.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import Foundation
import UIKit

public class Config {
    
    var data: NSDictionary? {
        didSet {
            if let loginTabs: NSDictionary = data?["loginTabs"] as? NSDictionary{
                loginMethods = loginTabs["list"] as? [String]
                defaultLoginMethod = loginTabs["default"] as? String
                var i: Int = 0
                loginMethods?.forEach({ method in
                    if (method == defaultLoginMethod) {
                        loginMethods?.remove(at: i)
                        loginMethods?.insert(method, at: 0)
                        return
                    }
                    i+=1
                })
            }
            
            if let verifyCodeTabConfig: NSDictionary = data?["verifyCodeTabConfig"] as? NSDictionary{
                if let enabledLoginMethods: [String] = verifyCodeTabConfig["enabledLoginMethods"] as? [String]{
                    enabledLoginMethods.forEach { method in
                        if method == "email-code" {
                            loginMethods?.append(method)
                        }
                    }
                }
            }
            if let passwordTabConfig: NSDictionary = data?["passwordTabConfig"] as? NSDictionary{
                enabledLoginMethods = passwordTabConfig["enabledLoginMethods"] as? [String]
            }
            if let registerTabs: NSDictionary = data?["registerTabs"] as? NSDictionary{
                registerMethods = registerTabs["list"] as? [String]
                defaultRegisterMethod = registerTabs["default"] as? String
                var i: Int = 0
                registerMethods?.forEach({ method in
                    if (method == defaultRegisterMethod) {
                        registerMethods?.remove(at: i)
                        registerMethods?.insert(method, at: 0)
                        return
                    }
                    i+=1
                })
            }
            if let internationalSmsConfig: NSDictionary = data?["internationalSmsConfig"] as? NSDictionary {
                internationalSmsConfigEnable = internationalSmsConfig["enabled"] as? Bool
            }
            completeFieldsPlace = data?["complateFiledsPlace"] as? [String]
            extendedFields = data?["extendsFields"] as? [NSDictionary]
            agreements = data?["agreements"] as? [NSDictionary]
            redirectUris = data?["redirectUris"] as? [String]
        }
    }
    
    var userPoolId: String? {
        get { return data?["userPoolId"] as? String }
    }
    var identifier: String? {
        get { return data?["identifier"] as? String }
    }
    var name: String? {
        get { return data?["name"] as? String }
    }
    var logo: String? {
        get { return data?["logo"] as? String }
    }
    var userpoolLogo: String? {
        get { return data?["userpoolLogo"] as? String }
    }
    
    var verifyCodeLength: Int? {
        get { return data?["verifyCodeLength"] as? Int }
    }
    
    public func getLogoUrl() -> String? {
        return logo ?? userpoolLogo
    }
    var loginMethods: [String]?
    var defaultLoginMethod: String?
    var enabledLoginMethods: [String]?
    var registerMethods: [String]?
    var defaultRegisterMethod: String?
    var passwordStrength: Int? {
        get { return data?["passwordStrength"] as? Int }
    }
    
    var socialConnections: [NSDictionary]?
    public func getConnectionId(type: String) -> String? {
        let connections: [NSDictionary]? = data?["ecConnections"] as? [NSDictionary]
        var cid: String? = nil
        connections?.forEach({ connection in
            if connection["type"] as? String == type {
                cid = connection["id"] as? String
            }
        })
        return cid
    }
    
    var completeFieldsPlace: [String]?
    var extendedFields: [NSDictionary]? // user info complete
    var agreements: [NSDictionary]?
    var redirectUris: [String]?
    
    var internationalSmsConfigEnable: Bool?
    
    // MARK: Request
    var appId: String
    var isGettingConfig: Bool = false
    private var configListeners = [ConfigCompletion]()
    
    public init(appId: String) {
        self.appId = appId
        requestPublicConfig()
    }
    
    private func requestPublicConfig() {
        isGettingConfig = true
        let url = "https://console." + Authing.getHost() + "/api/v2/applications/" + appId + "/public-config"
        AuthClient().request(config: nil, urlString: url, method: "get", body: nil) { code, message, jsonData in
            if (code == 200) {
                self.data = jsonData
            } else {
                ALog.e(Self.self, "error when getting public cofig:\(message!)")
            }
            self.fireCallback()
        }
    }
    
    private func fireCallback() {
        DispatchQueue.main.async() {
            for completion in self.configListeners {
                completion(self)
            }
            self.isGettingConfig = false
            self.configListeners.removeAll()
        }
    }
    
    public func getConfig(completion: @escaping(Config?)->Void) {
        if isGettingConfig {
            configListeners.append(completion);
        } else if data != nil {
            configListeners.removeAll()
            completion(self)
        } else {
            configListeners.append(completion);
            requestPublicConfig()
        }
    }
}
