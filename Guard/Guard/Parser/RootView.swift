//
//  RootView.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/15.
//

import UIKit

protocol AttributedViewProtocol {
    func setAttribute(key: String, value: String)
}

open class RootView: UIScrollView {
    public override func layoutSubviews() {
        if let layout = subviews[0] as? Layout {
            layout.frame = self.frame
        }
    }
}
