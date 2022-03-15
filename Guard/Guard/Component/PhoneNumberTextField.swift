//
//  PhoneNumberTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

open class PhoneNumberTextField: AccountTextField {
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
            self.keyboardType = .phonePad
            let sInput: String = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
            let sPhone: String = NSLocalizedString("authing_phone", bundle: Bundle(for: Self.self), comment: "")
            self.placeholder = "\(sInput)\(sPhone)"
        }
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tfCode: VerifyCodeTextField? = Util.findView(self, viewClass: VerifyCodeTextField.self)
        if (tfCode != nil) {
            tfCode?.becomeFirstResponder()
        }
        return true
    }
    
    override func syncData() {
        let account: String? = AuthFlow.getAccount(current: self)
        if (account != nil && Validator.isValidPhone(phone: account)) {
            text = account
        }
    }
}
