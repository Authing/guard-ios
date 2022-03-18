//
//  RootView.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/15.
//

import UIKit

public protocol AttributedViewProtocol {
    func setAttribute(key: String, value: String)
}

extension AttributedViewProtocol {
    public func setAttribute(key: String, value: String) {}
}

open class RootView: UIView, AttributedViewProtocol {
    public override func layoutSubviews() {
        if (subviews.count > 0) {
            if let layout = subviews[0] as? Layout {
                layout.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            }
        }
    }
    
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        layoutChild()
    }
    
    private func layoutChild() {
        if let layout = subviews[0] as? Layout {
            layout.layoutSubviews()
        }
    }
}
