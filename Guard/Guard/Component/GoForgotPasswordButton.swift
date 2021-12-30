//
//  GoForgotPasswordButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

import UIKit

open class GoForgotPasswordButton: GoSomewhereButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func getText() -> String {
        return NSLocalizedString("authing_forgot_password", bundle: Bundle(for: Self.self), comment: "")
    }
    
    override func getNibName() -> String {
        return "AuthingForgotPassword"
    }
}
