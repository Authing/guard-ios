//
//  LoginButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import UIKit

open class LoginButton: PrimaryButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let loginText = NSLocalizedString("authing_login", bundle: Bundle(for: Self.self), comment: "")
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let vc: AuthViewController? = viewController
        if (vc == nil) {
            return
        }
        
        let tfPhone: PhoneNumberTextField? = Util.findView(self, viewClass: PhoneNumberTextField.self)
        let tfCode: VerifyCodeTextField? = Util.findView(self, viewClass: VerifyCodeTextField.self)
        if (tfPhone != nil && tfCode != nil) {
            let phone: String? = tfPhone!.text
            let code: String? = tfCode!.text
            if (!phone!.isEmpty && !code!.isEmpty) {
                loginByPhoneCode(phone!, code!)
            }
            return
        }
        
        let tfAccount: AccountTextField? = Util.findView(self, viewClass: AccountTextField.self)
        let tfPassword: PasswordTextField? = Util.findView(self, viewClass: PasswordTextField.self)
        if (tfAccount != nil && tfPassword != nil) {
            let account: String? = tfAccount!.text
            let password: String? = tfPassword!.text
            if (!account!.isEmpty && !password!.isEmpty) {
                loginByAccount(account!, password!)
            }
        }
    }
    
    private func loginByPhoneCode(_ phone: String, _ code: String) {
        startLoading()
        AuthClient.loginByPhoneCode(phone: phone, code: code) { code, message, userInfo in
            self.stopLoading()
            if (code == 200) {
                DispatchQueue.main.async() {
                    let vc: AuthViewController? = self.viewController
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
    
    private func loginByAccount(_ account: String, _ password: String) {
        startLoading()
        AuthClient.loginByAccount(account: account, password: password) { code, message, userInfo in
            self.stopLoading()
            if (code == 200) {
                DispatchQueue.main.async() {
                    let vc: AuthViewController? = self.viewController
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
