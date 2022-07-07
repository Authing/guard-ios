//
//  VerifyCodeTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/27.
//

open class VerifyCodeTextField: TextFieldLayout {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.keyboardType = .numberPad
        
        if let image = UIImage(named: "authing_check", in: Bundle(for: Self.self), compatibleWith: nil){
            self.updateIconImage(icon: image)
        }
        
        let sInput: String = "authing_please_input".L
        let sVerifyCode: String = "authing_verify_code".L
        setHint("\(sInput)\(sVerifyCode)")
    }
}
