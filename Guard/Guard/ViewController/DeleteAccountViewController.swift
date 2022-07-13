//
//  DeleteAccountViewController.swift
//  Guard
//
//  Created by JnMars on 2022/7/13.
//

import Foundation

open class DeleteAccountViewController: AuthViewController {
    
    @IBOutlet var verifyLabel: UILabel!
    
    @IBOutlet var passwordTextField: PasswordTextField!
    
    @IBOutlet var verifyTextField: VerifyCodeTextField!
    
    @IBOutlet var verifyButton: GetVerifyCodeButton!
    
    @IBOutlet var deleteButton: DeleteAccountButton!
    
    public var onDeleteAccount: OnDeleteAccount?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI(userInfo: Authing.getCurrentUser())
    }
    
    func setupUI(userInfo: UserInfo?) {
        
        deleteButton.onDeleteAccount = { code, msg in
            self.onDeleteAccount?(code, msg)
        }
        
        if let user = userInfo{
            
            if (user.phone == nil || user.phone == "") &&
                (user.password == nil || user.password == "")
            {
                verifyLabel.text = "authing_delete_tip".L
                passwordTextField.isHidden = true
                verifyTextField.isHidden = true
                verifyButton.isHidden = true
            } else if user.phone == nil || user.phone == "" {
                verifyLabel.text = "authing_delete_password".L
                passwordTextField.isHidden = false
                verifyTextField.isHidden = true
                verifyButton.isHidden = true
            } else {
                verifyLabel.text = String(format: "authing_delete_phone".L, user.phone ?? "")
                passwordTextField.isHidden = true
                verifyTextField.isHidden = false
                verifyButton.isHidden = false
            } 
        }
    }
    
    @IBAction func verifyButtonAction(_ sender: Any) {
        if let phone = Authing.getCurrentUser()?.phone {
            
            AuthClient().sendSms(phone: phone) { code, message in
                if (code != 200) {
                    DispatchQueue.main.async() {
                        Util.setError(self.view, message)
                    }
                } else {
                    ALog.i(Self.self, "send sms success")
                    DispatchQueue.main.async() {
                        CountdownTimerManager.shared.createCountdownTimer(button: self.verifyButton)
                    }
                }
            }
        }
    }
    
}
