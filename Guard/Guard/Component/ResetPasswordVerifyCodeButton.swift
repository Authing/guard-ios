//
//  ResetPasswordVerifyCodeButton.swift
//  Guard
//
//  Created by JnMars on 2022/7/11.
//

open class ResetPasswordVerifyCodeButton: GetVerifyCodeButton {
        
    enum ResetType {
        case byPhone
        case byEmail
    }

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

        if (title(for: .normal) == nil) {
            let text: String = "authing_get_verify_code".L
            setTitle(text, for: .normal)
        }
        
        self.addTarget(self, action:#selector(click(sender:)), for: .touchUpInside)
        
    }
    
    @objc private func click(sender: UIButton) {
        
        if let tf: ResetPasswordTextField = Util.findView(self, viewClass: ResetPasswordTextField.self),
           let account = tf.text {
            if (Validator.isValidPhone(phone: account)) {
                next(.byPhone, account)
            } else if (Validator.isValidEmail(email: account)) {
                next(.byEmail, account)
            }
        }
    }

    func next(_ type: ResetType, _ account: String) {
        if type == .byPhone {
            startLoading()
            Util.setError(self, "")

            Util.getAuthClient(self).sendSms(phone: account) { code, message in
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
        } else {
            startLoading()
            Util.getAuthClient(self).sendEmail(email: account, scene: "RESET_PASSWORD") { code, message in
                self.stopLoading()
                if (code != 200) {
                    Util.setError(self, message)
                } else {
                    ALog.i(Self.self, "send email success")
                    DispatchQueue.main.async() {
                        CountdownTimerManager.shared.createCountdownTimer(button: self)
                    }
                }
            }
        }
    }
}

