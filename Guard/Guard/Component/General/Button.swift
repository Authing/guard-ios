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
    
    open var textAlign = 1 {
        didSet {
            if 0 == textAlign {
                contentHorizontalAlignment = .left
            } else if 1 == textAlign {
                contentHorizontalAlignment = .center
            } else {
                contentHorizontalAlignment = .right
            }
        }
    }
    
    public func getTextAlignAsString() -> String? {
        if 0 == textAlign {
            return "left"
        } else if 2 == textAlign {
            return "right"
        }
        return nil
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setAttribute(key: String, value: String) {
        super.setAttribute(key: key, value: value)
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
