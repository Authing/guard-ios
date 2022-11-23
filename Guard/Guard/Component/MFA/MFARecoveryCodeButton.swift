//
//  MFARecoveryCodeButton.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//

import Foundation

open class MFARecoveryCodeButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let loginText = "authing_login".L
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        Util.setError(self, "")
        Util.getConfig(self) { config in
            self._onClick(config)
        }
    }
    
    private func _onClick(_ config: Config?) {
        if let codeTF = Util.findView(self, viewClass: MFARecoveryCodeTextField.self) as? MFARecoveryCodeTextField {
            AuthClient().mfaAssociteByRecoveryCode(code: codeTF.text ?? "") { code, msg, userInfo in
                self.done(code, msg, userInfo)
            }
        }
    }
    
    private func done(_ code: Int, _ message: String?, _ userInfo: UserInfo?) {
        DispatchQueue.main.async() {
            self.stopLoading()
            if (code == 200) {
                if let flow = self.authViewController?.authFlow {
                    flow.complete(code, message, userInfo)
                }
            } else {
                Util.setError(self, message)
            }
        }
    }
}
