//
//  AppName.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import UIKit

open class AppName: Label {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        fontSize = 20
        isBold = true
        textAlignment = .center
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Util.getConfig(self) { config in
            if let tv = self.textValue {
                self.text = tv
            } else {
                self.text = config?.name
            }
            if let root = Util.findView(self, viewClass: RootView.self) {
                root.setNeedsLayout()
            }
        }
    }
}
