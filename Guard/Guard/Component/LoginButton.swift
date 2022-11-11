//
//  LoginButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

open class LoginButton: PrimaryButton {
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
        Util.getConfig(self) { config in
            if config?.autoRegisterThenLoginHintInfo ?? false &&
                !(config?.registerDisabled == true ||
                  config?.registerMethods == nil ||
                  config?.registerMethods?.count == 0) {
                
                let registerText = "authing_register".L
                self.setTitle("\(loginText) / \(registerText)", for: .normal)
            } else {
                self.setTitle(loginText, for: .normal)
            }
        }
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        Util.setError(self, "")
        Util.getConfig(self) { config in
            self._onClick(config)
        }
    }
    
    private func _onClick(_ config: Config?) {
        if let privacyBox = Util.findView(self, viewClass: PrivacyConfirmBox.self) as? PrivacyConfirmBox{
            if (!privacyBox.isHidden) {
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
                            if (agreement["required"] as? Bool == true && !privacyBox.isChecked) {
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
        }
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
                        loginByPhoneCode(tfPhone.countryCode, phone, code, config?.autoRegisterThenLoginHintInfo ?? false)
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
                    loginByAccount(account, password, config?.autoRegisterThenLoginHintInfo ?? false)
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
                    loginByEmail(email, code, config?.autoRegisterThenLoginHintInfo ?? false)
                }
            }
        }
    }
    
    private func loginByPhoneCode(_ countryCode: String? = nil, _ phone: String, _ code: String, _ autoRegister: Bool) {
        startLoading()
                
        let authProtocol = authViewController?.authFlow?.authProtocol ?? .EInHouse
        if authProtocol == .EInHouse {
            Util.getAuthClient(self).loginByPhoneCode(phoneCountryCode: countryCode, phone: phone, code: code) { code, message, userInfo in
                self.stopLoading()
                LoginButton.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)
            }
        } else {
            OIDCClient().loginByPhoneCode(phoneCountryCode: countryCode, phone: phone, code: code) { code, message, userInfo in
                self.stopLoading()
                LoginButton.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)
            }
        }
    }
    
    private func loginByAccount(_ account: String, _ password: String, _ autoRegister: Bool) {
        startLoading()
        
        let authProtocol = authViewController?.authFlow?.authProtocol ?? .EInHouse
        if authProtocol == .EInHouse {
            Util.getAuthClient(self).loginByAccount(authData: nil, account: account, password: password, autoRegister) { code, message, userInfo in
                self.stopLoading()
                LoginButton.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)
            }
        } else {
            OIDCClient().loginByAccount(account: account, password: password, autoRegister) { code,  message,  userInfo in
                self.stopLoading()
                LoginButton.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)
            }
        }
    }
    
    private func loginByEmail(_ email: String, _ code: String, _ autoRegister: Bool) {
        Util.getAuthClient(self).loginByEmail(authData: nil, email: email, code: code, autoRegister) { code, message, userInfo in
            self.stopLoading()
            LoginButton.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)
        }
    }
    
    public class func handleLogin(button: Button, _ code: Int, message: String?, userInfo: UserInfo?, authCompletion: Authing.AuthCompletion? = nil) {
        DispatchQueue.main.async() {
            if (authCompletion != nil) {
                if (code != 200 && code != Const.EC_MFA_REQUIRED && code != Const.EC_FIRST_TIME_LOGIN) {
                    Util.setError(button, message)
                }
                authCompletion?(code, message, userInfo)
            } else if (code == 200) {
                Util.getConfig(button) { config in
                    let missingFields: Array<NSDictionary> = AuthFlow.missingField(config: config, userInfo: userInfo)
                    if (config?.completeFieldsPlace != nil
                        && config!.completeFieldsPlace!.contains("login")
                        && missingFields.count > 0) {
                        let vc: AuthViewController? = AuthViewController(nibName: "AuthingUserInfoComplete", bundle: Bundle(for: Self.self))
                        vc?.hideNavigationBar = true
                        if let flow = button.authViewController?.authFlow {
                            vc?.authFlow = flow.copy() as? AuthFlow
                        }
                        vc?.authFlow?.data.setValue(missingFields, forKey: AuthFlow.KEY_EXTENDED_FIELDS)
                        button.authViewController?.navigationController?.pushViewController(vc!, animated: true)
                    } else {
                        if let flow = button.authViewController?.authFlow {
                            flow.complete(code, message, userInfo)
                        }
                    }
                }
            } else if (code == Const.EC_MFA_REQUIRED) {
                let vc: AuthViewController? = AuthViewController(nibName: "AuthingMFAOptions", bundle: Bundle(for: Self.self))
                vc?.authFlow = button.authViewController?.authFlow?.copy() as? AuthFlow
                button.authViewController?.navigationController?.pushViewController(vc!, animated: true)
            } else if (code == Const.EC_FIRST_TIME_LOGIN) {
                // clear password text field
                if let tfPassword: PasswordTextField = Util.findView(button, viewClass: PasswordTextField.self) {
                    tfPassword.text = ""
                }
                
                var nextVC: AuthViewController? = nil
                if let vc = button.viewController as? AuthViewController {
                    if (vc.authFlow?.resetPasswordFirstTimeLoginXibName == nil) {
                        nextVC = AuthViewController(nibName: "AuthingFirstTimeLogin", bundle: Bundle(for: Self.self))
                    } else {
                        nextVC = AuthViewController(nibName: vc.authFlow?.resetPasswordFirstTimeLoginXibName!, bundle: Bundle.main)
                    }
                    vc.authFlow?.data.setValue(userInfo, forKey: AuthFlow.KEY_USER_INFO)
                    nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
                    nextVC?.title = "authing_first_time_login_title".L
                    vc.navigationController?.pushViewController(nextVC!, animated: true)
                }
            } else {
                Util.setError(button, message)
            }
        }
    }
}
