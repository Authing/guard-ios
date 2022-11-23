//
//  MFAPhoneButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/10.
//

open class MFAPhoneButton: PrimaryButton {
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
            if let _ = self.authViewController?.authFlow?.data[AuthFlow.KEY_MFA_PHONE] as? String {
//                self.startLoading()
                self.setTitle("authing_login".L, for: .normal)
//                let phoneNumberTF: PhoneNumberTextField? = Util.findView(self, viewClass: PhoneNumberTextField.self)
//                Util.getAuthClient(self).sendSms(phone: phone, phoneCountryCode: phoneNumberTF?.countryCode) { code, message in
//                    self.stopLoading()
//                    if (code != 200) {
//                        Util.setError(self, message)
//                    }
//                }
            }
        }
    }
    
    @objc private func onClick(sender: UIButton) {
//        self.mfaBindPhone(phoneNumber: "15661050125", passCode: "8705")
//        self.mfaBindEmail(email: "872468553@qq.com", passCode: "7325")
//        return
        if let code = Util.getVerifyCode(self),
           let phone = Util.getPhoneNumber(self),
           code != "" {
            
            startLoading()

            if self.authViewController?.nibName == "AuthingMFAPhone0" {

                if self.authViewController?.authFlow?.mfaFromViewControllerName == "BindingMfaViewController" {
                    self.mfaBindPhone(passCode: code)
                } else {
                    checkPhone(phone, code)
                }

            } else {
                AuthClient().mfaVerifyByPhone(phone: phone, code: code) { code, message, userInfo in
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

    private func checkPhone(_ phone: String,_ verfiryCode: String) {
        startLoading()
        Util.getAuthClient(self).mfaCheck(phone: phone, email: nil) { code, message, result in
            if (code == 200) {
                if (result != nil && result!) {
                    AuthClient().mfaVerifyByPhone(phone: phone, code: verfiryCode) { code, message, userInfo in
                        self.done(code, message, userInfo)
                    }
                } else {
                    self.stopLoading()
                    Util.setError(self, "authing_phone_number_already_bound".L)
                }
            } else {
                self.stopLoading()
                Util.setError(self, message)
            }
        }
    }
    
    private func mfaBindPhone(passCode: String) {
        
        if let enrollmentToken = self.authViewController?.authFlow?.enrollmentToken {
            AuthClient().post("/api/v3/enroll-factor", ["factorType" : "SMS",
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
                    nextVC?.type = .phone
                    nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
                }
                self.authViewController?.navigationController?.pushViewController(nextVC!, animated: true)
//                if let flow = self.authViewController?.authFlow {
//                    flow.complete(code, message, userInfo)
//                }
            } else {
                Util.setError(self, message)
            }
        }
    }
}
