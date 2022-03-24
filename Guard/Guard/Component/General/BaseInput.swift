//
//  BaseInput.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/23.
//

import UIKit

open class BaseInput: UITextField, AttributedViewProtocol {
    
    var hintColor: UIColor? = nil {
        didSet {
            if let hint = placeholder {
                attributedPlaceholder = NSAttributedString(string: hint, attributes: [NSAttributedString.Key.foregroundColor: hintColor as Any])
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setHint(_ hint: String) {
        if let hc = hintColor {
            attributedPlaceholder = NSAttributedString(string: hint, attributes: [NSAttributedString.Key.foregroundColor: hc])
        } else {
            placeholder = hint
        }
    }
    
    public func setAttribute(key: String, value: String) {
        if ("hint-color" == key) {
            hintColor = Util.parseColor(value)
        }
    }
}
