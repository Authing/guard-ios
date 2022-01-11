//
//  GetVerifyCodeButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/27.
//

import UIKit

open class GetVerifyCodeButton: LoadingButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        if (title(for: .normal) == nil) {
            let text: String = NSLocalizedString("authing_get_verify_code", bundle: Bundle(for: Self.self), comment: "")
            setTitle(text, for: .normal)
        }
        
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        if let phone = Util.getPhoneNumber(self) {
            startLoading()
            Util.setError(self, "")
            AuthClient.sendSms(phone: phone) { code, message in
                self.stopLoading()
                if (code != 200) {
                    Util.setError(self, message)
                } else {
                    print("send sms success")
                }
            }
        }
    }
}
