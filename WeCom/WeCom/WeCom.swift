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
    
    private var receiveCallBack: Guard.AuthCompletion?

    /**
     - 初始化企业微信配置
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
    
    /**
     - 不使用 Guard 内置按钮 直接调用登录事件
     - Parameters:
        - completion:
        - code
        - message
        - userInfo
     */
    public func login(completion: @escaping Guard.AuthCompletion) -> Void {
        self.sendRequest()
        self.receiveCallBack = completion
    }
    
    @objc func sendRequest() {
        let req = WWKSSOReq()
        WWKApi.send(req)
    }
    
    public func handleOpenURL(url: URL) -> Bool {
        return WWKApi.handleOpen(url, delegate: self)
    }
    
    public func onResp(_ resp: WWKBaseResp!) {
        
        let rawValue = Guard.NotifyName.notify_wecom_Receive.rawValue
        let name = Notification.Name.init(rawValue: rawValue)
        
        if resp is WWKSSOResp{

            let r: WWKSSOResp = resp as! WWKSSOResp

            AuthClient().loginByWeCom(r.code ?? "") { code, msg, userInfo in
                NotificationCenter.default.post(name: name, object: ["code" : code,
                                                                     "msg" : msg ?? "",
                                                                     "userInfo" : userInfo as Any])
                self.receiveCallBack?(code, msg, userInfo)
            }
        }else{
            
            NotificationCenter.default.post(name: name, object: ["code" : resp.errCode,
                                                                 "msg" : resp.errStr,
                                                                 "userInfo" : nil])
            self.receiveCallBack?(Int(resp.errCode), resp.errStr, nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
