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
            let sInput: String = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
            let text: String = NSLocalizedString("authing_email", bundle: Bundle(for: Self.self), comment: "")
            self.setHint("\(sInput)\(text)")
        }
        
        if let image = UIImage(named: "authing_mail", in: Bundle(for: Self.self), compatibleWith: nil){
            self.updateIconImage(icon: image)
        }
    }
}
