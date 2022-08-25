//
//  UserInfoCompleteFieldPhone.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/22.
//

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
        
        phoneTextField.tintColor = Const.Color_Authing_Main
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneTextField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        phoneTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        phoneTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        phoneTextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
        
        verifyCodeTextField.tintColor = Const.Color_Authing_Main
        verifyCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        verifyCodeTextField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        verifyCodeTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        verifyCodeTextField.trailingAnchor.constraint(equalTo: getCodeButton.leadingAnchor, constant: -8).isActive = true
        verifyCodeTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 8).isActive = true
        
        getCodeButton.backgroundColor = Const.Color_BG_Text_Box
        getCodeButton.loadingLocation = 1
        getCodeButton.loadingColor = Const.Color_Authing_Main
        getCodeButton.setTitleColor(Const.Color_Authing_Main, for: .normal)
        getCodeButton.titleLabel?.font = getCodeButton.titleLabel?.font.withSize(16)
        getCodeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        getCodeButton.translatesAutoresizingMaskIntoConstraints = false
        getCodeButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        getCodeButton.widthAnchor.constraint(equalToConstant: 128).isActive = true
        getCodeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        getCodeButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 8).isActive = true
        getCodeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    public override func getHeight() ->CGFloat {
        return 128 + 16
    }
    
    public func getPhone() -> String? {
        return phoneTextField.text
    }
    
    public func getCountryCode() -> String? {
        return phoneTextField.countryCode
    }
    
    public func getCode() -> String? {
        return verifyCodeTextField.text
    }
    
    public override func setFormData(_ data: NSDictionary) {
        super.setFormData(data)
    }
}
