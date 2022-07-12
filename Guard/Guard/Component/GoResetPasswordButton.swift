//
//  GoResetPasswordButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

open class GoResetPasswordButton: GoSomewhereButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func getText() -> String {
        return "authing_forgot_password".L
    }
    
    override func goNow() {
        var nextVC: AuthViewController? = nil
        if let vc = authViewController {
            if (vc.authFlow?.forgotPasswordXibName == nil) {
                nextVC = ResetPasswordViewController(nibName: "AuthingResetPassword", bundle: Bundle(for: Self.self))
            } else {
                nextVC = ResetPasswordViewController(nibName: vc.authFlow?.forgotPasswordXibName!, bundle: Bundle.main)
            }
            nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
        }
        
        self.authViewController?.navigationController?.pushViewController(nextVC!, animated: true)
    }
}
