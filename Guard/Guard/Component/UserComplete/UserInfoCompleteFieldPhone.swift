//
//  UserInfoCompleteFieldPhone.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/22.
//

import UIKit

open class UserInfoCompleteFieldPhone: UserInfoCompleteFieldForm {
    
    var phoneTextField: PhoneNumberTextField = PhoneNumberTextField()
    var verifyCodeTextField: VerifyCodeTextField = VerifyCodeTextField()
    let getCodeButton: GetVerifyCodeButton = GetVerifyCodeButton()
    
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
        
        addSubview(phoneTextField)
        addSubview(verifyCodeTextField)
        addSubview(getCodeButton)
        
        phoneTextField.textField.borderStyle = .roundedRect
        phoneTextField.textField.font = UIFont.systemFont(ofSize: 14)
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        phoneTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        phoneTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        phoneTextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2).isActive = true
        
        verifyCodeTextField.borderStyle = .roundedRect
        verifyCodeTextField.font = UIFont.systemFont(ofSize: 14)
        verifyCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        verifyCodeTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        verifyCodeTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        verifyCodeTextField.trailingAnchor.constraint(equalTo: getCodeButton.leadingAnchor, constant: -8).isActive = true
        verifyCodeTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 12).isActive = true
        
        getCodeButton.backgroundColor = Const.Color_Button_Gray
        getCodeButton.loadingLocation = 1
        getCodeButton.loadingColor = Const.Color_Authing_Main
        getCodeButton.setTitleColor(Const.Color_Authing_Main, for: .normal)
        getCodeButton.titleLabel?.font = getCodeButton.titleLabel?.font.withSize(12)
        getCodeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        getCodeButton.translatesAutoresizingMaskIntoConstraints = false
        getCodeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        getCodeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        getCodeButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 12).isActive = true
        getCodeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    public override func getHeight() ->CGFloat {
        return 128
    }
    
    public func getPhone() -> String? {
        return phoneTextField.textField.text
    }
    
    public func getCountryCode() -> String? {
        return "\(phoneTextField.code)"
    }
    
    public func getCode() -> String? {
        return verifyCodeTextField.text
    }
    
    public override func setFormData(_ data: NSDictionary) {
        super.setFormData(data)
    }
}
