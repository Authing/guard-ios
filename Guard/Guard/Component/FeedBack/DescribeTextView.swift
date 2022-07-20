//
//  DescribeTextView.swift
//  Guard
//
//  Created by JnMars on 2022/7/7.
//

import Foundation

open class DescribeTextView: UIView {
    
    public var text: String?
    var textCountLabel: UILabel!
    var placeholderLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.backgroundColor = Const.Color_BG_Text_Box
        
        let textView = UITextView.init(frame: CGRect(x: 5, y: 5, width: self.frame.width - 10, height: self.frame.height - 10))
        textView.delegate = self
        textView.backgroundColor = UIColor.clear
        
        textView.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(textView)
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "authing_text_placeholder".L
        placeholderLabel.font = .italicSystemFont(ofSize: (textView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = Const.Color_Text_Default_Gray

        placeholderLabel.isHidden = !textView.text.isEmpty
        
        textCountLabel = UILabel.init(frame: CGRect(x: self.frame.width - 90, y: self.frame.height - 35, width: 80, height: 30))
        textCountLabel.textColor = Const.Color_Text_Gray
        textCountLabel.textAlignment = .right
        textCountLabel.font = UIFont.systemFont(ofSize: 16)
        textCountLabel.text = "0/500"
        self.addSubview(textCountLabel)
        
        layer.borderWidth = 1
        layer.cornerRadius = 4
        layer.borderColor = Const.Color_BG_Text_Box.cgColor
    }
    
}

extension DescribeTextView : UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        layer.borderColor = Const.Color_Authing_Main.cgColor
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) { 
        layer.borderColor = Const.Color_BG_Text_Box.cgColor
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        textCountLabel.text = "\(textView.text.count)/500"
        text = textView.text
    }
}
