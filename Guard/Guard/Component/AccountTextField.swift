//
//  AccountTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import UIKit

open class AccountTextField: TextFieldLayout {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Authing.getConfig { config in
            if (config != nil) {
                self.setup(config!)
            }
        }
    }
    
    private func setup(_ config: Config) {
        spellCheckingType = .no
        autocorrectionType = .no
        
        self.placeholder = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
        
        var i: Int = 0
        if (config.enabledLoginMethods != nil) {
            for method in config.enabledLoginMethods! {
                self.placeholder! += getMethodText(method)
                if (i < config.enabledLoginMethods!.count - 1) {
                    self.placeholder! += " / "
                }
                i += 1
            }
        }
        
        if (config.enabledLoginMethods?.count == 1) {
            if (config.enabledLoginMethods?[0] == "email-password") {
                keyboardType = .emailAddress
            } else if (config.enabledLoginMethods?[0] == "phone-password") {
                keyboardType = .phonePad
            }
        }
        
        DispatchQueue.main.async() {
            self.syncData()
        }
    }
    
    private func getMethodText(_ method: String) -> String {
        let sUsername: String = NSLocalizedString("authing_username", bundle: Bundle(for: Self.self), comment: "")
        let sEmail: String = NSLocalizedString("authing_email", bundle: Bundle(for: Self.self), comment: "")
        let sPhone: String = NSLocalizedString("authing_phone", bundle: Bundle(for: Self.self), comment: "")
        if (method == "username-password") {
            return sUsername
        } else if (method == "email-password") {
            return sEmail
        } else if (method == "phone-password") {
            return sPhone
        }
        return ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tf: PasswordTextField? = Util.findView(self, viewClass: PasswordTextField.self)
        if (tf != nil) {
            tf?.becomeFirstResponder()
        }
        return true
    }
    
    func syncData() {
        let account: String? = AuthFlow.getAccount(current: self)
        text = account
    }
}
