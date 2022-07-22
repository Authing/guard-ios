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
                Util.setError(tf, "authing_email_none".L)
            }
        }
    }
}

open class GetEmailVerifyCodeButton: GetEmailCodeButton {
    
    public override var scene: String{
        get { return "VERIFY_CODE" }
        set { super.scene = newValue }
    }
    
    override func sendEmail() {
        if let email = Util.getEmail(self) {
            startLoading()
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
        } else {
            if let tf: EmailTextField = Util.findView(self, viewClass: EmailTextField.self) {
                Util.setError(tf, "authing_email_none".L)
            }
        }
    }
    
}
