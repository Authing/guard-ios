//
//  GoFeedBackButton.swift
//  Guard
//
//  Created by JnMars on 2022/7/6.
//

import Foundation

class GoFeedBackButton: GoSomewhereButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {

    }
    
    override func goNow() {

        var nextVC: AuthViewController? = nil
        if let vc = authViewController {
            if (vc.authFlow?.feedBackXibName == nil) {
                nextVC = FeedBackController(nibName: "AuthingFeedBack", bundle: Bundle(for: Self.self))
            } else {
                nextVC = AuthViewController(nibName: vc.authFlow?.feedBackXibName!, bundle: Bundle.main)
            }
            nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
        }
        
        self.authViewController?.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
}
