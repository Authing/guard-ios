//
//  AuthingNavigationController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class AuthNavigationController: UINavigationController {
    
    public typealias AuthCompletion = (UserInfo?) -> Void
    
    private var authCompletion: AuthCompletion?
    
    public func setAuthCompletion(_ completion: AuthCompletion?) {
        self.authCompletion = completion
    }
    
    public func getAuthCompletion() -> AuthCompletion? {
        return self.authCompletion
    }
    
    public func complete(_ userInfo: UserInfo?, animated: Bool = true) {
        dismiss(animated: animated) {
            self.authCompletion?(userInfo)
        }
    }
}
