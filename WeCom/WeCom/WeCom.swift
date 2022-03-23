//
//  WeCom.swift
//  WeCom
//
//  Created by JnMars on 2022/3/23.
//

import Foundation
import Guard

open class WeCom: NSObject, WWKApiDelegate {
        
    @objc public static let shared = WeCom()
    private override init() {}
    
    /**
     - 注册企业微信
     - Parameters:
        - appid:  企业微信开发者ID
        - corpid:  企业微信企业ID
        - agentid:  企业微信企业应用ID
     */
    public func registerApp(appId: String, corpId: String, agentId: String) {
        
        let rawValue = Guard.NotifyName.notify_wecom_register.rawValue
        let name = Notification.Name.init(rawValue: rawValue)
        NotificationCenter.default.addObserver(self, selector: #selector(sendRequest), name: name, object: nil)
        WWKApi.registerApp(appId, corpId: corpId, agentId: agentId)
    }
    
    @objc func sendRequest() {
        let req = WWKSSOReq()
        WWKApi.send(req)
    }
    
    public func handleOpenURL(url: URL) -> Bool {
        return WWKApi.handleOpen(url, delegate: self)
    }
    
    public func onResp(_ resp: WWKBaseResp!) {
        
        if resp is WWKSSOResp{
            print(resp.errCode)
            let r: WWKSSOResp = resp as! WWKSSOResp

            let rawValue = Guard.NotifyName.notify_wecom_Receive.rawValue
            let name = Notification.Name.init(rawValue: rawValue)

            AuthClient().loginByWeCom(r.code ?? "") { code, msg, userInfo in
                NotificationCenter.default.post(name: name, object: ["code" : code,
                                                                     "msg" : msg ?? "",
                                                                     "userInfo" : userInfo as Any])
            }
        }
    }
    
}
