//
//  PhoneLabel.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/12.
//

import UIKit

open class PhoneLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        DispatchQueue.main.async() {
            if let phone = Util.getPhoneNumber(self) {
                self.text = phone
            }
        }
    }
}
