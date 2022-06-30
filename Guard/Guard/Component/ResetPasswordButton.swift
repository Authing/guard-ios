//
//  ResetPasswordButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

open class ResetPasswordButton: PrimaryButton {
    
    enum resetType {
        case byPhone
        case byEmail
    }
    
    open var phoneTarget: String? = nil
    open var emailTarget: String? = nil
    
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
        if let tfPassword: PasswordTextField = Util.findView(self, viewClass: PasswordTextField.self) {
            handleResetPassword(tfPassword.text)
            return
        }

        if let tfAccount: AccountTextField = Util.findView(self, viewClass: AccountTextField.self),
           let account = tfAccount.text {
            if (Validator.isValidPhone(phone: account)) {
                next(.byPhone, account)
            } else if (Validator.isValidEmail(email: account)) {
                next(.byEmail, account)
            }
        }
    }
    
    func handleResetPassword(_ password: String?) {
        let vc: AuthViewController? = authViewController
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
        Util.getAuthClient(self).resetPasswordByFirstTimeLoginToken(token: token!, password: password!) { code, message in
            DispatchQueue.main.async() {
                self.done(code, message)
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
        Util.getAuthClient(self).resetPasswordByPhone(phone: phone!, code: vCode!, newPassword: password!) { code, message in
            DispatchQueue.main.async() {
                self.done(code, message)
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
        Util.getAuthClient(self).resetPasswordByEmail(email: email!, code: vCode!, newPassword: password!) { code, message in
            DispatchQueue.main.async() {
                self.done(code, message)
            }
        }
    }
    
    func next(_ type: resetType, _ account: String) {
        if type == .byPhone {
            if let vc = viewController, vc.canPerformSegue(withIdentifier: "phone") {
                vc.performSegue(withIdentifier: "phone", sender: nil)
                return
            } else if let page = phoneTarget {
                Util.openPage(self, page)
                return
            }
        } else if type == .byEmail {
            if let vc = viewController, vc.canPerformSegue(withIdentifier: "email") {
                vc.performSegue(withIdentifier: "email", sender: nil)
                return
            } else if let page = emailTarget {
                Util.openPage(self, page)
                return
            }
        }
        
        var nextVC: AuthViewController? = nil
        if (type == .byPhone) {
            if let vc = authViewController {
                if (vc.authFlow?.resetPasswordByPhoneXibName == nil) {
                    nextVC = AuthViewController(nibName: "AuthingResetPasswordByPhone", bundle: Bundle(for: Self.self))
                } else {
                    nextVC = AuthViewController(nibName: vc.authFlow?.resetPasswordByPhoneXibName!, bundle: Bundle.main)
                }
                nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
            }
        } else if (type == .byEmail) {
            if let vc = authViewController {
                if (vc.authFlow?.resetPasswordByEmailXibName == nil) {
                    nextVC = AuthViewController(nibName: "AuthingResetPasswordByEmail", bundle: Bundle(for: Self.self))
                } else {
                    nextVC = AuthViewController(nibName: vc.authFlow?.resetPasswordByEmailXibName!, bundle: Bundle.main)
                }
                nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
            }
        }
        nextVC?.authFlow?.data.setValue(account, forKey: AuthFlow.KEY_ACCOUNT)
        self.authViewController?.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    private func done(_ code: Int, _ message: String?) {
        self.stopLoading()
        if code == 200 {
            if authCompletion != nil {
                ALog.i(Self.self, "Reset password success. Fire callback")
                authCompletion?(200, "", nil)
            } else {
                ALog.i(Self.self, "Reset password success. Now go to login")
                if let vc = self.authViewController?.navigationController?.viewControllers.first as? AuthViewController {
                    vc.authFlow = self.authViewController?.authFlow?.copy() as? AuthFlow
                }
                self.viewController?.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            Util.setError(self, message)
            authCompletion?(code, message, nil)
        }
    }
    
    public override func setAttribute(key: String, value: String) {
        super.setAttribute(key: key, value: value)
        if ("phoneTarget" == key) {
            phoneTarget = value
        } else if ("emailTarget" == key) {
            emailTarget = value
        }
    }
}
