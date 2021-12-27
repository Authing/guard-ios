//
//  LoginMethodTab.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

open class LoginMethodTab: UIView {
    
    private static let ITEM_WIDTH: CGFloat = 120
    
    var items = [LoginMethodTabItem]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(self.frame)
    }

    private func setup(_ frame: CGRect) {
        isUserInteractionEnabled = true
        
        Authing.getConfig { config in
            let underLine: UIView = UIView(frame: CGRect())
            self.addSubview(underLine)
            underLine.translatesAutoresizingMaskIntoConstraints = false
            underLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
            underLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
            underLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
            underLine.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            underLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
            
            var i: CGFloat = 0
            config?.loginMethods?.forEach({ method in
                let frame = CGRect(x: i * LoginMethodTab.ITEM_WIDTH, y: 0, width: LoginMethodTab.ITEM_WIDTH, height: frame.height)
                let item: LoginMethodTabItem = LoginMethodTabItem(frame: frame)
                if (method == "phone-code") {
                    item.setText(NSLocalizedString("authing_login_by_phone_code", bundle: Bundle(for: Self.self), comment: ""))
                    item.type = 0
                } else if (method == "password") {
                    item.setText(NSLocalizedString("authing_login_by_password", bundle: Bundle(for: Self.self), comment: ""))
                    item.type = 1
                }
                let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onClick))
                gesture.numberOfTapsRequired = 1
                item.addGestureRecognizer(gesture)
                if (method == config?.defaultLoginMethod) {
                    item.gainFocus()
                }
                self.addSubview(item)
                self.items.append(item)
                
                i += 1
            })
            
            self.setItemFrame()
        }
    }
    
    private func setItemFrame() {
        var i: CGFloat = 0
        items.forEach { item in
            let frame = CGRect(x: i * LoginMethodTab.ITEM_WIDTH, y: 0, width: LoginMethodTab.ITEM_WIDTH, height: frame.height)
            item.frame = frame
            i += 1
        }
    }
    
    @objc private func onClick(sender: UITapGestureRecognizer) {
        items.forEach { item in
            if (item == sender.view) {
                item.gainFocus()
            } else {
                item.loseFocus()
            }
        }
    }
}