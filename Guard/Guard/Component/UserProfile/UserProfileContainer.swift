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
            refersh()
        }
    }
    
    let logoutButton = LogoutButton()
    let deleteAccountButton = DeleteAccountButton()
    
    let notLoginTip = UILabel()
    let startLoginButton = PrimaryButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        refersh()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        refersh()
    }

    open func refersh() {
        for v in subviews {
            v.removeFromSuperview()
        }
        
        fieldsViews.removeAll()
        
        if Authing.getCurrentUser() != nil {
            if ("all" == fields) {
                addAvatarField()
                addTextField("nickname")
                addTextField("name")
                addTextField("username")
                addTextField("phone")
                addTextField("email")
            }
            
            logoutButton.onLogout = { code, message in
                self.refersh()
            }
            deleteAccountButton.onDeleteAccount = { code, message in
                self.refersh()
            }
            addSubview(logoutButton)
            addSubview(deleteAccountButton)
        } else {
            notLoginTip.textColor = UIColor.darkGray
            notLoginTip.text = NSLocalizedString("authing_not_login", bundle: Bundle(for: Self.self), comment: "")
            addSubview(notLoginTip)
            
            startLoginButton.setTitle(NSLocalizedString("authing_login", bundle: Bundle(for: Self.self), comment: ""), for: .normal)
            startLoginButton.addTarget(self, action:#selector(startLogin(sender:)), for: .touchUpInside)
            addSubview(startLoginButton)
        }
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
        if Authing.getCurrentUser() != nil {
            var y = 0.0
            for v in fieldsViews {
                v.frame = CGRect(x: 0, y: y, width: frame.width, height: TEXT_HEIGHT)
                y += v.frame.height
            }
            
            y += 4
            logoutButton.frame = CGRect(x: 0, y: y, width: frame.width, height: BUTTON_HEIGHT)
            
            y += 4 + BUTTON_HEIGHT
            deleteAccountButton.frame = CGRect(x: 0, y: y, width: frame.width, height: BUTTON_HEIGHT)
        } else {
            var y = 20.0
            let w = notLoginTip.intrinsicContentSize.width
            notLoginTip.frame = CGRect(x: MARGIN_X, y: y, width: w, height: BUTTON_HEIGHT)
            
            y += BUTTON_HEIGHT
            startLoginButton.frame = CGRect(x: MARGIN_X, y: y, width: frame.width - 2 * MARGIN_X, height: BUTTON_HEIGHT)
        }
    }
    
    @objc private func startLogin(sender: UIButton) {
        AuthFlow.start { userInfo in
            self.refersh()
        }
    }
}
