//
//  ResetPasswordButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

import UIKit

open class ResetPasswordButton: PrimaryButton {
    
    enum resetType {
        case byPhone
        case byEmail
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let loginText = NSLocalizedString("authing_reset_password", bundle: Bundle(for: Self.self), comment: "")
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let vc: AuthViewController? = viewController
        if (vc == nil) {
            return
        }
        
        let tfPassword: PasswordTextField? = Util.findView(self, viewClass: PasswordTextField.self)
        if (tfPassword != nil) {
            handleResetPassword(tfPassword?.text)
            return
        }
        
        let tf: AccountTextField? = Util.findView(self, viewClass: AccountTextField.self)
        guard tf != nil else {
            return
        }
        
        let account: String? = tf!.text
        guard account != nil else {
            return
        }
        
        if (Validator.isValidPhone(phone: tf!.text)) {
            next(.byPhone, account!)
        } else if (Validator.isValidEmail(email: tf!.text)) {
            next(.byEmail, account!)
        }
    }
    
    func handleResetPassword(_ password: String?) {
        let vc: AuthViewController? = viewController
        let userInfo: UserInfo? = vc?.authFlow?.data.value(forKey: AuthFlow.KEY_USER_INFO) as? UserInfo
        if (userInfo != nil) {
            if let firstTimeToken: String = userInfo!.firstTimeLoginToken {
                resetPasswordFirstTimeLogin(firstTimeToken, password)
                return
            }
        }
        
        let tfPhone: PhoneNumberTextField? = Util.findView(self, viewClass: PhoneNumberTextField.self)
        if (tfPhone != nil) {
            resetPasswordByPhone(tfPhone?.text, password)
            return
        }
        
        let tfEmail: EmailTextField? = Util.findView(self, viewClass: EmailTextField.self)
        if (tfEmail != nil) {
            resetPasswordByEmail(tfEmail?.text, password)
        }
    }
    
    func resetPasswordFirstTimeLogin(_ token: String?, _ password: String?) {
        let tfPasswordConfirm: PasswordConfirmTextField? = Util.findView(self, viewClass: PasswordConfirmTextField.self)
        guard password != nil && tfPasswordConfirm != nil && tfPasswordConfirm?.text == password else {
            return
        }

        startLoading()
        AuthClient().resetPasswordByFirstTimeLoginToken(token: token!, password: password!) { code, message in
            DispatchQueue.main.async() {
                if (code == 200) {
                    self.gotoLogin()
                } else {
                    Util.setError(self, message)
                }
                self.stopLoading()
            }
        }
    }
    
    func resetPasswordByPhone(_ phone: String?, _ password: String?) {
        let tfPasswordConfirm: PasswordConfirmTextField? = Util.findView(self, viewClass: PasswordConfirmTextField.self)
        let vCode: String? = Util.getVerifyCode(self)
        guard phone != nil && password != nil && vCode != nil
                && tfPasswordConfirm != nil && tfPasswordConfirm?.text == password else {
            return
        }

        startLoading()
        AuthClient().resetPasswordByPhone(phone: phone!, code: vCode!, newPassword: password!) { code, message in
            DispatchQueue.main.async() {
                if (code == 200) {
                    self.gotoLogin()
                } else {
                    Util.setError(self, message)
                }
                self.stopLoading()
            }
        }
    }
    
    func resetPasswordByEmail(_ email: String?, _ password: String?) {
        let tfPasswordConfirm: PasswordConfirmTextField? = Util.findView(self, viewClass: PasswordConfirmTextField.self)
        let vCode: String? = Util.getVerifyCode(self)
        guard email != nil && password != nil && vCode != nil
                && tfPasswordConfirm != nil && tfPasswordConfirm?.text == password else {
            return
        }

        startLoading()
        AuthClient().resetPasswordByEmail(email: email!, code: vCode!, newPassword: password!) { code, message in
            DispatchQueue.main.async() {
                if (code == 200) {
                    self.gotoLogin()
                } else {
                    Util.setError(self, message)
                }
                self.stopLoading()
            }
        }
    }
    
    func next(_ type: resetType, _ account: String) {
        var nextVC: AuthViewController? = nil
        if (type == .byPhone) {
            if let vc = viewController {
                if (vc.authFlow?.resetPasswordByPhoneXibName == nil) {
                    nextVC = AuthViewController(nibName: "AuthingResetPasswordByPhone", bundle: Bundle(for: Self.self))
                } else {
                    nextVC = AuthViewController(nibName: vc.authFlow?.resetPasswordByPhoneXibName!, bundle: Bundle.main)
                }
                nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
            }
        } else if (type == .byEmail) {
            if let vc = viewController {
                if (vc.authFlow?.resetPasswordByEmailXibName == nil) {
                    nextVC = AuthViewController(nibName: "AuthingResetPasswordByEmail", bundle: Bundle(for: Self.self))
                } else {
                    nextVC = AuthViewController(nibName: vc.authFlow?.resetPasswordByEmailXibName!, bundle: Bundle.main)
                }
                nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
            }
        }
        nextVC?.authFlow?.data.setValue(account, forKey: AuthFlow.KEY_ACCOUNT)
        self.viewController?.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func gotoLogin() {
        if let vc = self.viewController?.navigationController?.viewControllers.first as? AuthViewController {
            vc.authFlow = self.viewController?.authFlow?.copy() as? AuthFlow
        }
        self.viewController?.navigationController?.popToRootViewController(animated: true)
    }
}
