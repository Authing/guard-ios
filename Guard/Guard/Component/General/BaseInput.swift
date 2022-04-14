//
//  BaseInput.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/23.
//

import UIKit

open class BaseInput: UITextField, AttributedViewProtocol {
    
    open var textValue: String? = nil {
        didSet {
            text = textValue
        }
    }
    
    var hintColor: UIColor? = nil {
        didSet {
            if let hint = placeholder {
                attributedPlaceholder = NSAttributedString(string: hint, attributes: [NSAttributedString.Key.foregroundColor: hintColor as Any])
            }
        }
    }
    
    open var fontSize = 14.0 {
        didSet {
            if isBold {
                font = UIFont.boldSystemFont(ofSize: fontSize)
            } else {
                font = UIFont.systemFont(ofSize: fontSize)
            }
        }
    }
    
    open var isBold = false {
        didSet {
            if isBold {
                font = UIFont.boldSystemFont(ofSize: fontSize)
            } else {
                font = UIFont.systemFont(ofSize: fontSize)
            }
        }
    }
    
    open var textAlign = 0 {
        didSet {
            if 1 == textAlign {
                textAlignment = .center
            } else if 2 == textAlign {
                textAlignment = .right
            } else {
                textAlignment = .left
            }
        }
    }
    
    public func getTextAlignAsString() -> String? {
        if 1 == textAlign {
            return "center"
        } else if 2 == textAlign {
            return "right"
        }
        return nil
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        borderStyle = .roundedRect
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
        super.setAttribute(key: key, value: value)
        if ("hint-color" == key) {
            hintColor = Util.parseColor(value)
        } else if ("text" == key) {
            textValue = value
        } else if ("color" == key) {
            if let color = Util.parseColor(value) {
                textColor = color
            }
        } else if ("font-size" == key) {
            fontSize = CGFloat((value as NSString).floatValue)
        } else if ("font-weight" == key) {
            isBold = value == "bold"
        } else if ("text-align" == key) {
            if "left" == value {
                textAlign = 0
            } else if "center" == value {
                textAlign = 1
            } else if "right" == value {
                textAlign = 2
            }
        }
    }
}
