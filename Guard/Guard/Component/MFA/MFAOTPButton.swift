//
//  MFAOTPButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/11.
//

open class MFAOTPButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let text = NSLocalizedString("authing_login", bundle: Bundle(for: Self.self), comment: "")
        self.setTitle(text, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        if let code = Util.getVerifyCode(self) {
            startLoading()
            Util.getAuthClient(self).mfaVerifyByOTP(code: code) { code, message, userInfo in
                self.done(code, message, userInfo)
            }
        }
    }
    
    private func done(_ code: Int, _ message: String?, _ userInfo: UserInfo?) {
        DispatchQueue.main.async() {
            self.stopLoading()
            if (code == 200) {
                if let vc = self.authViewController?.navigationController as? AuthNavigationController {
                    vc.complete(code, message, userInfo)
                }
            } else {
                Util.setError(self, message)
            }
        }
    }
}
