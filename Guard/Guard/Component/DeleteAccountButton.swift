//
//  DeleteAccountButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/4.
//

public typealias OnDeleteAccount = (Int, String?) -> Void

open class DeleteAccountButton: PrimaryButton {
    
    public var onDeleteAccount: OnDeleteAccount?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let loginText = "authing_delete_title".L
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
       
       startLoading()
       
        if let user = Authing.getCurrentUser() {
            
            if (user.phone == nil || user.phone == "") &&
                (user.password == nil || user.password == "")
            {
                deleteAccount()
            } else if user.phone == nil || user.phone == "" {
                checkPassword()
            } else {
                checkPhoneCode()
            }
        }
    }
    
    private func deleteAccount() {
        DispatchQueue.main.async() {
            Util.getAuthClient(self).deleteAccount { code, message in
               self.stopLoading()
               self.onDeleteAccount?(code, message)
            }
        }
    }
    
    private func checkPassword() {
        if let password: PasswordTextField = Util.findView(self, viewClass: PasswordTextField.self) {
            if let text = password.text,
               text != "" {
                Util.getAuthClient(self).checkPassword(password: text) { code, message in
                   if code == 200 {
                      self.deleteAccount()
                   } else {
                      self.stopLoading()
                      Util.setError(self, message)
                   }
                }
            } else {
               self.stopLoading()
                Util.setError(self, "authing_password_hint".L)
            }
        } else {
           self.stopLoading()
        }
    }
    
    private func checkPhoneCode() {
        if let tfCode: VerifyCodeTextField = Util.findView(self, viewClass: VerifyCodeTextField.self) {
           if let phone = Authing.getCurrentUser()?.phone,
              let code = tfCode.text {
              Util.getAuthClient(self).loginByPhoneCode(phone: phone, code: code) { code, message, user in
                 if code == 200 || code == Const.EC_MFA_REQUIRED {
                      self.deleteAccount()
                  } else {
                     self.stopLoading()
                  }
              }
           } else {
              self.stopLoading()
           }
        } else {
           self.stopLoading()
        }
    }
}
