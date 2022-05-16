//
//  PhoneNumberTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

typealias PhoneNumberTextFieldTextChangeBlock = () -> Void

public class PhoneNumberTextField: AccountTextField {
    
    let countryCodeView = UIView()
    var countryCodeButton = UIButton()
    open var countryCode: String = "+86" {
        didSet {
            countryCodeButton.setTitle(countryCode, for: .normal)
            countryCodeButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: CGFloat(5 * countryCode.count))
        }
    }
    
    var textChangeCallBack: PhoneNumberTextFieldTextChangeBlock?

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
        let sInput: String = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
        let sPhone: String = NSLocalizedString("authing_phone", bundle: Bundle(for: Self.self), comment: "")
        self.setHint("\(sInput)\(sPhone)")
        
        countryCodeButton.setTitle(countryCode, for: .normal)
        countryCodeButton.setImage(UIImage.init(named: "authing_down", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        countryCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        countryCodeButton.setTitleColor(UIColor.black, for: .normal)
        countryCodeButton.addTarget(self, action: #selector(countryCodeButtonAction), for: .touchUpInside)
        countryCodeButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: CGFloat(5 * countryCode.count))
        countryCodeButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 60, bottom: 0, right: 0)
        
        countryCodeView.addSubview(countryCodeButton)
        
        self.leftView = countryCodeView
        self.leftViewMode = .never

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        Util.getConfig(self) { [self] config in
            
            countryCodeButton.frame = CGRect(x: 0,
                                                            y: 0,
                                                            width: config?.internationalSmsConfigEnable == true ? 80 : 0,
                                                            height: self.frame.height)
            countryCodeView.frame = countryCodeButton.frame
            self.leftViewMode = config?.internationalSmsConfigEnable == true ? .always : .never
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
