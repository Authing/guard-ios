//
//  LoginButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import UIKit

open class LoginButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.backgroundColor = Const.Color_Authing_Main
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), for: .highlighted)
        let loginText = NSLocalizedString("authing_login", bundle: Bundle(for: Self.self), comment: "")
        self.setTitle(loginText, for: .normal)
        
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let vc: AuthViewController? = viewController
        if (vc == nil) {
            return
        }
        
        let tfAccountView: UIView? = Util.findView(self, viewClass: AccountTextField.self)
        let tfPasswordView: UIView? = Util.findView(self, viewClass: PasswordTextField.self)
        if (tfAccountView != nil && tfPasswordView != nil) {
            let tfAccount: AccountTextField = tfAccountView as! AccountTextField
            let tfPassword: PasswordTextField = tfPasswordView as! PasswordTextField
            let account: String? = tfAccount.text
            let password: String? = tfPassword.text
            if (!account!.isEmpty && !password!.isEmpty) {
                loginByAccount(account!, password!)
            }
        }
    }
    
    private func loginByAccount(_ account: String, _ password: String) {
        AuthClient.loginByAccount(account: account, password: password) { code, message, userInfo in
            if (code == 200) {
                DispatchQueue.main.async() {
                    let vc: AuthViewController? = self.viewController
                    if (vc == nil) {
                        return
                    }
                    
                    vc?.complete(userInfo)
                }
            }
        }
    }
}
