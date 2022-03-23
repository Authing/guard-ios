//
//  Client.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/23.
//

import UIKit

public class Client {
    var config: Config? = nil
    
    public init() { }
    
    public init(_ config: Config?) {
        self.config = config
    }
    
    public func getConfig(completion: @escaping(Config?)->Void) {
        var c: Config? = config
        if c == nil {
            c = Guard.sConfig
        }
        guard c != nil else {
            ALog.e(AuthClient.self, "Cannot get config. Maybe not calling start(appId)?. app id:\(Guard.getAppId())")
            completion(nil)
            return
        }
        
        c?.getConfig { configuration in
            completion(configuration)
        }
    }
}
