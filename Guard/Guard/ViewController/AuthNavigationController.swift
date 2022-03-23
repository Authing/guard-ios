//
//  AuthingNavigationController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class AuthNavigationController: UINavigationController {
    
    private var authCompletion: Guard.AuthCompletion?
    
    public func setAuthCompletion(_ completion: Guard.AuthCompletion?) {
        self.authCompletion = completion
    }
    
    public func getAuthCompletion() -> Guard.AuthCompletion? {
        return self.authCompletion
    }
    
    public func complete(_ code: Int, _ message: String?, _ userInfo: UserInfo?, animated: Bool = true) {
        dismiss(animated: animated) {
            self.authCompletion?(code, message, userInfo)
        }
    }
}
