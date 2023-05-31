//
//  AccountTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

open class AccountTextField: TextFieldLayout {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        Util.getConfig(self) { config in
            if (config != nil) {
                self.setup(config!)
            }
        }
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc public func textFieldDidChange(textField: UITextField) {
        Util.setError(self, "")
    }
    
    private func setup(_ config: Config) {

        spellCheckingType = .no
        autocorrectionType = .no
        
        // hint can be set explicitly via Nib
        var methods = config.passwordValidLoginMethods
        if let socialBindingMethods = (authViewController?.authFlow?.data.value(forKey: AuthFlow.KEY_USER_INFO) as? UserInfo)?.socialBindingData?["methods"] as? [String] {
            methods = []
            for method in socialBindingMethods {
                if method.contains("password") {
                    methods.append(method)
                }
            }
        }
        
        if placeholder == nil {
            
            if let image = UIImage(named: "authing_user", in: Bundle(for: Self.self), compatibleWith: nil) {
                self.updateIconImage(icon: image)
            }

            var hint = "authing_please_input".L
            
            var i: Int = 0

            for method in config.passwordValidLoginMethods {
                hint += getMethodText(method, config)
                if (i < config.passwordValidLoginMethods.count - 1) {
                    hint += " / "
                }
                i += 1
            }
            
            setHint(hint)
        }
        
        if (methods.count == 1) {
            if (methods[0] == "email-password") {
                keyboardType = .emailAddress
            } else if (methods[0] == "phone-password") {
                keyboardType = .phonePad
            }
        }
        
        DispatchQueue.main.async() {
            self.syncData()
        }
    }
    
    private func getMethodText(_ method: String, _ config: Config) -> String {
        let sUsername: String = "authing_username".L
        let sEmail: String = "authing_email".L
        let sPhone: String = "authing_phone".L
        if (method == "username-password") {
            return sUsername
        } else if (method == "email-password") {
            return sEmail
        } else if (method == "phone-password") {
            return sPhone
        } else if method.contains("-password"){
            let item = method.replacingOccurrences(of: "-password", with: "")
            return Util.getExtendFieldTitle(config: config, field: item)
        }
        return ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tf: PasswordTextField? = Util.findView(self, viewClass: PasswordTextField.self)
        if (tf != nil) {
            tf?.becomeFirstResponder()
        }
        
        let tfCode: VerifyCodeTextField? = Util.findView(self, viewClass: VerifyCodeTextField.self)
        if (tfCode != nil) {
            tfCode?.becomeFirstResponder()
        }
        return true
    }
        
    private func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        CountdownTimerManager.shared.invalidate()
        return true
    }
    
    func syncData() {
        let account: String? = AuthFlow.getAccount(current: self)
        text = account
    }
}
