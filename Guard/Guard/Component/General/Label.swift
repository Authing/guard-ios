//
//  Label.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/24.
//

import UIKit

open class Label: UILabel, AttributedViewProtocol {
    
    open var textValue: String? = nil {
        didSet {
            text = textValue
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
                textColor = color
            }
        } else if ("font-size" == key) {
            fontSize = CGFloat((value as NSString).floatValue)
        } else if ("font-weight" == key) {
            isBold = value == "bold"
        }
    }
}
