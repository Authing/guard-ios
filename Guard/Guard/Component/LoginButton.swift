//
//  LoginButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import UIKit

open class LoginButton: PrimaryButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let loginText = NSLocalizedString("authing_login", bundle: Bundle(for: Self.self), comment: "")
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let vc: AuthViewController? = viewController
        if (vc == nil) {
            return
        }
        
        let tfPhone: PhoneNumberTextField? = Util.findView(self, viewClass: PhoneNumberTextField.self)
        let tfCode: VerifyCodeTextField? = Util.findView(self, viewClass: VerifyCodeTextField.self)
        if (tfPhone != nil && tfCode != nil) {
            let phone: String? = tfPhone!.text
            let code: String? = tfCode!.text
            if (!phone!.isEmpty && !code!.isEmpty) {
                loginByPhoneCode(phone!, code!)
            }
            return
        }
        
        let tfAccount: AccountTextField? = Util.findView(self, viewClass: AccountTextField.self)
        let tfPassword: PasswordTextField? = Util.findView(self, viewClass: PasswordTextField.self)
        if (tfAccount != nil && tfPassword != nil) {
            let account: String? = tfAccount!.text
            let password: String? = tfPassword!.text
            if (!account!.isEmpty && !password!.isEmpty) {
                loginByAccount(account!, password!)
            }
        }
    }
    
    private func loginByPhoneCode(_ phone: String, _ code: String) {
        startLoading()
        AuthClient.loginByPhoneCode(phone: phone, code: code) { code, message, userInfo in
            self.stopLoading()
            DispatchQueue.main.async() {
                self.handleLogin(code, message: message, userInfo: userInfo)
            }
        }
    }
    
    private func loginByAccount(_ account: String, _ password: String) {
        startLoading()
        AuthClient.loginByAccount(account: account, password: password) { code, message, userInfo in
            self.stopLoading()
            DispatchQueue.main.async() {
                self.handleLogin(code, message: message, userInfo: userInfo)
            }
        }
    }
    
    private func handleLogin(_ code: Int, message: String?, userInfo: UserInfo?) {
        if (code == 200) {
            Authing.getConfig { config in
                let missingFields: Array<NSDictionary> = AuthFlow.missingField(config: config, userInfo: userInfo)
                if (config?.completeFieldsPlace != nil
                    && config!.completeFieldsPlace!.contains("login")
                    && missingFields.count > 0) {
                    let vc: AuthViewController? = AuthViewController(nibName: "AuthingUserInfoComplete", bundle: Bundle(for: Self.self))
                    vc?.authFlow?.data.setValue(missingFields, forKey: AuthFlow.KEY_EXTENDED_FIELDS)
                    self.viewController?.navigationController?.pushViewController(vc!, animated: true)
                } else {
                    if let vc = self.viewController?.navigationController as? AuthNavigationController {
                        vc.complete(userInfo)
                    }
                }
            }
        } else if (code == Const.EC_MFA_REQUIRED) {
            let vc: AuthViewController? = AuthViewController(nibName: "AuthingMFAOptions", bundle: Bundle(for: Self.self))
            self.viewController?.navigationController?.pushViewController(vc!, animated: true)
        } else if (code == Const.EC_FIRST_TIME_LOGIN) {
            // clear password text field
            if let tfPassword: PasswordTextField = Util.findView(self, viewClass: PasswordTextField.self) {
                tfPassword.text = ""
            }
            
            var nextVC: AuthViewController? = nil
            if let vc = viewController {
                if (vc.authFlow?.resetPasswordFirstTimeLoginXibName == nil) {
                    nextVC = AuthViewController(nibName: "AuthingFirstTimeLogin", bundle: Bundle(for: Self.self))
                } else {
                    nextVC = AuthViewController(nibName: vc.authFlow?.resetPasswordFirstTimeLoginXibName!, bundle: Bundle.main)
                }
                vc.authFlow?.data.setValue(userInfo, forKey: AuthFlow.KEY_USER_INFO)
                nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
            }
            self.viewController?.navigationController?.pushViewController(nextVC!, animated: true)
        } else {
            Util.setError(self, message)
        }
    }
}
