//
//  MFARecoveryCodeTextField.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//

import Foundation

open class MFARecoveryCodeTextField: AccountTextField {
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func setup() {

        if let image = UIImage(named: "authing_password", in: Bundle(for: Self.self), compatibleWith: nil) {
            self.updateIconImage(icon: image)
        }
        
        let sTip: String = "authing_recovery_button".L
        setHint("\(sTip)")
    }
}
