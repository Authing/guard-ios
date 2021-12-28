//
//  TextFieldLayout.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

open class TextFieldLayout: UITextField, UITextFieldDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.delegate = self
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        layer.borderColor = Const.Color_Authing_Main.cgColor
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
    }
}
