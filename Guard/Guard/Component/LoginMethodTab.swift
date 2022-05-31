//
//  LoginMethodTab.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

open class LoginMethodTab: MethodTab {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func doSetup(_ config: Config) {
        var i: CGFloat = 0
        var defaultLoginIncluded = false
        for method in config.loginMethods ?? [] {
            let frame = CGRect(x: i * self.ITEM_WIDTH, y: 0, width: self.ITEM_WIDTH, height: frame.height)
            let item = LoginMethodTabItem(frame: frame)
            if (method == "phone-code") {
                item.setText(NSLocalizedString("authing_login_by_phone_code", bundle: Bundle(for: Self.self), comment: ""))
                item.type = 0
            } else if (method == "password") {
                item.setText(NSLocalizedString("authing_login_by_password", bundle: Bundle(for: Self.self), comment: ""))
                item.type = 1
            } else if (method == "email-code") {
                item.setText(NSLocalizedString("authing_login_by_email_code", bundle: Bundle(for: Self.self), comment: ""))
                item.type = 2
            } else {
                continue
            }
            
            if (method == config.defaultLoginMethod) {
                defaultLoginIncluded = true
                item.gainFocus(lastFocused: nil)
            } else {
                item.loseFocus()
            }
            self.addSubview(item)
            self.items.append(item)
            
            i += 1
        }
        
        if !defaultLoginIncluded && self.items.count > 0 {
            self.items[0].gainFocus(lastFocused: nil)
        }
    }
}
