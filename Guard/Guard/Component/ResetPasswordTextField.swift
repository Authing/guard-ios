//
//  ResetPasswordTextField.swift
//  Guard
//
//  Created by by JnMars on 2022/7/10.
//

open class ResetPasswordTextField: AccountTextField {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func setup() {
        super.setup()
        if let image = UIImage(named: "authing_user", in: Bundle(for: Self.self), compatibleWith: nil) {
            self.updateIconImage(icon: image)
        }

        let hint = "authing_input_phone_or_email".L
        setHint(hint)
    }
}
