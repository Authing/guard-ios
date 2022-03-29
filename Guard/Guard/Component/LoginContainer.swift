//
//  LoginContainer.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

@IBDesignable open class LoginContainer: Layout {

    // 0 by phone code; 1 by password; 2 by email code
    @IBInspectable open var type: Int = 0
    
    public override func setAttribute(key: String, value: String) {
        if ("type" == key) {
            type = Int(value) ?? 0
        }
    }
}
