//
//  PrimaryButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/28.
//

import UIKit

open class PrimaryButton: LoadingButton {
    
    var authCompletion: Guard.AuthCompletion?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        layer.cornerRadius = 4
        layer.masksToBounds = true
        self.backgroundColor = Const.Color_Authing_Main
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .highlighted)
    }
    
    public func setAuthCompletion(_ completion: Guard.AuthCompletion?) {
        self.authCompletion = completion
    }
}
