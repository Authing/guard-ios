//
//  UserProfileContainer.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/28.
//

import UIKit

open class UserProfileContainer: UIScrollView {
    
    let MARGIN_X = CGFloat(20)
    let TEXT_HEIGHT = CGFloat(52)
    let BUTTON_HEIGHT = CGFloat(44)
    
    var fieldsViews = Array<UserProfileField>()
    
    @IBInspectable var fields: String = "all" {
        didSet {
            setup()
        }
    }
    
    let logoutButton = LogoutButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        for v in subviews {
            v.removeFromSuperview()
        }
        
        fieldsViews.removeAll()
        
        if ("all" == fields) {
            addAvatarField()
            addTextField("nickname")
            addTextField("name")
            addTextField("username")
            addTextField("phone")
            addTextField("email")
        }
        
        addSubview(logoutButton)
    }
    
    private func addAvatarField() {
        let field = UserProfileAvatarField()
        addSubview(field)
        fieldsViews.append(field)
        field.field = "photo"
    }
    
    private func addTextField(_ field: String) {
        let uptf = UserProfileTextField()
        addSubview(uptf)
        fieldsViews.append(uptf)
        uptf.field = field
    }
    
    open override func layoutSubviews() {
        var y = 0.0
        for v in fieldsViews {
            v.frame = CGRect(x: 0, y: y, width: frame.width, height: TEXT_HEIGHT)
            y += v.frame.height
        }
        
        y += 4
        logoutButton.frame = CGRect(x: 0, y: y, width: frame.width, height: BUTTON_HEIGHT)
    }
}
