//
//  AccountTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import UIKit

open class AccountTextField: TextFieldLayout {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let sInput: String = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
        let sUsername: String = NSLocalizedString("authing_username", bundle: Bundle(for: Self.self), comment: "")
        let sEmail: String = NSLocalizedString("authing_email", bundle: Bundle(for: Self.self), comment: "")
        let sPhone: String = NSLocalizedString("authing_phone", bundle: Bundle(for: Self.self), comment: "")
        Authing.getConfig { config in
            self.placeholder = "\(sInput)\(sUsername) / \(sEmail) / \(sPhone)"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tf: PasswordTextField? = Util.findView(self, viewClass: PasswordTextField.self)
        if (tf != nil) {
            tf?.becomeFirstResponder()
        }
        return true
    }
}
