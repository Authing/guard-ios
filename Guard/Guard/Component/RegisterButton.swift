//
//  RegisterButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

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
        let text = NSLocalizedString("authing_register", bundle: Bundle(for: Self.self), comment: "")
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
                            let warning = NSLocalizedString("authing_agree_privacy_first", bundle: Bundle(for: LoginButton.self), comment: "")
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
            let phone: String? = tfPhone.textField.text
            let code: String? = tfCode.text
            if (!phone!.isEmpty && !code!.isEmpty) {
                if let international = config?.internationalSmsConfig{
                    if international  == true{
                        registerByPhoneCode("\(tfPhone.countryCode)", phone!, code!)
                        return
                    }
                }
                registerByPhoneCode(nil, phone!, code!)
                return
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
    
    private func registerByPhoneCode(_ countryCode: String? = nil, _ phone: String, _ code: String) {
        startLoading()
        Util.getAuthClient(self).registerByPhoneCode(phoneCountryCode: countryCode, phone: phone, code: code) { code, message, userInfo in
            self.done(code: code, message: message, userInfo: userInfo)
        }
    }
    
    private func registerByEmail(_ email: String, _ password: String) {
        startLoading()
        Util.getAuthClient(self).registerByEmail(email: email, password: password) { code, message, userInfo in
            self.done(code: code, message: message, userInfo: userInfo)
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
