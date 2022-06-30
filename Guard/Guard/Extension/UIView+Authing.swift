//
//  UIView+Authing.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

extension UIView {
    public var viewController: UIViewController? {
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
    
    public var authViewController: AuthViewController? {
        return viewController as? AuthViewController
    }
}
