//
//  BasePasswordTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

open class BasePasswordTextField: TextFieldLayout {
    
    let eyeView = UIButton()
    let eyeImage = UIImage(named: "authing_eye", in: Bundle(for: BasePasswordTextField.self), compatibleWith: nil)
    let eyeOffImage = UIImage(named: "authing_eye_off", in: Bundle(for: BasePasswordTextField.self), compatibleWith: nil)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.isSecureTextEntry = true
        
        if let image = UIImage(named: "authing_password", in: Bundle(for: Self.self), compatibleWith: nil) {
            self.updateIconImage(icon: image)
        }
        
        let rightBackGroundView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        rightBackGroundView.addSubview(eyeView)
        eyeView.frame = CGRect(x: 12, y: 12, width: 24, height: 24)
        eyeView.setImage(eyeOffImage, for: .normal)
        rightView = rightBackGroundView
        rightViewMode = .always
        
        eyeView.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        isSecureTextEntry.toggle()
        
        if isSecureTextEntry {
            if let existingText = text {
                text = nil
                insertText(existingText)
            }
            eyeView.setImage(eyeOffImage, for: .normal)
        } else {
            eyeView.setImage(eyeImage, for: .normal)
        }
    }
}
