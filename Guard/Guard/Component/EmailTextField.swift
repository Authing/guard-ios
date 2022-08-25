//
//  EmailTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

open class EmailTextField: AccountTextField {
    
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
        Util.getConfig(self) { config in
            self.keyboardType = .emailAddress
            if let image = UIImage(named: "authing_mail", in: Bundle(for: Self.self), compatibleWith: nil) {
                self.updateIconImage(icon: image)
            }
            let sInput: String = "authing_please_input".L
            let text: String = "authing_email".L
            self.setHint("\(sInput)\(text)")
        }
    }
}
