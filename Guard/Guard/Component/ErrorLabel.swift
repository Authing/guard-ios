//
//  ErrorLabel.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/27.
//

import UIKit

open class ErrorLabel: UILabel, AttributedViewProtocol {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont.systemFont(ofSize: 14)
        numberOfLines = 2
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        if Util.isNull(text) {
            text = " "
        }
        textColor = Const.Color_Error
    }
}
