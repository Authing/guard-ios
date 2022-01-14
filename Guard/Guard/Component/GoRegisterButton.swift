//
//  GoRegisterButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class GoRegisterButton: GoSomewhereButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
        Authing.getConfig { config in
            if (config?.registerMethods == nil || config?.registerMethods?.count == 0) {
                self.isHidden = true
            }
        }
    }

    override func getText() -> String {
        return NSLocalizedString("authing_register_now", bundle: Bundle(for: Self.self), comment: "")
    }
    
    @objc private func onClick(sender: UIButton) {
        var nextVC: AuthViewController? = nil
        if let vc = viewController {
            if (vc.authFlow?.registerXibName == nil) {
                nextVC = AuthViewController(nibName: "AuthingRegister", bundle: Bundle(for: Self.self))
            } else {
                nextVC = AuthViewController(nibName: vc.authFlow?.registerXibName!, bundle: Bundle.main)
            }
            nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
        }
        self.viewController?.navigationController?.pushViewController(nextVC!, animated: true)
    }
}
