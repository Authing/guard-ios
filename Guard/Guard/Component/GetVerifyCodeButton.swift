//
//  GetVerifyCodeButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/27.
//

open class GetVerifyCodeButton: LoadingButton {
    
    override open var loadingColor: UIColor? {
        get {
            return Const.Color_Authing_Main
        }
        set {}
    }
    
    override open var loadingLocation: Int {
        get {
            return 1
        }
        set {}
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(Const.Color_Authing_Main, for: .normal)
        fontSize = 14
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        
        backgroundColor = Const.Color_BG_Text_Box
        layer.cornerRadius = 4
        clipsToBounds = true
        
        if (title(for: .normal) == nil) {
            let text: String = "authing_get_verify_code".L
            setTitle(text, for: .normal)
        }
        
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        if let phone = Util.getPhoneNumber(self) {
            startLoading()
            Util.setError(self, "")
          
            if let phoneNumberTF: PhoneNumberTextField = Util.findView(self, viewClass: PhoneNumberTextField.self) {
                Util.getAuthClient(self).sendSms(phone: phone, phoneCountryCode: phoneNumberTF.countryCode) { code, message in
                    self.stopLoading()
                    if (code != 200) {
                        Util.setError(self, message)
                    } else {
                        ALog.i(Self.self, "send sms success")
                        DispatchQueue.main.async() {
                            CountdownTimerManager.shared.createCountdownTimer(button: self)
                        }
                    }
                }
            }
        } else {
            if let phoneNumberTF: PhoneNumberTextField = Util.findView(self, viewClass: PhoneNumberTextField.self) {
                if phoneNumberTF.text == "" {
                    Util.setError(phoneNumberTF, "authing_phone_none".L)
                } else {
                    Util.setError(phoneNumberTF, "authing_invalid_phone".L)
                }
            }
        }
    }
}

