//
//  SocialCreateAccountButton.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//

import Foundation

class SocialCreateAccountButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        
        self.backgroundColor = UIColor.init(hex: "#F2F3F5")
        self.setTitleColor(UIColor.init(hex: "#1D2129"), for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        startLoading()
        
        let key = (authViewController?.authFlow?.data.value(forKey: AuthFlow.KEY_USER_INFO) as? UserInfo)?.socialBindingData?["key"] as? String ?? ""
        AuthClient().bindWechatWithRegister(key: key) { code, message, userInfo in
            self.stopLoading()
            DispatchQueue.main.async() {
                if (code == 200) {
                    if let flow = self.authViewController?.authFlow {
                        flow.complete(code, message, userInfo)
                    }
                } else {
                    Util.setError(self, message)
                }
            }
        }
    }
}
