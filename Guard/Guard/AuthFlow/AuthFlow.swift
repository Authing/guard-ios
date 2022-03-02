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
    public static let KEY_EXTENDED_FIELDS: String = "extended_fields"
    public static let KEY_MFA_PHONE: String = "mfa_phone"
    public static let KEY_MFA_EMAIL: String = "mfa_email"
    
    public var data: NSDictionary = NSMutableDictionary()
    
    // nil means Authing default. don't set value otherwise engine won't know from which bundle to load xib
    public var loginXibName: String? = nil
    public var registerXibName: String? = nil
    public var forgotPasswordXibName: String? = nil
    public var resetPasswordByEmailXibName: String? = nil
    public var resetPasswordByPhoneXibName: String? = nil
    
    // MFA
    public var mfaPhoneXibName: [String]? = nil
    public var mfaEmailXibName: [String]? = nil
    public var mfaOTPXibName: String? = nil
    
    public var resetPasswordFirstTimeLoginXibName: String? = nil
    
    public init() {
    }
    
    public init(_ data: NSDictionary) {
        self.data = data.mutableCopy() as! NSDictionary
    }
    
    public static func showUserProfile() {
        let vc = UserProfileViewController(nibName: "AuthingUserProfile", bundle: Bundle(for: Self.self))
        let nav: AuthNavigationController = AuthNavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        UIApplication.topViewController()!.present(nav, animated: true, completion: nil)
    }
    
    public static func start(nibName: String? = nil, authCompletion: AuthNavigationController.AuthCompletion? = nil) -> AuthFlow? {
        var vc: IndexAuthViewController? = nil
        if (nibName == nil) {
            vc = IndexAuthViewController(nibName: "AuthingLogin", bundle: Bundle(for: Self.self))
        } else {
            vc = IndexAuthViewController(nibName: nibName, bundle: Bundle.main)
        }
        
        guard vc != nil else {
            return nil
        }

        let authFlow = AuthFlow()
        authFlow.loginXibName = nibName
        vc?.authFlow = authFlow
        let nav: AuthNavigationController = AuthNavigationController(rootViewController: vc!)
        nav.setNavigationBarHidden(true, animated: false)
        nav.setAuthCompletion(authCompletion)
        nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        if let topVC = UIApplication.topViewController() {
            topVC.present(nav, animated: true, completion: nil)
        } else {
            DispatchQueue.main.async() {
                UIApplication.topViewController()?.present(nav, animated: true, completion: nil)
            }
        }
        return authFlow
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
    
    public static func missingField(config: Config?, userInfo: UserInfo?) -> Array<NSDictionary> {
        var missing: Array<NSDictionary> = []
        guard config != nil && userInfo != nil else {
            return missing
        }
        
        if let extendedFields = config!.extendedFields {
            for dic: NSDictionary in extendedFields {
                let name: String? = dic["name"] as? String
                let value: String? = userInfo!.raw?[name as Any] as? String
                if (Util.isNull(value) || ("gender" == name && "U" == value)) {
                    missing.append(dic)
                }
            }
        }
        
        return missing
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AuthFlow(data)
        copy.loginXibName = self.loginXibName
        copy.registerXibName = self.registerXibName
        copy.forgotPasswordXibName = self.forgotPasswordXibName
        copy.resetPasswordByPhoneXibName = self.resetPasswordByPhoneXibName
        copy.resetPasswordByEmailXibName = self.resetPasswordByEmailXibName
        copy.mfaPhoneXibName = self.mfaPhoneXibName
        copy.mfaEmailXibName = self.mfaEmailXibName
        copy.mfaOTPXibName = self.mfaOTPXibName
        copy.resetPasswordFirstTimeLoginXibName = self.resetPasswordFirstTimeLoginXibName
        return copy
    }
}
