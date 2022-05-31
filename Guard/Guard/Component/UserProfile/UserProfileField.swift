//
//  UserProfileField.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/1.
//

import UIKit

open class UserProfileField: UIView {
    
    static let labels = ["photo":"authing_avatar",
                         "nickname":"authing_nickname",
                         "name":"authing_name",
                         "username":"authing_username",
                         "phone":"authing_phone",
                         "email":"authing_email"]
    let labelField: UILabel = UILabel()
    
    let MARGIN_X = CGFloat(20)
    let sep = UIView()
    
    @IBInspectable var field: String = "" {
        didSet {
            setField(field)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        labelField.textColor = Util.getLabelColor()
        addSubview(labelField)
        
        backgroundColor = Util.getWhiteBackgroundColor()
        sep.backgroundColor = Const.Color_BG_Gray
        addSubview(sep)
    }
    
    open override func layoutSubviews() {
        let h = labelField.intrinsicContentSize.height
        let y = (frame.height - h) / 2
        labelField.frame = CGRect(x: MARGIN_X, y: y, width: labelField.intrinsicContentSize.width, height: h)
        sep.frame = CGRect(x: MARGIN_X, y: 0, width: frame.width, height: Const.ONEPX)
    }
    
    func setField(_ field: String) {
        if let key = UserProfileField.labels[field] {
            labelField.text = NSLocalizedString(key, bundle: Bundle(for: Self.self), comment: "")
        }
    }
}
