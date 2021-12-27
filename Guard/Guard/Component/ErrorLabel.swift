//
//  ErrorLabel.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/27.
//

import UIKit

open class ErrorLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        textColor = Const.Color_Error
    }
}
