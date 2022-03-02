//
//  LogoutButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/1.
//

import UIKit

open class LogoutButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.white
        setTitleColor(UIColor.black, for: .normal)
        let text = NSLocalizedString("authing_logout", bundle: Bundle(for: Self.self), comment: "")
        self.setTitle(text, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        AuthClient.logout { code, message in
        }
    }
}
