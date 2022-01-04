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
    }
    
    @objc private func onClick(sender: UIButton) {
        Authing.wechatDelegate = self
        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        WXApi.sendAuthReq(req, viewController: viewController!, delegate: self) { success in
            print("wechat auth req result:\(success)")
        }
    }

    public func onResp(_ resp: BaseResp) {
        Authing.wechatDelegate = nil
        
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
