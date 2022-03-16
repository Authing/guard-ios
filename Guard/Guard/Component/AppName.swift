//
//  AppName.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import UIKit

open class AppName: UILabel {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont.boldSystemFont(ofSize: 20)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Authing.getConfig { config in
            self.text = config?.name
        }
    }
}
