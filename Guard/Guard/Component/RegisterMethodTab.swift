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
        
        for method in config.registerMethods ?? [] {
            let frame = CGRect.zero
            let item = RegisterMethodTabItem(frame: frame)
            if (method == "phone") {
                item.setText("authing_register_by_phone".L)
                item.type = 0
            } else if (method == "phone-password") {
                item.setText("authing_register_by_phonePassword".L)
                item.type = 1
            } else if (method == "email") {
                item.setText("authing_register_by_email".L)
                item.type = 2
            } else if (method == "emailCode") {
                item.setText("authing_register_by_emailCode".L)
                item.type = 3
            } else if method.contains("-password") {
                let field = method.replacingOccurrences(of: "-password", with: "")
                let text = Util.getExtendFieldTitle(config: config, field: field)
                item.setExtendField(field, text)
                item.setText(text)
                item.type = 4
            } else {
                continue
            }

            self.addSubview(item)
            self.items.append(item)
            if (method == config.defaultRegisterMethod) {
                item.gainFocus(lastFocused: nil)
            } else {
                item.loseFocus()
            }
            i += 1
        }
    }
}
