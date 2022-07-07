//
//  PasswordConfirmTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

open class PasswordConfirmTextField: BasePasswordTextField {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let text: String = "authing_password_confirm_hint".L
        setHint("\(text)")
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc final private func textFieldDidChange(textField: UITextField) {
        Util.setError(self, "")
        
        let tfPassword: PasswordTextField? = Util.findView(self, viewClass: PasswordTextField.self)
        if (text != nil && tfPassword?.text != nil && text != tfPassword?.text) {
            let message: String = "authing_password_do_not_match".L
            Util.setError(self, message)
        }
    }
}
