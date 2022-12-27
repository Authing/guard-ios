//
//  EmailTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

open class EmailTextField: AccountTextField {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func setup() {
        super.setup()
        Util.getConfig(self) { config in
            self.keyboardType = .emailAddress
            if let image = UIImage(named: "authing_mail", in: Bundle(for: Self.self), compatibleWith: nil) {
                self.updateIconImage(icon: image)
            }
            let sInput: String = "authing_please_input".L
            let text: String = "authing_email".L
            self.setHint("\(sInput)\(text)")
        }
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            if !(text == "" || text.isEmpty) {
                if !(Validator.isValidEmail(email: text)) {
                    Util.setError(self, "authing_invalid_email".L)
                    return false
                }
            }
        }
        return true
    }
}
