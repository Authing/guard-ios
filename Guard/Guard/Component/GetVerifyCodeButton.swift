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
        let text: String = NSLocalizedString("authing_get_verify_code", bundle: Bundle(for: Self.self), comment: "")
        setTitle(text, for: .normal)
        
        layer.cornerRadius = 4
        layer.borderWidth = 1/UIScreen.main.scale
        layer.borderColor = Const.Color_Authing_Main.cgColor
        
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {  
        let tf: PhoneNumberTextField? = Util.findView(self, viewClass: PhoneNumberTextField.self)
        if (tf != nil) {
            let phone: String? = tf!.text
            if (!phone!.isEmpty) {
                sendSms(phone!)
            }
        }
    }
    
    private func sendSms(_ phone: String) {
        startLoading()
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
