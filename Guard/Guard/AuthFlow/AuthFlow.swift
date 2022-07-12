//
//  AuthFlow.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

public enum AuthProtocol {
    case EInHouse
    case EOIDC
}

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
    public var feedBackXibName: String? = nil

    // MFA
    public var mfaPhoneXibName: [String]? = nil
    public var mfaEmailXibName: [String]? = nil
    public var mfaOTPXibName: String? = nil
    
    public var resetPasswordFirstTimeLoginXibName: String? = nil
    
    public var authProtocol: AuthProtocol = .EInHouse
    
    // if not nil, we are in dynamic mode. the appId in appBundle can be different than Authing.getAppId
    // which means we are doing some management work e.g. editor
    public var appBundle: AppBundle? = nil
    public var config: Config? = nil

    public var skipConsent: Bool = false
    
    public init() {
    }
    
    public init(_ appId: String?) {
        if let appid = appId {
            config = Config(appId: appid)
        }
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
    
    public func start(_ appId: String? = nil, authCompletion: Authing.AuthCompletion? = nil) {
        var vc: IndexAuthViewController? = nil
        if let nibName = loginXibName {
            vc = IndexAuthViewController(nibName: nibName, bundle: Bundle.main)
        } else {
            vc = IndexAuthViewController(nibName: "AuthingLogin", bundle: Bundle(for: Self.self))
        }
        
        guard vc != nil else {
            return
        }

        vc?.authFlow = self
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
    }
    
    public static func getAccount(current: UIView) -> String? {
        var account: String? = nil
        let tf: AccountTextField? = Util.findView(current, viewClass: AccountTextField.self)
        if (tf != nil) {
            account = tf?.text
        }
        
        if (account == nil || account!.isEmpty) {
            let vc: AuthViewController? = current.authViewController
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
    
    public func startAppBundle(_ appId: String, authCompletion: Authing.AuthCompletion? = nil) {
        if let ab = Parser().parse(appId: appId) {
            Parser().inflate(appBundle: ab)
            AuthFlow().startAppBundle(ab, authCompletion: authCompletion)
        }
    }
    
    public func startAppBundle(_ appBundle: AppBundle, authCompletion: Authing.AuthCompletion? = nil) {
        guard let appid = appBundle.appId else {
            ALog.e(Self.self, "startAppBundle failed. No appid")
            return
        }
        
        guard let rootView = appBundle.indexView else {
            ALog.e(Self.self, "startAppBundle failed. App bundle has no index view. appId:\(appid)")
            return
        }
        
        config = Config(appId: appid)

        self.appBundle = appBundle
        let vc = IndexAuthViewController()
        vc.authFlow = self
        vc.view = rootView
        DispatchQueue.main.async() {
            if let topVC = UIApplication.topViewController() {
                let nav: AuthNavigationController = AuthNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                nav.setNavigationBarHidden(true, animated: false)
                nav.setAuthCompletion(authCompletion)
                topVC.present(nav, animated: true, completion: nil)
            } else {
                ALog.e(Self.self, "startAppBundle failed for \(appid). No view controller for current app")
            }
        }
    }
    
    public func getConfig(completion: @escaping(Config?)->Void) {
        if let c = config {
            c.getConfig(completion: completion)
        } else {
            completion(nil)
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AuthFlow(data)
        copy.loginXibName = self.loginXibName
        copy.registerXibName = self.registerXibName
        copy.forgotPasswordXibName = self.forgotPasswordXibName
        copy.mfaPhoneXibName = self.mfaPhoneXibName
        copy.mfaEmailXibName = self.mfaEmailXibName
        copy.mfaOTPXibName = self.mfaOTPXibName
        copy.resetPasswordFirstTimeLoginXibName = self.resetPasswordFirstTimeLoginXibName
        
        copy.appBundle = self.appBundle
        copy.config = self.config
        copy.skipConsent = self.skipConsent
        return copy
    }
    
}
