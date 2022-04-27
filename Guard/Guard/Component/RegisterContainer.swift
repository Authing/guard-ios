//
//  RegisterContainer.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class RegisterContainer: Layout {
    
    // 0 by phone; 1 by email
    @IBInspectable open var type: Int = 0

    public override func setAttribute(key: String, value: String) {
        if ("type" == key) {
            type = Int(value) ?? 0
        }
    }
}
