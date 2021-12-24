//
//  LoginContainer.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

@IBDesignable open class LoginContainer: UIView {
    
    enum LoginType {
        case byPhoneCode
        case byPassword
    }
    
    @IBInspectable var type: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
    }
}
