//
//  PasswordTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import UIKit

open class PasswordTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.isSecureTextEntry = true
        let sInput: String = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
        let sPassword: String = NSLocalizedString("authing_password", bundle: Bundle(for: Self.self), comment: "")
        Authing.getConfig { config in
            self.placeholder = "\(sInput)\(sPassword)"
        }
    }
}
