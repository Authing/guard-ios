//
//  GetEmailCodeButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

open class GetEmailCodeButton: LoadingButton {
    
    public var scene: String = "RESET_PASSWORD"
    
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

    public func setup() {
        
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
        self.sendEmail()
    }
    
    fileprivate func sendEmail() {
        if let email = Util.getEmail(self) {
            startLoading()
            Util.getAuthClient(self).sendEmail(email: email, scene: self.scene) { code, message in
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
        } else {
            if let tf: EmailTextField = Util.findView(self, viewClass: EmailTextField.self) {
                if tf.text == "" {
                    Util.setError(tf, "authing_email_none".L)
                } else {
                    Util.setError(tf, "authing_invalid_email".L)
                }
            }
        }
    }
}

open class GetEmailVerifyCodeButton: GetEmailCodeButton {
    
    public override var scene: String{
        get { return "VERIFY_CODE" }
        set { super.scene = newValue }
    }
    
    public override func setup() {
        super.setup()
        DispatchQueue.main.async() {
            if self.authViewController?.nibName == "AuthingMFAEmail1" {
                self.startLoading()
                self.scene = "MFA_VERIFY"
                self.sendEmail()
            }
        }
    }

    
    override func sendEmail() {
        if let email = Util.getEmail(self) {
            startLoading()
            if self.authViewController?.authFlow?.mfaFromViewControllerName == "BindingMfaViewController" {
                self.sendVerifyEmail(email: email)
            } else {
                Util.getAuthClient(self).sendLoginEmail(email: email, scene: scene) { code, message in
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
        } else {
            if let tf: EmailTextField = Util.findView(self, viewClass: EmailTextField.self) {
                if tf.text == "" {
                    Util.setError(tf, "authing_email_none".L)
                } else {
                    Util.setError(tf, "authing_invalid_email".L)
                }
            }
        }
    }
    
    private func sendVerifyEmail(email: String) {
        
        let body: NSDictionary = ["factorType" : "EMAIL", "profile": ["email": email]]
        
        AuthClient().post("/api/v3/send-enroll-factor-request", body) { code, msg, res in
            self.stopLoading()
            if  let data = res?["data"] as? NSDictionary,
                let statusCode = res?["statusCode"] as? Int,
                statusCode == 200 {
                if let enrollmentToken = data["enrollmentToken"] as? String {
                    DispatchQueue.main.async() {
                        self.authViewController?.authFlow?.enrollmentToken = enrollmentToken
                        CountdownTimerManager.shared.createCountdownTimer(button: self)
                    }
                }
            }
            Toast.show(text: res?["message"] as? String ?? "")
        }
    }
    
    
}
