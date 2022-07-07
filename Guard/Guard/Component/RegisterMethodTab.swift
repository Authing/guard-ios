//
//  RegisterMethodTab.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

open class RegisterMethodTab: MethodTab {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func doSetup(_ config: Config) {
        var i: CGFloat = 0
        config.registerMethods?.forEach({ method in
            let frame = CGRect.zero
            let item = RegisterMethodTabItem(frame: frame)
            if (method == "phone") {
                item.setText("authing_register_by_phone".L)
                item.type = 0
            } else if (method == "email") {
                item.setText("authing_register_by_email".L)
                item.type = 1
            }else if (method == "emailCode") {
                item.setText("authing_register_by_emailCode".L)
                item.type = 2
            }

            self.addSubview(item)
            self.items.append(item)
            if (method == config.defaultRegisterMethod) {
                item.gainFocus(lastFocused: nil)
            } else {
                item.loseFocus()
            }
            i += 1
        })
    }
}
