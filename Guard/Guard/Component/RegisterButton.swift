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
//                            let warning = "authing_agree_privacy_first".L
                            if (agreement["required"] as? Bool == true && !privacyBox!.isChecked) {
//                                Util.setError(self, warning)
                                PrivacyToast.showToast(viewController: self.viewController ?? UIViewController())
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
                if !(Validator.isValidPhone(phone: phone)) {
                    Util.setError(tfPhone, "authing_invalid_phone".L)
                    return
                }
                if phone == "" {
                    Util.setError(tfPhone, "authing_phone_none".L)
                } else if code == "" {
                    Util.setError(tfCode, "authing_verifycode_none".L)
                } else {
                    registerByPhoneCode(tfPhone.countryCode, phone, code)
                }
                return
            }
        }
        
        if let tfPhone: PhoneNumberTextField = Util.findView(self, viewClass: PhoneNumberTextField.self),
           let tfPassword: PasswordTextField = Util.findView(self, viewClass: PasswordTextField.self) {
            if let phone = tfPhone.text,
               let password = tfPassword.text {
                if !(Validator.isValidPhone(phone: phone)) {
                    Util.setError(tfPhone, "authing_invalid_phone".L)
                    return
                }
                if phone == "" {
                    Util.setError(tfPhone, "authing_phone_none".L)
                } else if password == "" {
                    Util.setError(tfPassword, "authing_password_none".L)
                } else {
                    registerByPhone(tfPhone.countryCode, phone, password)
                }
                return
            }
        }
        
        if let tfEmail: EmailTextField = Util.findView(self, viewClass: EmailTextField.self),
           let tfPassword: PasswordTextField = Util.findView(self, viewClass: PasswordTextField.self) {
            if let email = tfEmail.text,
               let password = tfPassword.text {
                if !(Validator.isValidEmail(email: email)) {
                    Util.setError(tfEmail, "authing_invalid_email".L)
                    return
                }
                if email == "" {
                    Util.setError(tfEmail, "authing_email_none".L)
                } else if password == "" {
                    Util.setError(tfPassword, "authing_password_none".L)
                } else {
                    registerByEmail(email, password)
                }
                return
            }
        }
        
        if let tfEmail: EmailTextField = Util.findView(self, viewClass: EmailTextField.self),
           let tfCode: VerifyCodeTextField = Util.findView(self, viewClass: VerifyCodeTextField.self) {
            if let email = tfEmail.text,
               let code = tfCode.text {
                if !(Validator.isValidEmail(email: email)) {
                    Util.setError(tfEmail, "authing_invalid_email".L)
                    return
                }
                if email == "" {
                    Util.setError(tfEmail, "authing_email_none".L)
                } else if code == "" {
                    Util.setError(tfCode, "authing_verifycode_none".L)
                } else {
                    registerByEmailCode(email, code)
                }
                return
            }
        }
        
        if let tfExtend: ExtendFieldTextField = Util.findView(self, viewClass: ExtendFieldTextField.self),
           let tfPassword: PasswordTextField = Util.findView(self, viewClass: PasswordTextField.self) {
            if let account = tfExtend.text,
               let password = tfPassword.text,
               let extend = tfExtend.extendField {

                if account == "" {
                    Util.setError(tfExtend, "authing_account_none".L)
                } else if password == "" {
                    Util.setError(tfPassword, "authing_password_none".L)
                } else {
                    registerByExtend(extend, account, password)
                }
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
    
    private func registerByPhone(_ countryCode: String? = nil, _ phone: String, _ password: String) {
        let authProtocol = authViewController?.authFlow?.authProtocol ?? .EInHouse
        if authProtocol == .EInHouse {
            Util.getAuthClient(self).registerByPhone(phoneCountryCode: countryCode, phone: phone, password: password) { code, message, userInfo in
                self.done(code: code, message: message, userInfo: userInfo)
            }
        } else {
            OIDCClient().registerByPhone(phoneCountryCode: countryCode, phone: phone, password: password) { code, message, userInfo in
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
    
    
    private func registerByExtend(_ extend: String, _ account: String, _ password: String) {
        startLoading()
        let authProtocol = authViewController?.authFlow?.authProtocol ?? .EInHouse
        if authProtocol == .EInHouse {
            Util.getAuthClient(self).registerByExtendedFields(extendedFields: extend, account: account, password: password) { code, message, userInfo in
                self.done(code: code, message: message, userInfo: userInfo)
            }
        } else {
            OIDCClient().registerByExtendedFields(extendedFields: extend, account: account, password: password) { code, message, userInfo in
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
                Util.getConfig(self) { config in
                    let missingFields: Array<NSDictionary> = AuthFlow.missingField(config: config, userInfo: userInfo)
                    if (config?.completeFieldsPlace != nil
                        && config!.completeFieldsPlace!.contains("register")
                        && missingFields.count > 0) {
                        let vc: AuthViewController? = AuthViewController(nibName: "AuthingUserInfoComplete", bundle: Bundle(for: Self.self))
                        vc?.hideNavigationBar = true
                        if let flow = self.authViewController?.authFlow {
                            vc?.authFlow = flow.copy() as? AuthFlow
                        }
                        vc?.authFlow?.data.setValue(missingFields, forKey: AuthFlow.KEY_EXTENDED_FIELDS)
                        self.authViewController?.navigationController?.pushViewController(vc!, animated: true)
                    } else {
                        if let flow = self.authViewController?.authFlow {
                            flow.complete(code, message, userInfo)
                        }
                    }
                }
            }
        }
    }
}
