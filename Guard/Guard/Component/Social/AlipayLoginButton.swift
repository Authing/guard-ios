//
//  AlipayButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/5.
//

import UIKit

open class AlipayLoginButton: SocialLoginButton {

    let alipay: Alipay = Alipay()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        setBackgroundImage(UIImage(named: "authing_alipay", in: Bundle(for: WechatLoginButton.self), compatibleWith: nil), for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        loading?.startAnimating()
        alipay.login { code, message, userInfo in
            DispatchQueue.main.async() {
                self.loading?.stopAnimating()
                if (code == 200) {
                    if let vc = self.viewController?.navigationController as? AuthNavigationController {
                        vc.complete(userInfo)
                    }
                } else {
                    Util.setError(self, message)
                }
            }
        }
    }
}
