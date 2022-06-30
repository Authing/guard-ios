//
//  AuthingNavigationController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

open class AuthNavigationController: UINavigationController {
    
    private var authCompletion: Authing.AuthCompletion?
    
    public func setAuthCompletion(_ completion: Authing.AuthCompletion?) {
        self.authCompletion = completion
    }
    
    public func getAuthCompletion() -> Authing.AuthCompletion? {
        return self.authCompletion
    }
    
    public func complete(_ code: Int, _ message: String?, _ userInfo: UserInfo?, animated: Bool = true) {
        dismiss(animated: animated) {
            self.authCompletion?(code, message, userInfo)
        }
    }
}
