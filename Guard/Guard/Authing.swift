//
//  Authing.swift
//  Guard
//
//  Created by Lance Mao on 2021/11/23.
//

import Foundation

typealias ConfigCompletion = (Config?) -> Void

public class Authing {
    private static var sHost = "authing.cn"
    private static var sAppId = ""
    private static var sConfig: Config? = nil
    private static var isGettingConfig: Bool = false
    private static var configListeners = [ConfigCompletion]()
    
    public static func start(appid: String) {
        sAppId = appid
        requestPublicConfig()
        SDKUsageTask.report();
    }
    
    public static func getAppId() -> String {
        return sAppId
    }
    
    public static func setHost(host: String) {
        sHost = host
    }
    
    public static func getHost() -> String {
        return sHost
    }
    
    public static func getConfig(completion: @escaping(Config?)->Void) {
        // add listener first. otherwise callback might be fired in the other thread
        // and this listener is missed
        if (isGettingConfig) {
            configListeners.append(completion);
        }
        
        if (sConfig != nil) {
            configListeners.removeAll()
            completion(sConfig)
        }
    }
    
    private static func requestPublicConfig() {
        isGettingConfig = true
        sConfig = nil
        let url = "https://console." + sHost + "/api/v2/applications/" + sAppId + "/public-config"
        Guardian.request(config: nil, urlString: url, method: "get", body: nil) { code, message, jsonData in
            if (code == 200) {
                sConfig = Config.parse(data: jsonData)
                fireCallback()
            } else {
                print("error when getting public cofig:\(message!)")
                fireCallback()
            }
        }
    }
    
    private static func fireCallback() {
        DispatchQueue.main.async() {
            for completion in configListeners {
                completion(sConfig)
            }
            isGettingConfig = false
            configListeners.removeAll()
        }
    }
}
