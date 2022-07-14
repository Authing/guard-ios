//
//  RegisterButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

open class RegisterButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let text = "authing_register".L
        self.setTitle(text, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        Util.setError(self, "")
        Util.getConfig(self) { config in
            self._onClick(config)
        }
    }
    
    private func _onClick(_ config: Config?) {
        let privacyBox = Util.findView(self, viewClass: PrivacyConfirmBox.self) as? PrivacyConfirmBox
        if (privacyBox != nil && !privacyBox!.isHidden) {
            let lang = Util.getLangHeader()
            if let agreements = config?.agreements {
                for agreement in agreements {
                    if (lang == agreement["lang"] as? String) {
                        let availableAt = agreement["availableAt"] as? Int
                        if (availableAt == nil) {
                            continue
                        }
                        if (availableAt! == 2 || availableAt! == 1) {
                            let warning = "authing_agree_privacy_first".L
                            if (agreement["required"] as? Bool == true && !privacyBox!.isChecked) {
                                Util.setError(self, warning)
                                return;
                            }
                            break
                        }
                    }
                }
            }
        }
        
        if let tfPhone: PhoneNumberTextField = Util.findView(self, viewClass: PhoneNumberTextField.self),
           let tfCode: VerifyCodeTextField = Util.findView(self, viewClass: VerifyCodeTextField.self) {
            if let phone = tfPhone.text,
               let code = tfCode.text {

                registerByPhoneCode(tfPhone.countryCode, phone, code)
                return
            }
        }
        
        if let tfEmail: EmailTextField = Util.findView(self, viewClass: EmailTextField.self),
           let tfPassword: PasswordTextField = Util.findView(self, viewClass: PasswordTextField.self) {
            if let email = tfEmail.text,
               let password = tfPassword.text {
                registerByEmail(email, password)
                return
            }
        }
        
        if let tfEmail: EmailTextField = Util.findView(self, viewClass: EmailTextField.self),
           let tfCode: VerifyCodeTextField = Util.findView(self, viewClass: VerifyCodeTextField.self) {
            if let email = tfEmail.text,
               let code = tfCode.text {
                registerByEmailCode(email, code)
                return
            }
        }
        
    }
    
    private func registerByPhoneCode(_ countryCode: String? = nil, _ phone: String, _ code: String) {
        startLoading()
        let authProtocol = authViewController?.authFlow?.authProtocol ?? .EInHouse
        if authProtocol == .EInHouse {
            Util.getAuthClient(self).registerByPhoneCode(phoneCountryCode: countryCode, phone: phone, code: code) { code, message, userInfo in
                self.done(code: code, message: message, userInfo: userInfo)
            }
        } else {
            OIDCClient().registerByPhoneCode(phoneCountryCode: countryCode, phone: phone, code: code) { code, message, userInfo in
                self.done(code: code, message: message, userInfo: userInfo)
            }
        }
    }
    
    private func registerByEmail(_ email: String, _ password: String) {
        startLoading()
        let authProtocol = authViewController?.authFlow?.authProtocol ?? .EInHouse
        if authProtocol == .EInHouse {
            Util.getAuthClient(self).registerByEmail(email: email, password: password) { code, message, userInfo in
                self.done(code: code, message: message, userInfo: userInfo)
            }
        } else {
            OIDCClient().registerByEmail(email: email, password: password) { code, message, userInfo in
                self.done(code: code, message: message, userInfo: userInfo)
            }
        }
    }
    
    private func registerByEmailCode(_ email: String, _ code: String) {
        startLoading()
        let authProtocol = authViewController?.authFlow?.authProtocol ?? .EInHouse
        if authProtocol == .EInHouse {
            Util.getAuthClient(self).registerByEmailCode(email: email, code: code) { code, message, userInfo in
                self.done(code: code, message: message, userInfo: userInfo)
            }
        } else {
            OIDCClient().registerByEmailCode(email: email, code: code) { code, message, userInfo in
                self.done(code: code, message: message, userInfo: userInfo)
            }
        }
    }
    
    private func done(code: Int, message: String?, userInfo: UserInfo?) {
        self.stopLoading()
        if (code != 200) {
            Util.setError(self, message)
        }
        
        if (authCompletion != nil) {
            authCompletion?(code, message, userInfo)
        } else if (code == 200) {
            DispatchQueue.main.async() {
                if let vc = self.authViewController?.navigationController as? AuthNavigationController {
                    vc.complete(code, message, userInfo)
                }
            }
        }
    }
}
