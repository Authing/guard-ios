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
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }

    override func getText() -> String {
        return NSLocalizedString("authing_forgot_password", bundle: Bundle(for: Self.self), comment: "")
    }
    
    @objc private func onClick(sender: UIButton) {
        var nextVC: AuthViewController? = nil
        if let vc = viewController {
            if (vc.authFlow?.forgotPasswordXibName == nil) {
                nextVC = AuthViewController(nibName: "AuthingForgotPassword", bundle: Bundle(for: Self.self))
            } else {
                nextVC = AuthViewController(nibName: vc.authFlow?.forgotPasswordXibName!, bundle: Bundle.main)
            }
            nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
        }
        
        self.viewController?.navigationController?.pushViewController(nextVC!, animated: true)
    }
}
