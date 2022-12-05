//
//  SocialBindingAccountButton.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//

import Foundation

class SocialBindingAccountButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let loginText = "authing_login".L
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        
        let key = (authViewController?.authFlow?.data.value(forKey: AuthFlow.KEY_USER_INFO) as? UserInfo)?.socialBindingData?["key"] as? String ?? ""

        if let tfPhone: PhoneNumberTextField = Util.findView(self, viewClass: PhoneNumberTextField.self),
           let tfCode: VerifyCodeTextField = Util.findView(self, viewClass: VerifyCodeTextField.self) {
                if let phone = tfPhone.text, let code = tfCode.text {
                    if !(Validator.isValidPhone(phone: phone)) {
                        Util.setError(tfPhone, "authing_invalid_phone".L)
                        return
                    }
                    if phone == "" {
                        Util.setError(tfPhone, "authing_phone_none".L)
                    } else if code == "" {
                        Util.setError(tfCode, "authing_verifycode_none".L)
                    } else {
                        startLoading()
                        AuthClient().bindWechatByPhoneCode(phoneCountryCode: tfPhone.countryCode, phone: phone, code: code, key: key) { code, message, userInfo in
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
                    return
                }
        }
        
        if let tfAccount: AccountTextField = Util.findView(self, viewClass: AccountTextField.self),
            let tfPassword: PasswordTextField = Util.findView(self, viewClass: PasswordTextField.self) {
            if let account = tfAccount.text,
               let password = tfPassword.text {
                if account == "" {
                    Util.setError(tfAccount, "authing_account_none".L)
                } else if password == "" {
                    Util.setError(tfPassword, "authing_password_none".L)
                } else {
                    startLoading()
                    AuthClient().bindWechatByAccount(account: account, password: password, key: key) { code, message, userInfo in
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
                return
            }
        }
        
        if let tfEmail: EmailTextField = Util.findView(self, viewClass: EmailTextField.self),
           let tfEmailCode: VerifyCodeTextField = Util.findView(self, viewClass: VerifyCodeTextField.self) {
            if let email = tfEmail.text,
               let code = tfEmailCode.text {
                if !(Validator.isValidEmail(email: email)) {
                    Util.setError(tfEmail, "authing_invalid_email".L)
                    return
                }
                if email == "" {
                    Util.setError(tfEmail, "authing_email_none".L)
                } else if code == "" {
                    Util.setError(tfEmailCode, "authing_verifycode_none".L)
                } else {
                    startLoading()
                    AuthClient().bindWechatByEmailCode(email: email, code: code, key: key) { code, message, userInfo in
                        self.stopLoading()
                        Toast.show(text: message ?? "")
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
        }
    }
}
