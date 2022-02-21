//
//  UserInfoCompleteButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/17.
//

import UIKit

open class UserInfoCompleteButton: PrimaryButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let vc: AuthViewController? = viewController
        if (vc == nil) {
            return
        }
        
        let container: UserInfoCompleteContainer? = Util.findView(self, viewClass: UserInfoCompleteContainer.self)
        if (container == nil) {
            return
        }
        
        Util.setError(self, "")
        for sub in container!.subviews {
            let emailForm = sub as? UserInfoCompleteFieldEmail
            if (emailForm != nil) {
                bindEmail(emailForm!)
            }
        }
        
    }
    
    private func bindEmail(_ form: UserInfoCompleteFieldEmail) {
        let email = form.getEmail()
        let code = form.getCode()
        guard email != nil && code != nil else {
            return
        }
        
        AuthClient.bindEmail(email: email!.lowercased(), code: code!) { code, message, userInfo in
            if (code == 200) {
                
            } else {
                Util.setError(self, message)
            }
        }
    }
}
