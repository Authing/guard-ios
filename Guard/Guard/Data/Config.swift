//
//  Config.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//


import WebKit

public class Config: NSObject {
    
    open var data: NSDictionary? {
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
                    let arr = (loginMethods ?? []) + enabledLoginMethods
                    loginMethods = arr.enumerated().filter { (index, value) -> Bool in
                        return arr.firstIndex(of: value) == index
                    }.map {
                        $0.element
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
    
    open var userPoolId: String? {
        get { return data?["userPoolId"] as? String }
    }
    open var identifier: String? {
        get { return data?["identifier"] as? String }
    }
    open var name: String? {
        get { return data?["name"] as? String }
    }
    open var logo: String? {
        get { return data?["logo"] as? String }
    }
    open var userpoolLogo: String? {
        get { return data?["userpoolLogo"] as? String }
    }
    
    open var verifyCodeLength: Int? {
        get { return data?["verifyCodeLength"] as? Int }
    }
    
    open var requestHostname: String? {
        get { return data?["requestHostname"] as? String }
    }
    
    public func getLogoUrl() -> String? {
        return logo ?? userpoolLogo
    }
    open var loginMethods: [String]?
    open var defaultLoginMethod: String?
    open var enabledLoginMethods: [String]?
    open var registerMethods: [String]?
    open var defaultRegisterMethod: String?
    open var passwordStrength: Int? {
        get { return data?["passwordStrength"] as? Int }
    }
    
    open var socialConnections: [NSDictionary]?
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
    
    open var completeFieldsPlace: [String]?
    open var extendedFields: [NSDictionary]? // user info complete
    open var agreements: [NSDictionary]?
    open var redirectUris: [String]?
    
    open var internationalSmsConfigEnable: Bool?
    
    // MARK: Request
    open var appId: String!
    open var userAgent: String?
    var isGettingConfig: Bool = false
    private var configListeners = [ConfigCompletion]()
    
    public init(appId: String) {
        super.init()
        self.appId = appId
        requestPublicConfig()
    }
    
    public func requestPublicConfig() {
        isGettingConfig = true
        let url = "https://console." + Authing.getHost() + "/api/v2/applications/" + appId + "/public-config"
        AuthClient().request(config: nil, urlString: url, method: "get", body: nil) { code, message, jsonData in
            if (code != 200) {
                ALog.e(Self.self, "error when getting public cofig:\(message!)")
            }
            self.fireCallback(jsonData)
        }
    }
    
    private func fireCallback(_ data: NSDictionary?) {
        DispatchQueue.main.async() {
            self.data = data
            self.userAgent = WKWebView().value(forKey: "userAgent") as? String
            if self.configListeners.count > 0 {
                ALog.d(Self.self, "firing (\(self.configListeners.count)) callbacks for config")
            }
            for completion in self.configListeners {
                completion(self)
            }
            self.isGettingConfig = false
            self.configListeners.removeAll()
        }
    }
    
    public func getConfig(completion: @escaping(Config?)->Void) {
        if isGettingConfig {
            ALog.w(Self.self, "getting config while requesting")
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
