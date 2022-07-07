//
//  PasswordTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

open class PasswordTextField: BasePasswordTextField {
    
    @IBInspectable var checkStrength: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let sInput: String = "authing_please_input".L
        let sPassword: String = "authing_password".L
        setHint("\(sInput)\(sPassword)")
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc final private func textFieldDidChange(textField: UITextField) {
        Util.setError(self, "")
        
        guard checkStrength else {
            return
        }
        
        Util.getConfig(self) { config in
            let strength = config?.passwordStrength
            if (strength == 0) {
                return
            }
            
            var message: String? = nil
            let length = self.text?.count ?? 0
            if (length < 6) {
                if (strength == 2) {
                    message = "authing_password_strength2".L
                } else if (strength == 3) {
                    message = "authing_password_strength3".L
                } else {
                    message = "authing_password_strength1".L
                }
            } else if (strength == 2 || strength == 3) {
                var count = 0
                if (Validator.hasEnglish(self.text)) {
                    count += 1;
                }
                if (Validator.hasNumber(self.text)) {
                    count += 1;
                }
                if (Validator.hasSpecialCharacter(self.text)) {
                    count += 1;
                }
                if (strength == 2) {
                    if (count < 2) {
                        message = "authing_password_strength2".L
                    }
                } else {
                    if (count < 3) {
                        message = "authing_password_strength3".L
                    }
                }
            }
            
            Util.setError(self, message)
        }
        let tfPassword: PasswordTextField? = Util.findView(self, viewClass: PasswordTextField.self)
        if (text != nil && tfPassword?.text != nil && text != tfPassword?.text) {
            let message: String = "authing_password_do_not_match".L
            Util.setError(self, message)
        }
    }
}
