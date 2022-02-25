//
//  TextFieldLayout.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

open class TextFieldLayout: UITextField, UITextFieldDelegate {
    
    var border: TextFieldBorder? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.delegate = self
        layer.borderWidth = 0
        clipsToBounds = false
        layer.borderColor = UIColor.clear.cgColor
        border = TextFieldBorder()
        addSubview(border!)
        border?.translatesAutoresizingMaskIntoConstraints = false
        border?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -2).isActive = true
        border?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 2).isActive = true
        border?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 2).isActive = true
        border?.topAnchor.constraint(equalTo: self.topAnchor, constant: -2).isActive = true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        border?.setHighlight(true)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        border?.setHighlight(false)
    }
}
