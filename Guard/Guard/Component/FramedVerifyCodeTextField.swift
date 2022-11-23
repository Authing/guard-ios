//
//  FramedVerifyCodeTextField.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/11.
//

open class FramedVerifyCodeTextField: UIView, UITextFieldDelegate {
    
    // 0: default, 1: bindOTP, 2: verfiyOTP
    @IBInspectable var type: Int = 0
    @IBInspectable var boxWidth: CGFloat = 64
    @IBInspectable var boxHeight: CGFloat = 64
    @IBInspectable var boxSpacing: CGFloat = 23
    @IBInspectable var hyphen: Bool = true
    @IBInspectable var digit: Int = 0 {
        didSet {
            setup()
        }
    }
    
    var textFields: [TextFieldLayout]? = []
    var hyphenView: UIView? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Util.getConfig(self) { config in
            guard config != nil else {
                return
            }
            
            if (self.digit == 0) {
                self.digit = (config?.verifyCodeLength)!
            }
            
            self.textFields?.removeAll()
            for sub in self.subviews {
                sub.removeFromSuperview()
            }
            
            var i = 0
            while (i < self.digit) {
                let tf: TextFieldLayout = TextFieldLayout()
                tf.clearButtonMode = .never
                tf.keyboardType = .numberPad
                tf.textAlignment = .center
                tf.tintColor = UIColor.clear
                tf.font = UIFont.systemFont(ofSize: 18)
                tf.backgroundColor = UIColor(white: 0.95, alpha: 1)
                tf.delegate = self
                self.textFields?.append(tf)
                self.addSubview(tf)
                
                if (self.hyphen && i == self.digit / 2) {
                    self.hyphenView = UIView()
                    self.hyphenView?.backgroundColor = UIColor(white: 0.9, alpha: 1)
                    self.addSubview(self.hyphenView!)
                }
                i += 1
            }
        }
    }
    
    open override func layoutSubviews() {
        let hyphenWidth = CGFloat(12)
        let hyphenSpace = self.hyphenView != nil ? hyphenWidth + boxSpacing : 0
        let w = self.frame.width
        let h = self.frame.height
        var x = (w - hyphenSpace - boxWidth * CGFloat(Float(digit)) - boxSpacing * CGFloat((digit - 1))) / 2
        if x < 12 {
            boxWidth = w/CGFloat(textFields?.count ?? 0) - CGFloat(Float(digit)) - CGFloat(Float(digit * 2))
            x = (w - hyphenSpace - boxWidth * CGFloat(Float(digit)) - boxSpacing * CGFloat((digit - 1))) / 2
        }
        var i = 0
        for tf in textFields! {
            if (i < digit / 2) {
                tf.frame = CGRect(x: x + CGFloat(i) * (boxWidth + boxSpacing), y: 0, width: boxWidth, height: h)
            } else {
                tf.frame = CGRect(x: x + hyphenSpace + CGFloat(i) * (boxWidth + boxSpacing), y: 0, width: boxWidth, height: h)
            }
            i += 1
        }
        
        if (hyphenView != nil) {
            hyphenView?.frame = CGRect(x: (w - hyphenWidth) / 2, y: h/2, width: hyphenWidth, height: 1)
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let tf = textField as? TextFieldLayout {
            tf.border.setHighlight(true)
            tf.layer.borderColor = Const.Color_Authing_Main.cgColor
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if #available(iOS 13.0, *) {
            UIMenuController.shared.hideMenu()
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let tf = textField as? TextFieldLayout {
            tf.border.setHighlight(false)
            tf.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            DispatchQueue.main.async() {
                self.moveFocusToPrevious(textField)
            }
            return true
        }
        
        if (textField.text != string) {
            textField.text = String(string.prefix(1))
        }
        DispatchQueue.main.async() {
            self.moveFocusToNext(textField)
        }
        return false
    }
    
    private func moveFocusToNext(_ textField: UITextField) {
        var i = 0
        var next = 0
        for tf in textFields! {
            if (tf == textField) {
                next = i + 1
                if (next >= digit) {
                    next = digit - 1
                }
                break
            }
            i += 1
        }
        
        if let tf = textField as? TextFieldLayout {
            tf.resignFirstResponder()
        }
        
        textFields![next].becomeFirstResponder()
        
        // bind
        if next == 5 && i == 5 && type == 1 {
            if let verifyCode = Util.getVerifyCode(self) {
                
                // Authing Mobile v3
                if self.authViewController?.authFlow?.mfaFromViewControllerName == "BindingMfaViewController" {
                    self.mfaBindOTP(passCode: verifyCode)
                } else {
                // v2
                    Util.getAuthClient(self).mfaAssociateConfirmByOTP(code: verifyCode) { code, msg, data in
                        if code == 200 {
                            DispatchQueue.main.async() {
                                Util.getAuthClient(self).mfaVerifyByOTP(code: verifyCode) { code, msg, userInfo in
                                    self.done(code, msg, userInfo)
                                }
                            }
                        } else {
                            Toast.show(text: msg ?? "")
                        }
                    }
                }
            }
        }
        
        // verfify
        if next == 5 && i == 5 && type == 2 {
            if let verifyCode = Util.getVerifyCode(self) {
                Util.getAuthClient(self).mfaVerifyByOTP(code: verifyCode) { code, message, userInfo in
                    self.done(code, message, userInfo)
                }
            }
        }
    }
    
    private func moveFocusToPrevious(_ textField: UITextField) {
        var i = 0
        var next = 0
        for tf in textFields! {
            if (tf == textField) {
                next = i - 1
                if (next < 0) {
                    next = 0
                }
                break
            }
            i += 1
        }
        
        if let tf = textField as? TextFieldLayout {
            tf.resignFirstResponder()
        }
        
        textFields![next].becomeFirstResponder()
    }
    
    public func getText() -> String {
        var s: String = ""
        for tf in textFields! {
            s += tf.text ?? ""
        }
        return s
    }
    
    private func mfaBindOTP(passCode: String) {
        
        if let enrollmentToken = self.authViewController?.authFlow?.enrollmentToken {
            AuthClient().post("/api/v3/enroll-factor", ["factorType" : "OTP",
                                                 "enrollmentToken": enrollmentToken,
                                                        "enrollmentData": ["passCode": passCode]]) { code, msg, res in
                if let statusCode = res?["statusCode"] as? Int,
                    statusCode == 200 {
                    self.done(code, msg, Authing.getCurrentUser())
                } else {
                    Toast.show(text: res?["message"] as? String ?? "")
                }
            }
        }
    }
    private func done(_ code: Int, _ message: String?, _ userInfo: UserInfo?) {
        DispatchQueue.main.async() {
            if (code == 200) {
                if self.type == 1 {
                    var nextVC: AuthViewController? = nil
                    if let vc = self.authViewController {
                        nextVC = MFABindSuccessViewController(nibName: "AuthingMFABindSuccess", bundle: Bundle(for: Self.self))
                        nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
                    }
                    self.authViewController?.navigationController?.pushViewController(nextVC!, animated: true)
                } else {
                    if let flow = self.authViewController?.authFlow {
                        flow.complete(code, message, userInfo)
                    }
                }
            } else {
                Util.setError(self, message)
            }
        }
    }
    
}
