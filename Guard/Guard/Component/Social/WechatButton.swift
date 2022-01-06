//
//  Wechat.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/4.
//

import UIKit

open class WechatButton: UIButton, WXApiDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        setBackgroundImage(UIImage(named: "authing_wechat", in: Bundle(for: WechatButton.self), compatibleWith: nil), for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(self.wechatLoginOK(notification:)), name: Notification.Name("wechatLoginOK"), object: nil)
    }
    
    @objc private func onClick(sender: UIButton) {
        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        WXApi.sendAuthReq(req, viewController: viewController!, delegate: self) { success in
            print("wechat auth req result:\(success)")
        }
    }
    
    @objc func wechatLoginOK(notification: Notification) {
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
        
        AuthClient.loginByWechat(code!) { code, message, userInfo in
//            self.stopLoading()
            if (code == 200) {
                DispatchQueue.main.async() {
                    let vc = self.viewController?.navigationController as? AuthNavigationController
                    if (vc == nil) {
                        return
                    }
                    
                    vc?.complete(userInfo)
                }
            } else {
                Util.setError(self, message)
            }
        }
    }
}
