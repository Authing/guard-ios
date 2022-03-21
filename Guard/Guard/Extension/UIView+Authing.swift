//
//  UIView+Authing.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import UIKit

extension UIView {
    public var viewController: AuthViewController? {
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? AuthViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
