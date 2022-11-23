//
//  MFAEmailButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/11.
//

open class MFAEmailButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let text = "authing_bind".L
        self.setTitle(text, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
        
        DispatchQueue.main.async() {
            if let _ = self.authViewController?.authFlow?.data[AuthFlow.KEY_MFA_EMAIL] as? String {
//                self.startLoading()
                self.setTitle("authing_login".L, for: .normal)
//                Util.getAuthClient(self).sendMFAEmail(email: email) { code, message in
//                    self.stopLoading()
//                    if (code != 200) {
//                        Util.setError(self, message)
//                    }
//                }
            }
        }
    }
    
    @objc private func onClick(sender: UIButton) {
        if let code = Util.getVerifyCode(self) {
            if let email = Util.getEmail(self) {

                startLoading()
                
                if self.authViewController?.nibName == "AuthingMFAEmail0" {
                    if self.authViewController?.authFlow?.mfaFromViewControllerName == "BindingMfaViewController" {
                        self.mfaBindEmail(passCode: code)
                    } else {
                        checkEmail(email, code)
                    }
                } else {
                    AuthClient().mfaVerifyByEmail(email: email, code: code) { code, message, userInfo in
                        DispatchQueue.main.async() {
                            self.stopLoading()
                            if (code == 200) {
                                if let flow = self.authViewController?.authFlow {
                                    flow.complete(code, message, userInfo)
                                } else {
                                    Util.setError(self, message)
                                }
                            } else {
                                Util.setError(self, message)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func checkEmail(_ email: String, _ verifyCode: String) {
        startLoading()
        Util.getAuthClient(self).mfaCheck(phone: nil, email: email) { code, message, result in
            self.stopLoading()
            if (code == 200) {
                if (result != nil && result!) {
                    AuthClient().mfaVerifyByEmail(email: email, code: verifyCode) { code, message, userInfo in
                        self.done(code, message, userInfo)
                    }
                } else {
                    Util.setError(self, "authing_email_already_bound".L)
                }
            } else {
                Util.setError(self, message)
            }
        }
    }
    
    
    private func next(_ email: String?) {
        DispatchQueue.main.async() {
            let vc: AuthViewController? = AuthViewController(nibName: "AuthingMFAEmail1", bundle: Bundle(for: Self.self))
            vc?.authFlow?.data.setValue(email, forKey: AuthFlow.KEY_MFA_EMAIL)
            self.authViewController?.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    private func mfaBindEmail(passCode: String) {
        
        if let enrollmentToken = self.authViewController?.authFlow?.enrollmentToken {
            AuthClient().post("/api/v3/enroll-factor", ["factorType" : "EMAIL",
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
            self.stopLoading()
            if (code == 200) {
                var nextVC: MFABindSuccessViewController? = nil
                if let vc = self.authViewController {
                    nextVC = MFABindSuccessViewController(nibName: "AuthingMFABindSuccess", bundle: Bundle(for: Self.self))
                    nextVC?.type = .email
                    nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
                }
                self.authViewController?.navigationController?.pushViewController(nextVC!, animated: true)

            } else {
                Util.setError(self, message)
            }
        }
    }
}
