//
//  FaceIdLoginButton.swift
//  FaceId
//
//  Created by JnMars on 2022/8/12.
//

import Foundation

open class FaceIdLoginButton: SocialLoginButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        setImage(UIImage(named: "authing_face", in: Bundle(for: SocialLoginListView.self), compatibleWith: nil), for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        
        if PrivacyToast.privacyBoxIsChecked() == false {
            PrivacyToast.showToast(viewController: self.viewController ?? UIViewController(), true)
            return
        }
        
        

    }
    
}
