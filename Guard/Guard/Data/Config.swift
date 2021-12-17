//
//  Config.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import Foundation

public class Config {
    var userPoolId: String?
    var identifier: String?
    var name: String?
    var logo: String?
    var userpoolLogo: String?
    
    public static func parse(data: NSDictionary?) -> Config {
        var config: Config
        config = Config()
        config.userPoolId = data!["userPoolId"] as? String
        config.identifier = data!["identifier"] as? String
        config.name = data!["name"] as? String
        config.logo = data!["logo"] as? String
        config.userpoolLogo = data!["userpoolLogo"] as? String
        return config
    }
    
    public func getLogoUrl() -> String? {
        if (logo != nil) {
            return logo
        }
        return userpoolLogo
    }
}
