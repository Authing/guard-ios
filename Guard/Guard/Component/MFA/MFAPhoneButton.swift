//
//  MFAPhoneButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/10.
//

open class MFAPhoneButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let text = "authing_bind".L
        self.setTitle(text, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
        
        DispatchQueue.main.async() {
            if let phone = self.authViewController?.authFlow?.data[AuthFlow.KEY_MFA_PHONE] as? String {
                self.startLoading()
                self.setTitle("authing_login".L, for: .normal)
                let phoneNumberTF: PhoneNumberTextField? = Util.findView(self, viewClass: PhoneNumberTextField.self)
                Util.getAuthClient(self).sendSms(phone: phone, phoneCountryCode: phoneNumberTF?.countryCode) { code, message in
                    self.stopLoading()
                    if (code != 200) {
                        Util.setError(self, message)
                    }
                }
            }
        }
    }
    
    @objc private func onClick(sender: UIButton) {
        if let code = Util.getVerifyCode(self) {
            if let phone = Util.getPhoneNumber(self) {
                startLoading()
                Util.getAuthClient(self).mfaVerifyByPhone(phone: phone, code: code) { code, message, userInfo in
                    self.done(code, message, userInfo)
                }
            }
        } else {
            if let tfPhone: PhoneNumberTextField = Util.findView(self, viewClass: PhoneNumberTextField.self) {
                checkPhone(tfPhone.text)
            }
        }
    }
    
    private func checkPhone(_ phone: String?) {
        startLoading()
        Util.getAuthClient(self).mfaCheck(phone: phone, email: nil) { code, message, result in
            if (code == 200) {
                if (result != nil && result!) {
                    self.next(phone)
                } else {
                    self.stopLoading()
                    Util.setError(self, "authing_phone_number_already_bound".L)
                }
            } else {
                self.stopLoading()
                Util.setError(self, message)
            }
        }
    }
    
    private func next(_ phone: String?) {
        DispatchQueue.main.async() {
            let vc: AuthViewController? = AuthViewController(nibName: "AuthingMFAPhone1", bundle: Bundle(for: Self.self))
            vc?.authFlow?.data.setValue(phone, forKey: AuthFlow.KEY_MFA_PHONE)
            self.authViewController?.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    private func done(_ code: Int, _ message: String?, _ userInfo: UserInfo?) {
        DispatchQueue.main.async() {
            self.stopLoading()
            if (code == 200) {
                if let vc = self.authViewController?.navigationController as? AuthNavigationController {
                    vc.complete(code, message, userInfo)
                }
            } else {
                Util.setError(self, message)
            }
        }
    }
}
