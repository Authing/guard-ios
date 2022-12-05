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
        var methods = config.loginMethods ?? []

        if let socialBindingMethods = (authViewController?.authFlow?.data.value(forKey: AuthFlow.KEY_USER_INFO) as? UserInfo)?.socialBindingData?["methods"] as? [String] {
            methods = socialBindingMethods
            
            for method in methods {
                if method.contains("password") {
                    methods.append("password")
                }
            }
            
            methods = methods.enumerated().filter { (index, value) -> Bool in
                return methods.firstIndex(of: value) == index
            }.map {
                $0.element
            }
        }
        for method in methods {
            let frame = CGRect.zero
            let item = LoginMethodTabItem(frame: frame)
            if (method == "phone-code") {
                item.setText("authing_login_by_phone_code".L)
                item.type = 0
            } else if (method == "password") {
                item.setText("authing_login_by_password".L)
                item.type = 1
            } else if (method == "email-code") {
                item.setText("authing_login_by_email_code".L)
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
