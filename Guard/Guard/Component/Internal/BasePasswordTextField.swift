//
//  BasePasswordTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

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
        
        if let image = UIImage(named: "authing_password", in: Bundle(for: Self.self), compatibleWith: nil){
            self.updateIconImage(icon: image)
        }
        
        eyeView.setBackgroundImage(eyeImage, for: .normal)
        rightView = eyeView
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
            eyeView.setBackgroundImage(eyeImage, for: .normal)
        } else {
            eyeView.setBackgroundImage(eyeOffImage, for: .normal)
        }
    }
}
