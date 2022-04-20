//
//  WechatLogin.swift
//  Guard
//
//  Created by JnMars on 2022/4/20.
//

import Foundation

open class WechatLogin: NSObject, WXApiDelegate {
        
    @objc public static let shared = WechatLogin()
    private override init() {}
    
    private var receiveCallBack: Authing.AuthCompletion?

    public func registerApp(appId: String, universalLink: String) {
        
        let ret = WXApi.registerApp(appId, universalLink: universalLink)
        if (!ret) {
            print("set up wechat failed!")
        }
    }
    
    /// 微信一键登录方法
    public func login(viewController:UIViewController, completion: @escaping Authing.AuthCompletion) -> Void {
        self.sendRequest(viewController: viewController)
        self.receiveCallBack = completion
    }
    
    @objc func sendRequest(viewController: UIViewController) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.wechatLoginOK(notification:)), name: Notification.Name("wechatLoginOK"), object: nil)

        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        WXApi.sendAuthReq(req, viewController: viewController, delegate: self) { success in
            ALog.i(Self.self, "wechat auth req result:\(success)")
        }
    }
    
    @objc func wechatLoginOK(notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        let userActivity = notification.object as? NSUserActivity
        if (userActivity != nil) {
            WXApi.handleOpenUniversalLink(userActivity!, delegate: self)
        } else {
            let url = notification.object as? URL
            if (url != nil) {
                WXApi.handleOpen(url!, delegate: self)
            }
        }
    }
    
    private func handleOpenURL(url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    public func onResp(_ resp: BaseResp) {
        let authResp = resp as? SendAuthResp

        if let code = authResp?.code{
            AuthClient().loginByWechat(code) { c, message, userInfo in
                self.receiveCallBack?(c, message, userInfo)
            }
        }else {
            self.receiveCallBack?(Int(resp.errCode), resp.errStr, nil)
        }
    }
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
