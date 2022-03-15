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
        NotificationCenter.default.addObserver(self, selector: #selector(self.wechatLoginOK(notification:)), name: Notification.Name("wechatLoginOK"), object: nil)
        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        WXApi.sendAuthReq(req, viewController: viewController!, delegate: self) { success in
            print("wechat auth req result:\(success)")
        }
        
        loading?.startAnimating()
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

    public func onResp(_ resp: BaseResp) {
        let authResp = resp as? SendAuthResp
        let code = authResp?.code
        
        guard code != nil else {
            return
        }
        
        AuthClient().loginByWechat(code!) { code, message, userInfo in
            DispatchQueue.main.async() {
                self.loading?.stopAnimating()
                if (code == 200) {
                    if let vc = self.viewController?.navigationController as? AuthNavigationController {
                        vc.complete(code, message, userInfo)
                    }
                } else {
                    Util.setError(self, message)
                }
            }
        }
    }
}
