//
//  UserInfoFieldForm.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/17.
//

import UIKit

open class UserInfoFieldForm: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
    }
    
    public func getHeight() ->CGFloat {
        return 128
    }
}
