//
//  AuthFlow.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import UIKit

public class AuthFlow {
    
    public static let KEY_USER_INFO: String = "user_info"
    public static let KEY_ACCOUNT: String = "account"
    public static let KEY_MFA_PHONE: String = "mfa_phone"
    public static let KEY_MFA_EMAIL: String = "mfa_email"
    
    public var data: NSDictionary = NSMutableDictionary()
    
    init() {
    }
    
    init(_ data: NSDictionary) {
        self.data = data.mutableCopy() as! NSDictionary
    }
    
    public static func showUserProfile() {
        let vc = UserProfileViewController(nibName: "AuthingUserProfile", bundle: Bundle(for: Self.self))
        let nav: AuthNavigationController = AuthNavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        UIApplication.topViewController()!.present(nav, animated: true, completion: nil)
    }
    
    public static func start(nibName: String? = nil, authCompletion: AuthNavigationController.AuthCompletion? = nil) {
        var vc: IndexAuthViewController? = nil
        if (nibName == nil) {
            vc = IndexAuthViewController(nibName: "AuthingLogin", bundle: Bundle(for: Self.self))
        } else {
            vc = IndexAuthViewController(nibName: nibName, bundle: nil)
        }
        
        guard vc != nil else {
            return
        }

        let nav: AuthNavigationController = AuthNavigationController(rootViewController: vc!)
        nav.setNavigationBarHidden(true, animated: false)
        nav.setAuthCompletion(authCompletion)
        nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        UIApplication.topViewController()!.present(nav, animated: true, completion: nil)
    }
    
    public static func getAccount(current: UIView) -> String? {
        var account: String? = nil
        let tf: AccountTextField? = Util.findView(current, viewClass: AccountTextField.self)
        if (tf != nil) {
            account = tf?.text
        }
        
        if (account == nil || account!.isEmpty) {
            let vc: AuthViewController? = current.viewController
            if (vc != nil) {
                account = vc?.authFlow?.data[AuthFlow.KEY_ACCOUNT] as? String
            }
        }
        return account
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AuthFlow(data)
        return copy
    }
}
