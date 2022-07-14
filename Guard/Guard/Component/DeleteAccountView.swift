//
//  DeleteAccountView.swift
//  Guard
//
//  Created by JnMars on 2022/7/14.
//

import Foundation

open class DeleteAccountView: UIView {
    
    public var deleteButton: DeleteAccountButton?
    public var passwordTextField: PasswordTextField?
    public var verifyTextField: VerifyCodeTextField?
    public var verifyLabel: Label?
    public var verifyButton: GetVerifyCodeButton?
    public var onDeleteAccount: OnDeleteAccount?
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI(userInfo: Authing.getCurrentUser())
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI(userInfo: Authing.getCurrentUser())
    }
    
    func setupUI(userInfo: UserInfo?) {
        
        let deleteButton = Util.findView(self, viewClass: DeleteAccountButton.self) as? DeleteAccountButton
        let passwordTextField = Util.findView(self, viewClass: PasswordTextField.self) as? PasswordTextField
        let verifyTextField = Util.findView(self, viewClass: VerifyCodeTextField.self) as? VerifyCodeTextField
        let verifyLabel = Util.findView(self, viewClass: Label.self) as? Label
        let verifyButton = Util.findView(self, viewClass: GetVerifyCodeButton.self) as? GetVerifyCodeButton
        
        verifyButton?.addTarget(self, action: #selector(verifyButtonAction), for: .touchUpInside)

        deleteButton?.onDeleteAccount = { code, msg in
            self.onDeleteAccount?(code, msg)
        }
        
        if let user = userInfo{
            
            if (user.phone == nil || user.phone == "") &&
                (user.password == nil || user.password == "")
            {
                verifyLabel?.text = "authing_delete_tip".L
                passwordTextField?.isHidden = true
                verifyTextField?.isHidden = true
                verifyButton?.isHidden = true
            } else if user.phone == nil || user.phone == "" {
                verifyLabel?.text = "authing_delete_password".L
                passwordTextField?.isHidden = false
                verifyTextField?.isHidden = true
                verifyButton?.isHidden = true
            } else {
                verifyLabel?.text = String(format: "authing_delete_phone".L, user.phone ?? "")
                passwordTextField?.isHidden = true
                verifyTextField?.isHidden = false
                verifyButton?.isHidden = false
            }
        }
    }
        
    @objc func verifyButtonAction(_ sender: Any) {
        if let phone = Authing.getCurrentUser()?.phone {
            
            AuthClient().sendSms(phone: phone) { code, message in
                if (code != 200) {
                    DispatchQueue.main.async() {
                        Util.setError(self, message)
                    }
                } else {
                    ALog.i(Self.self, "send sms success")
                    DispatchQueue.main.async() {
                        CountdownTimerManager.shared.createCountdownTimer(button: self.verifyButton ?? GetVerifyCodeButton())
                    }
                }
            }
        }
    }
    
}
