//
//  UserInfoFieldForm.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/17.
//

import UIKit

open class UserInfoCompleteFieldForm: UIView {
    
    let LABEL_H: CGFloat = CGFloat(26)
    
    var label: UILabel = UILabel()
    var labelAsterisk: UILabel = UILabel()
    var data: NSDictionary? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        addSubview(label)
        addSubview(labelAsterisk)
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.heightAnchor.constraint(equalToConstant: LABEL_H).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        labelAsterisk.font = UIFont.systemFont(ofSize: 14)
        labelAsterisk.textColor = Const.Color_Asterisk
        labelAsterisk.heightAnchor.constraint(equalToConstant: LABEL_H).isActive = true
        labelAsterisk.translatesAutoresizingMaskIntoConstraints = false
        labelAsterisk.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 0).isActive = true
        labelAsterisk.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
    }
    
    public func getHeight() -> CGFloat {
        return LABEL_H
    }
    
    public func getValue() -> String? {
        return nil
    }
    
    public func setFormData(_ data: NSDictionary) {
        self.data = data
        label.text = data["label"] as? String
        let required: Bool = data["required"] as! Bool
        if (required) {
            labelAsterisk.text = "*"
        }
    }
}
