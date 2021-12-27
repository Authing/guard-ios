//
//  VerifyCodeTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/27.
//

import UIKit

open class VerifyCodeTextField: TextFieldLayout {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.keyboardType = .numberPad
        let sInput: String = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
        let sVerifyCode: String = NSLocalizedString("authing_verify_code", bundle: Bundle(for: Self.self), comment: "")
        self.placeholder = "\(sInput)\(sVerifyCode)"
    }
}
