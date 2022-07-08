//
//  Client.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/23.
//

public class Client: NSObject {
    var config: Config? = nil
    
    public override init() { }
    
    public init(_ config: Config?) {
        self.config = config
    }
    
    public func getConfig(completion: @escaping(Config?)->Void) {
        var c: Config? = config
        if c == nil {
            c = Authing.sConfig
        }
        guard c != nil else {
            ALog.e(Self.self, "Cannot get config. Maybe not calling start(appId)?. app id:\(Authing.getAppId())")
            completion(nil)
            return
        }
        
        c?.getConfig { configuration in
            completion(configuration)
        }
    }
}
