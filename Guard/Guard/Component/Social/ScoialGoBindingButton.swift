//
//  ScoialGoBindingButton.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//

import Foundation

class ScoialGoBindingButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let loginText = "authing_login".L
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let vc = AuthViewController(nibName: "AuthingBinding", bundle: Bundle(for: Self.self))
        vc.authFlow = self.authViewController?.authFlow?.copy() as? AuthFlow
        self.authViewController?.navigationController?.pushViewController(vc, animated: true)
        
    }
}
