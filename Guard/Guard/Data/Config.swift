//
//  Config.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import Foundation

public class Config {
    
    var data: NSDictionary? {
        didSet {
            let loginTabs: NSDictionary? = data?["loginTabs"] as? NSDictionary
            if (loginTabs != nil) {
                loginMethods = loginTabs!["list"] as? [String]
                defaultLoginMethod = loginTabs!["default"] as? String
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
            
            let passwordTabConfig: NSDictionary? = data?["passwordTabConfig"] as? NSDictionary
            if (passwordTabConfig != nil) {
                enabledLoginMethods = passwordTabConfig?["enabledLoginMethods"] as? [String]
            }
            let registerTabs: NSDictionary? = data?["registerTabs"] as? NSDictionary
            if (registerTabs != nil) {
                registerMethods = registerTabs!["list"] as? [String]
                defaultRegisterMethod = registerTabs!["default"] as? String
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
            completeFieldsPlace = data?["complateFiledsPlace"] as? [String]
            extendedFields = data?["extendsFields"] as? [NSDictionary]
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
}
