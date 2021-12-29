//
//  BasePasswordTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class BasePasswordTextField: TextFieldLayout {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.isSecureTextEntry = true
    }
}
