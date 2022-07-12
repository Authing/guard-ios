//
//  ResetPasswordButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

open class ResetPasswordButton: PrimaryButton {    

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
        let loginText = "authing_reset_password".L
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        if let tfPassword: PasswordTextField = Util.findView(self, viewClass: PasswordTextField.self) {
            handleResetPassword(tfPassword.text)
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
        
        if let tf: ResetPasswordTextField = Util.findView(self, viewClass: ResetPasswordTextField.self),
           let account = tf.text {
            if (Validator.isValidPhone(phone: account)) {
                resetPasswordByPhone(account, password)
            } else if (Validator.isValidEmail(email: account)) {
                resetPasswordByEmail(account, password)
            }
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

        let vCode: String? = Util.getVerifyCode(self)
        guard phone != nil && password != nil && vCode != nil else {
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

        let vCode: String? = Util.getVerifyCode(self)
        guard email != nil && password != nil && vCode != nil else {
            return
        }

        startLoading()
        Util.getAuthClient(self).resetPasswordByEmail(email: email!, code: vCode!, newPassword: password!) { code, message in
            DispatchQueue.main.async() {
                self.done(code, message)
            }
        }
    }
        
    private func done(_ code: Int, _ message: String?) {
        self.stopLoading()
        if code == 200 {
            if authCompletion != nil {
                ALog.i(Self.self, "Reset password success. Fire callback")
                authCompletion?(200, "", nil)
            } else {
                ALog.i(Self.self, "Reset password success. Now go to login")
                var nextVC: AuthViewController? = nil
                if let vc = authViewController {
                    nextVC = ResetSuccessViewController(nibName: "AuthingResetSuccess", bundle: Bundle(for: Self.self))
                    nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
                }
                self.authViewController?.navigationController?.pushViewController(nextVC!, animated: true)
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
