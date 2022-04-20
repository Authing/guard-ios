//
//  Wechat.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/4.
//

import UIKit

open class WechatLoginButton: SocialLoginButton, WXApiDelegate {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        setBackgroundImage(UIImage(named: "authing_wechat", in: Bundle(for: WechatLoginButton.self), compatibleWith: nil), for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {

        loading?.startAnimating()

        WechatLogin.shared.login(viewController: authViewController ?? UIViewController()) { code, message, userInfo in
            DispatchQueue.main.async() {
                self.loading?.stopAnimating()
                if (code == 200) {
                    if let vc = self.authViewController?.navigationController as? AuthNavigationController {
                        vc.complete(code, message, userInfo)
                    }
                } else {
                    Util.setError(self, message)
                }
            }
        }
    }
    

}

open class WechatLogin: NSObject, WXApiDelegate {
        
    @objc public static let shared = WechatLogin()
    private override init() {}
    
    fileprivate var receiveCallBack: Authing.AuthCompletion?

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
    
    fileprivate func handleOpenURL(url: URL) -> Bool {
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
