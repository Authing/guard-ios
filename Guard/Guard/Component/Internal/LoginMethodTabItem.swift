//
//  LoginMethodTabItem.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

public class LoginMethodTabItem: MethodTabItem {
    override public func focusGained() {
        let containers: Array<LoginContainer> = Util.findViews(self, viewClass: LoginContainer.self)
        containers.forEach { container in
            if (container.type == self.type) {
                container.isHidden = false
            } else {
                container.isHidden = true
            }
        }
    }
}
