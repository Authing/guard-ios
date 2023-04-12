//
//  UserInfoCompleteSkipButton.swift
//  Guard
//
//  Created by JnMars on 2022/8/25.
//

import Foundation

open class UserInfoCompleteSkipButton: Button {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        
        Util.getConfig(self) { config in
            self.isHidden = !(config?.skipComplateFileds ?? false)
        }
        let text = "authing_complete_skip".L
        self.setTitle(text, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        self.authViewController?.authFlow?.complete(200, "", Authing.getCurrentUser())
    }
    
}
