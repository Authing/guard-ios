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
