//
//  PhoneNumberTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

typealias PhoneNumberTextFieldBeginEditingCallBack = () -> Void
typealias PhoneNumberTextFieldEndEditingCallBack = () -> Void

open class PhoneNumberTextField: TextFieldLayout {
    
    public var textField = PhoneNumberText()
    private var countryCodeButton = UIButton()
    
    open var countryCode: String = "+86" {
        didSet {
            self.countryCodeButton.setTitle(countryCode, for: .normal)
            self.countryCodeButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: CGFloat(5 * countryCode.count))
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
        
        self.countryCodeButton = UIButton.init(type: .custom)
        self.countryCodeButton.setTitle(countryCode, for: .normal)
        self.countryCodeButton.setImage(UIImage.init(named: "authing_down", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        self.countryCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.countryCodeButton.setTitleColor(UIColor.black, for: .normal)
        self.countryCodeButton.addTarget(self, action: #selector(countryCodeButtonAction), for: .touchUpInside)
        self.countryCodeButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: CGFloat(5 * countryCode.count))
        self.countryCodeButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 60, bottom: 0, right: 0)
        self.addSubview(self.countryCodeButton)
        
        self.addSubview(self.textField)

        
        self.textField.beginEditingCallBack = { [weak self] in
            self?.border.setHighlight(true)
        }

        self.textField.endEditingCallBack = { [weak self] in
            self?.border.setHighlight(false)
        }
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        Util.getConfig(self) { [self] config in
            
            //根据 internationalSmsConfigEnable 判断 true 显示, false 隐藏
            countryCodeButton.isHidden = !(config?.internationalSmsConfigEnable ?? false)
            countryCodeButton.frame = CGRect(x: 0,
                                                                y: 0,
                                                                width: config?.internationalSmsConfigEnable == true ? 80 : 0,
                                                                height: self.frame.height)
            countryCodeButton.setNeedsDisplay()
            
            textField.frame = CGRect(x: self.countryCodeButton.frame.width,
                                          y: 0,
                                          width: self.frame.width - self.countryCodeButton.frame.width,
                                          height: self.frame.height)
            textField.setNeedsDisplay()
        }
    }
    
    @objc func countryCodeButtonAction() {
        let countryCodeVC = CountryCodeViewController(nibName: "AuthingCountryCode", bundle: Bundle(for: CountryCodeViewController.self))
        countryCodeVC.modalPresentationStyle = .fullScreen
        countryCodeVC.selectCountryCallBack = { model in
            self.countryCode = "+\(model.code ?? 86)"
        }
        self.viewController?.present(countryCodeVC, animated: true)
    }
    
    public override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    
    public override func textFieldDidEndEditing(_ textField: UITextField) {
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

    override func setup() {
        self.backgroundColor = UIColor.clear
        self.borderStyle = .none
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
