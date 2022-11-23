//
//  MFAGoRecoveryCodeButton.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//

import Foundation

open class MFAGoRecoveryCodeButton: Button {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        
        let vc = AuthViewController(nibName: "AuthingRecoveryCode", bundle: Bundle(for: Self.self))
        vc.title = "authing_recovery_title".L
        vc.authFlow = self.authViewController?.authFlow?.copy() as? AuthFlow
        self.authViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
