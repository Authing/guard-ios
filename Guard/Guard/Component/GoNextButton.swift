//
//  GoNextButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/4/19.
//

import UIKit

open class GoNextButton: GoSomewhereButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }

    override func getText() -> String {
        return NSLocalizedString("authing_next", bundle: Bundle(for: Self.self), comment: "")
    }
    
    override func onClick() {
        // save state
        if let authFlow = authViewController?.authFlow {
            if let tfPhone: PhoneNumberTextField = Util.findView(self, viewClass: PhoneNumberTextField.self) {
                if (!Validator.isValidPhone(phone: tfPhone.text)) {
                    let msg: String = NSLocalizedString("authing_invalid_phone", bundle: Bundle(for: Self.self), comment: "")
                    Util.setError(self, msg)
                    return
                }
            }
            
            if let tfEmail: EmailTextField = Util.findView(self, viewClass: EmailTextField.self) {
                if (!Validator.isValidEmail(email: tfEmail.text)) {
                    let msg: String = NSLocalizedString("authing_invalid_email", bundle: Bundle(for: Self.self), comment: "")
                    Util.setError(self, msg)
                    return
                }
            }
            
            if let account = Util.getAccount(self) {
               authFlow.data.setValue(account, forKey: AuthFlow.KEY_ACCOUNT)
            }
        }
        super.onClick()
    }
}
