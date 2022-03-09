//
//  MFAPhoneButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/10.
//

import UIKit

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
        let text = NSLocalizedString("authing_bind", bundle: Bundle(for: Self.self), comment: "")
        self.setTitle(text, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
        
        DispatchQueue.main.async() {
            if let phone = self.viewController?.authFlow?.data[AuthFlow.KEY_MFA_PHONE] as? String {
                self.startLoading()
                self.setTitle(NSLocalizedString("authing_login", bundle: Bundle(for: Self.self), comment: ""), for: .normal)
                AuthClient.sendSms(phone: phone) { code, message in
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
                AuthClient.mfaVerifyByPhone(phone: phone, code: code) { code, message, userInfo in
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
        AuthClient.mfaCheck(phone: phone, email: nil) { code, message, result in
            if (code == 200) {
                if (result != nil && result!) {
                    self.next(phone)
                } else {
                    self.stopLoading()
                    Util.setError(self, NSLocalizedString("authing_phone_number_already_bound", bundle: Bundle(for: Self.self), comment: ""))
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
            self.viewController?.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    private func done(_ code: Int, _ message: String?, _ userInfo: UserInfo?) {
        DispatchQueue.main.async() {
            self.stopLoading()
            if (code == 200) {
                if let vc = self.viewController?.navigationController as? AuthNavigationController {
                    vc.complete(code, message, userInfo)
                }
            } else {
                Util.setError(self, message)
            }
        }
    }
}
