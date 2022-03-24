//
//  Button.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/24.
//

import UIKit

open class Button: UIButton, AttributedViewProtocol {
    open var textValue: String? = nil {
        didSet {
            titleLabel?.text = textValue
            setTitle(textValue, for: .normal)
        }
    }
    
    open var fontSize = 18.0 {
        didSet {
            if isBold {
                titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
            } else {
                titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            }
        }
    }
    
    open var isBold = false {
        didSet {
            if isBold {
                titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
            } else {
                titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setAttribute(key: String, value: String) {
        if ("text" == key) {
            textValue = value
        } else if ("color" == key) {
            if let color = Util.parseColor(value) {
                titleLabel?.textColor = color
                setTitleColor(color, for: .normal)
                setTitleColor(color, for: .disabled)
            }
        } else if ("font-size" == key) {
            fontSize = CGFloat((value as NSString).floatValue)
        } else if ("font-weight" == key) {
            isBold = value == "bold"
        }
    }
}
