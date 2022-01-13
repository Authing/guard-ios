//
//  GoRegisterButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class GoRegisterButton: GoSomewhereButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Authing.getConfig { config in
            if (config?.registerMethods == nil || config?.registerMethods?.count == 0) {
                self.isHidden = true
            }
        }
    }

    override func getText() -> String {
        return NSLocalizedString("authing_register_now", bundle: Bundle(for: Self.self), comment: "")
    }
    
    override func getNibName() -> String {
        return "AuthingRegister"
    }
}
