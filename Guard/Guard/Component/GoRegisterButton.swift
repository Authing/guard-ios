//
//  GoRegisterButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class GoRegisterButton: GoSomewhereButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Util.getConfig(self) { config in
            if (config?.registerMethods == nil || config?.registerMethods?.count == 0) {
                self.isHidden = true
            }
        }
    }

    override func getText() -> String {
        return NSLocalizedString("authing_register_now", bundle: Bundle(for: Self.self), comment: "")
    }
    
    override func goNow() {
        var nextVC: AuthViewController? = nil
        if let vc = authViewController {
            if (vc.authFlow?.registerXibName == nil) {
                nextVC = AuthViewController(nibName: "AuthingRegister", bundle: Bundle(for: Self.self))
            } else {
                nextVC = AuthViewController(nibName: vc.authFlow?.registerXibName!, bundle: Bundle.main)
            }
            nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
        }
        self.authViewController?.navigationController?.pushViewController(nextVC!, animated: true)
    }
}
