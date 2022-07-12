//
//  LoginView.swift
//  Guard
//
//  Created by JnMars on 2022/7/12.
//

import Foundation

class LoginView: UIView {
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        
        if let type = Bundle(identifier: "cn.authing.OneAuth")?.classNamed("OneAuth.OneAuthButton") as? SocialLoginButton.Type {
            let button = type.init()
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitle("手机号码一键登录", for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.backgroundColor = Const.Color_BG_Text_Box
            self.addSubview(button)
            let loginButton = Util.findView(self, viewClass: LoginButton.self)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
            button.topAnchor.constraint(equalTo: loginButton?.bottomAnchor ?? self.topAnchor, constant: 16).isActive = true
        }
    }
}
