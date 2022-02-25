//
//  FramedVerifyCodeTextField.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/11.
//

import UIKit

open class FramedVerifyCodeTextField: UIView, UITextFieldDelegate {
    
    @IBInspectable var boxWidth: CGFloat = 44
    @IBInspectable var boxHeight: CGFloat = 52
    @IBInspectable var boxSpacing: CGFloat = 12
    @IBInspectable var hyphen: Bool = true
    @IBInspectable var digit: Int = 0 {
        didSet {
            setup()
        }
    }
    
    var textFields: [TextFieldLayout]? = []
    var hyphenView: UIView? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Authing.getConfig { config in
            guard config != nil else {
                return
            }
            
            if (self.digit == 0) {
                self.digit = (config?.verifyCodeLength)!
            }
            
            self.textFields?.removeAll()
            for sub in self.subviews {
                sub.removeFromSuperview()
            }
            
            var i = 0
            while (i < self.digit) {
                let tf: TextFieldLayout = TextFieldLayout()
                tf.keyboardType = .numberPad
                tf.textAlignment = .center
                tf.tintColor = UIColor.clear
                tf.font = UIFont.systemFont(ofSize: 18)
                tf.backgroundColor = UIColor(white: 0.95, alpha: 1)
                tf.delegate = self
                self.textFields?.append(tf)
                self.addSubview(tf)
                
                if (self.hyphen && i == self.digit / 2) {
                    self.hyphenView = UIView()
                    self.hyphenView?.backgroundColor = UIColor(white: 0.9, alpha: 1)
                    self.addSubview(self.hyphenView!)
                }
                i += 1
            }
        }
    }
    
    open override func layoutSubviews() {
        let hyphenWidth = CGFloat(12)
        let hyphenSpace = self.hyphenView != nil ? hyphenWidth + boxSpacing : 0
        let w = self.frame.width
        let h = self.frame.height
        let x = (w - hyphenSpace - boxWidth * CGFloat(Float(digit)) - boxSpacing * CGFloat((digit - 1))) / 2
        var i = 0
        for tf in textFields! {
            if (i < digit / 2) {
                tf.frame = CGRect(x: x + CGFloat(i) * (boxWidth + boxSpacing), y: 0, width: boxWidth, height: h)
            } else {
                tf.frame = CGRect(x: x + hyphenSpace + CGFloat(i) * (boxWidth + boxSpacing), y: 0, width: boxWidth, height: h)
            }
            i += 1
        }
        
        if (hyphenView != nil) {
            hyphenView?.frame = CGRect(x: (w - hyphenWidth) / 2, y: h/2, width: hyphenWidth, height: 1)
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let tf = textField as? TextFieldLayout {
            tf.border?.setHighlight(true)
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        UIMenuController.shared.hideMenu()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let tf = textField as? TextFieldLayout {
            tf.border?.setHighlight(false)
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            DispatchQueue.main.async() {
                self.moveFocusToPrevious(textField)
            }
            return true
        }
        
        if (textField.text != string) {
            textField.text = String(string.prefix(1))
        }
        DispatchQueue.main.async() {
            self.moveFocusToNext(textField)
        }
        return false
    }
    
    private func moveFocusToNext(_ textField: UITextField) {
        var i = 0
        var next = 0
        for tf in textFields! {
            if (tf == textField) {
                next = i + 1
                if (next >= digit) {
                    next = digit - 1
                }
                break
            }
            i += 1
        }
        
        if let tf = textField as? TextFieldLayout {
            tf.resignFirstResponder()
        }
        
        textFields![next].becomeFirstResponder()
    }
    
    private func moveFocusToPrevious(_ textField: UITextField) {
        var i = 0
        var next = 0
        for tf in textFields! {
            if (tf == textField) {
                next = i - 1
                if (next < 0) {
                    next = 0
                }
                break
            }
            i += 1
        }
        
        if let tf = textField as? TextFieldLayout {
            tf.resignFirstResponder()
        }
        
        textFields![next].becomeFirstResponder()
    }
    
    public func getText() -> String {
        var s: String = ""
        for tf in textFields! {
            s += tf.text ?? ""
        }
        return s
    }
}
