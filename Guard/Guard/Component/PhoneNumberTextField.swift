//
//  PhoneNumberTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

typealias PhoneNumberTextFieldBeginEditingCallBack = () -> Void
typealias PhoneNumberTextFieldEndEditingCallBack = () -> Void

open class PhoneNumberTextField: UIView {
    
    let border = TextFieldBorder()

//    public var text: String?
    public var textField = PhoneNumberText()
    private var countryCodeButton = UIButton()
    
    open var countryCode: String = "+86" {
        didSet {
            self.countryCodeButton.setTitle(countryCode, for: .normal)
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
    
    private func setup() {
        
        self.addSubview(border)
        
        self.countryCodeButton = UIButton.init(type: .custom)
        self.countryCodeButton.setTitle(countryCode, for: .normal)
        self.countryCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.countryCodeButton.setTitleColor(UIColor.gray, for: .normal)
        self.countryCodeButton.isEnabled = false
        self.countryCodeButton.addTarget(self, action: #selector(countryCodeButtonAction), for: .touchUpInside)
        self.addSubview(self.countryCodeButton)
        
        self.addSubview(self.textField)

        self.textField.beginEditingCallBack = { [weak self] in
            self?.border.setHighlight(true)
        }
        
        self.textField.endEditingCallBack = { [weak self] in
            self?.border.setHighlight(false)
        }
        
        Util.getConfig(self) { [self] config in
            
            if config?.internationalSmsConfigEnable == true {
                self.countryCodeButton.setTitleColor(UIColor.black, for: .normal)
                self.countryCodeButton.isEnabled = true
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = CGRect(x: -2, y: -2, width: frame.width + 4, height: frame.height + 4)
        border.setNeedsDisplay()
        
        countryCodeButton.frame = CGRect(x: 0, y: 0, width: 80, height: self.frame.height)
        countryCodeButton.setNeedsDisplay()
        
        textField.frame = CGRect(x: self.countryCodeButton.frame.width,
                                      y: 0,
                                      width: self.frame.width - 80,
                                      height: self.frame.height)
        textField.setNeedsDisplay()
        
    }
    
    @objc func countryCodeButtonAction() {
        let countryCodeVC = CountryCodeViewController(nibName: "AuthingCountryCode", bundle: Bundle(for: CountryCodeViewController.self))
        countryCodeVC.selectCountryCallBack = { model in
            self.countryCode = "+\(model.code ?? 86)"
        }
        self.viewController?.navigationController?.pushViewController(countryCodeVC, animated: true)
    }
}

public class PhoneNumberText: AccountTextField {
    
    var beginEditingCallBack: PhoneNumberTextFieldBeginEditingCallBack?
    var endEditingCallBack: PhoneNumberTextFieldEndEditingCallBack?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.border.removeFromSuperview()
        
        self.keyboardType = .phonePad
        let sInput: String = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
        let sPhone: String = NSLocalizedString("authing_phone", bundle: Bundle(for: Self.self), comment: "")
        self.setHint("\(sInput)\(sPhone)")
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
    
    public override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.beginEditingCallBack?()
        return true
    }
    
    
    public override func textFieldDidEndEditing(_ textField: UITextField) {
        self.endEditingCallBack?()
    }
}
