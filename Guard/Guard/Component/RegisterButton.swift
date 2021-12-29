//
//  RegisterButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class RegisterButton: PrimaryButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let text = NSLocalizedString("authing_register", bundle: Bundle(for: Self.self), comment: "")
        self.setTitle(text, for: .normal)
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
            let tfPassword: PasswordTextField? = Util.findView(self, viewClass: PasswordTextField.self)
            let phone: String? = tfPhone?.text
            let password: String? = tfPassword?.text
            let code: String? = tfCode?.text
            if (!phone!.isEmpty && !password!.isEmpty && !code!.isEmpty) {
                registerByPhoneCode(phone!, password!, code!)
            }
            return
        }
        
        let tfEmail: EmailTextField? = Util.findView(self, viewClass: EmailTextField.self)
        let tfPassword: PasswordTextField? = Util.findView(self, viewClass: PasswordTextField.self)
        if (tfEmail != nil && tfPassword != nil) {
            let email: String? = tfEmail!.text
            let password: String? = tfPassword!.text
            if (!email!.isEmpty && !password!.isEmpty) {
                registerByEmail(email!, password!)
            }
        }
    }
    
    private func registerByPhoneCode(_ phone: String, _ password: String, _ code: String) {
        startLoading()
        AuthClient.registerByPhoneCode(phone: phone, password: password, code: code) { code, message, userInfo in
            self.stopLoading()
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
    
    private func registerByEmail(_ email: String, _ password: String) {
        startLoading()
        AuthClient.registerByEmail(email: email, password: password) { code, message, userInfo in
            self.stopLoading()
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
