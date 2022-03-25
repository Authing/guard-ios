//
//  TextFieldLayout.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

open class TextFieldLayout: BaseInput, UITextFieldDelegate {
    
    let border = TextFieldBorder()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        leftView = paddingView
        leftViewMode = .always
        clearButtonMode = .whileEditing
        font = UIFont.systemFont(ofSize: 14)
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
        autocapitalizationType = .none
        layer.borderColor = UIColor.clear.cgColor
        addSubview(border)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = CGRect(x: -2, y: -2, width: frame.width + 4, height: frame.height + 4)
        border.setNeedsDisplay()
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        border.setHighlight(true)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        border.setHighlight(false)
    }
}
