//
//  SocialNoLoginMethodsView.swift
//  Guard
//
//  Created by JnMars on 2022/9/18.
//

import Foundation

class SocialNoLoginMethodsView: UIView, AttributedViewProtocol {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.isHidden = true
        
        Util.getConfig(self) { config in
            var hidden: Bool = false
            for method in config?.loginMethods ?? [] {
                if (method == "phone-code") {
                    hidden = true
                } else if (method == "password") {
                    hidden = true
                } else if (method == "email-code") {
                    hidden = true
                }
            }
            self.isHidden = hidden
        }
    }
    
}
