//
//  GoBackButton.swift
//  Guard
//
//  Created by JnMars on 2022/7/12.
//

import Foundation

open class GoBackButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let loginText = "authing_reset_goback".L
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        if let vc = self.authViewController?.navigationController?.viewControllers.first as? AuthViewController {
            vc.authFlow = self.authViewController?.authFlow?.copy() as? AuthFlow
        }
        self.viewController?.navigationController?.popToRootViewController(animated: true)
    }
}
