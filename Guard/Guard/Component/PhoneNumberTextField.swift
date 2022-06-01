//
//  PhoneNumberTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

typealias PhoneNumberTextFieldTextChangeBlock = () -> Void

public class PhoneNumberTextField: AccountTextField {
    
    let countryCodeView = CountryCodeView()
    
    var textChangeCallBack: PhoneNumberTextFieldTextChangeBlock?
    
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
        
        self.keyboardType = .phonePad
        
        if let image = UIImage(named: "authing_phone", in: Bundle(for: Self.self), compatibleWith: nil){
            self.updateIconImage(icon: image)
        }
        
        let sInput: String = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
        let sPhone: String = NSLocalizedString("authing_phone", bundle: Bundle(for: Self.self), comment: "")
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
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tfCode: VerifyCodeTextField? = Util.findView(self, viewClass: VerifyCodeTextField.self)
        if (tfCode != nil) {
            tfCode?.becomeFirstResponder()
        }
        return true
    }
    
    private func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.textChangeCallBack?()
        return true
    }
    
    override func syncData() {
        let account: String? = AuthFlow.getAccount(current: self)
        if (account != nil && Validator.isValidPhone(phone: account)) {
            text = account
        }
    }
    
}
