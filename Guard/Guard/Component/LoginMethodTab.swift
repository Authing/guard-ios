//
//  LoginMethodTab.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

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
            let frame = CGRect.zero
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
            
            self.addSubview(item)
            self.items.append(item)
            
            if (method == config.defaultLoginMethod) {
                defaultLoginIncluded = true
                item.gainFocus(lastFocused: nil)
            } else {
                item.loseFocus()
            }

            i += 1
        }
        
        if !defaultLoginIncluded && self.items.count > 0 {
            self.items[0].gainFocus(lastFocused: nil)
        }
    }
}
