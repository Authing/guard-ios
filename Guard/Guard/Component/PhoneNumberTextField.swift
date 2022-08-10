//
//  PhoneNumberTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

public class PhoneNumberTextField: AccountTextField {
    
    let countryCodeView = CountryCodeView()
        
    var countryCode: String {
        get {
            return countryCodeView.countryCode
        }
    }

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
        
        self.keyboardType = .phonePad
        
        if let image = UIImage(named: "authing_phone", in: Bundle(for: Self.self), compatibleWith: nil){
            self.updateIconImage(icon: image)
        }
        
        let sInput: String = "authing_please_input".L
        let sPhone: String = "authing_phone".L
        self.setHint("\(sInput)\(sPhone)")
        
        countryCodeView.countryCodeUpdateCallBack = { [weak self] _ in
            self?.countryCodeView.frame = CGRect(x: 0, y: 0, width: self?.countryCodeView.getWidth() ?? 0, height: self?.frame.size.height ?? 0)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        Util.getConfig(self) { [self] config in
            
            if config?.internationalSmsConfigEnable == true {
                countryCodeView.frame = CGRect(x: 0, y: 0, width: countryCodeView.getWidth(), height: self.frame.size.height)
                self.leftView = countryCodeView
            }
        }
    }
    
    
    @objc public override func textFieldDidChange(textField: UITextField) {
        if let text = textField.text {
            if (text.count) > 11 {
                self.text = String(text.prefix(11))
            }
        }
    }
    
        
    public override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        
        if textField.text?.isEmpty == true {
            Util.setError(self, "authing_phone_none".L)
        }
    }
    
    override func syncData() {
        let account: String? = AuthFlow.getAccount(current: self)
        if (account != nil && Validator.isValidPhone(phone: account)) {
            text = account
        }
    }
}
