//
//  MFAEmailButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/11.
//

import UIKit

open class MFAEmailButton: PrimaryButton {
    override init(frame: CGRect) {
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
            if let email = self.viewController?.authFlow?.data[AuthFlow.KEY_MFA_EMAIL] as? String {
                self.startLoading()
                self.setTitle(NSLocalizedString("authing_login", bundle: Bundle(for: Self.self), comment: ""), for: .normal)
                AuthClient.sendMFAEmail(email: email) { code, message in
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
            if let email = Util.getEmail(self) {
                startLoading()
                AuthClient.mfaVerifyByEmail(email: email, code: code) { code, message, userInfo in
                    self.done(code, message, userInfo)
                }
            }
        } else {
            if let tfEmail: EmailTextField = Util.findView(self, viewClass: EmailTextField.self) {
                checkEmail(tfEmail.text)
            }
        }
    }
    
    private func checkEmail(_ email: String?) {
        startLoading()
        AuthClient.mfaCheck(phone: nil, email: email) { code, message, result in
            self.stopLoading()
            if (code == 200) {
                if (result != nil && result!) {
                    self.next(email)
                } else {
                    Util.setError(self, NSLocalizedString("authing_email_already_bound", bundle: Bundle(for: Self.self), comment: ""))
                }
            } else {
                Util.setError(self, message)
            }
        }
    }
    
    private func next(_ email: String?) {
        DispatchQueue.main.async() {
            let vc: AuthViewController? = AuthViewController(nibName: "AuthingMFAEmail1", bundle: Bundle(for: Self.self))
            vc?.authFlow?.data.setValue(email, forKey: AuthFlow.KEY_MFA_EMAIL)
            self.viewController?.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    private func done(_ code: Int, _ message: String?, _ userInfo: UserInfo?) {
        DispatchQueue.main.async() {
            self.stopLoading()
            if (code == 200) {
                if let vc = self.viewController?.navigationController as? AuthNavigationController {
                    vc.complete(userInfo)
                }
            } else {
                Util.setError(self, message)
            }
        }
    }
}
