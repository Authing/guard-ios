//
//  UserInfoCompleteContentView.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/21.
//

import UIKit

open class UserInfoCompleteContentView: UIView {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = Util.findView(self, viewClass: UserInfoCompleteButton.self)
        if (v != nil) {
            let p = v!.convert(point, from: self)
            if (v!.bounds.contains(p)) {
                return v?.hitTest(p, with: event)
            }
        }
        return super.hitTest(point, with: event)
    }
}
