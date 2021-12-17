//
//  AuthViewController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import UIKit

public class AuthViewController: UIViewController {

    public typealias AuthCompletion = (UserInfo?) -> Void
    
    private var authCompletion: AuthCompletion?
    
    public func setAuthCompletion(_ completion: AuthCompletion?) {
        self.authCompletion = completion
    }
    
    public func getAuthCompletion() -> AuthCompletion? {
        return self.authCompletion
    }
    
    @IBAction func onCloseClick(_ sender: UIButton, forEvent event: UIEvent) {
        dismiss(animated: true, completion: nil)
    }
    
    public func complete(_ userInfo: UserInfo?) {
        dismiss(animated: true) {
            self.authCompletion?(userInfo)
        }
    }
}
