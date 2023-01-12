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

public enum TransitionAnimation {
    case Push
    case Present
}

public enum RequestType {
    case FeedBack
    case Register
    case ResetPassword
    case BindingWebAuthn
}

public typealias RequestSuccessCallBack = (_ requestType: RequestType, _ code: Int, _ message: String, _ userInfo: UserInfo?) -> Void

public class AuthFlow: NSObject {
        
    public static let KEY_USER_INFO: String = "user_info"
    public static let KEY_ACCOUNT: String = "account"
    public static let KEY_EXTENDED_FIELDS: String = "extended_fields"
    public static let KEY_MFA_PHONE: String = "mfa_phone"
    public static let KEY_MFA_EMAIL: String = "mfa_email"
    public static let KEY_BINDING_WEBAUTHN: String = "binding_webauthn"

    public var startViewController: UIViewController?
    public var authCompletion: Authing.AuthCompletion?
    
    public var data: NSDictionary = NSMutableDictionary()
    
    // nil means Authing default. don't set value otherwise engine won't know from which bundle to load xib
    public var loginXibName: String? = nil
    public var registerXibName: String? = nil
    public var forgotPasswordXibName: String? = nil
    public var feedBackXibName: String? = nil
    public var deleteAccountXibName: String? = nil

    // MFA
    public var mfaFromViewControllerName: String? = nil
    public var mfaRecoveryCode: String? = nil

    public var resetPasswordFirstTimeLoginXibName: String? = nil
    
    public var authProtocol: AuthProtocol = .EInHouse
    
    public var transition: TransitionAnimation = .Present

    // if not nil, we are in dynamic mode. the appId in appBundle can be different than Authing.getAppId
    // which means we are doing some management work e.g. editor
    public var appBundle: AppBundle? = nil
    public var config: Config? = nil
    
    // UI
    public var UIConfig: AuthFlowUIConfig? = nil
    
    public var requestCallBack: RequestSuccessCallBack?
    
    public var enrollmentToken: String? = nil


    public override init() {
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
        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        UIApplication.topViewController()!.present(nav, animated: true, completion: nil)
    }
    
    @objc public func start(authCompletion: Authing.AuthCompletion? = nil) {
        var vc: IndexAuthViewController? = nil

        DispatchQueue.main.async() {
            
            if let nibName = self.loginXibName {
                vc = IndexAuthViewController(nibName: nibName, bundle: Bundle.main)
            } else {
                vc = IndexAuthViewController(nibName: "AuthingLogin", bundle: Bundle(for: Self.self))
            }
                
            guard let target = vc else {
                return
            }
            
            target.authFlow = self
            self.authCompletion = authCompletion
            
            if let topVC = UIApplication.topViewController() {
                self.startViewController = topVC
                self._start(topVC, target)
            }
        }
    }
    
    private func _start(_ topVC: UIViewController, _ target: AuthViewController) {
        if let n = topVC.navigationController {
            if transition == .Push {
                n.pushViewController(target, animated: true)
                return
            }
        }
        
        let nav = UINavigationController(rootViewController: target)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        topVC.present(nav, animated: true, completion: nil)
    }
    
    public func complete(_ code: Int, _ message: String?, _ userInfo: UserInfo?, animated: Bool = true) {
        if let value = data[AuthFlow.KEY_BINDING_WEBAUTHN] as? String {
            if !value.isEmpty {
                self.requestCallBack?(.BindingWebAuthn, code, message ?? "", userInfo)
                return
            }
        }
        DispatchQueue.main.async() {
            self.authCompletion?(code, message, userInfo)
        }
        if transition == .Push {
            startViewController?.navigationController?.popToViewController(startViewController!, animated: true)
        } else {
            startViewController?.dismiss(animated: true)
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
                let dictionary: NSMutableDictionary = dic.mutableCopy() as? NSMutableDictionary ?? [:]
                let name: String? = dictionary["name"] as? String
                if let extendsFieldsI18n = config!.extendsFieldsI18n {
                    extendsFieldsI18n.forEach { (key, value) in
                        if name == key as? String {
                            if let v: NSDictionary = value as? NSDictionary {
                                v.forEach { (key, value) in
                                    dictionary[key] = value
                                }
                            }
                        }
                    }
                }
                let value: String? = userInfo!.raw?[name as Any] as? String
                if (Util.isNull(value) || ("gender" == name && "U" == value)) {
                    missing.append(dictionary)
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
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                nav.setNavigationBarHidden(true, animated: false)
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
    
    public override func copy() -> Any {
        let copy = AuthFlow(data)
        copy.startViewController = self.startViewController
        copy.authCompletion = self.authCompletion
        copy.loginXibName = self.loginXibName
        copy.registerXibName = self.registerXibName
        copy.forgotPasswordXibName = self.forgotPasswordXibName
        copy.feedBackXibName = self.feedBackXibName
        copy.deleteAccountXibName = self.deleteAccountXibName
        copy.mfaFromViewControllerName = self.mfaFromViewControllerName
        copy.resetPasswordFirstTimeLoginXibName = self.resetPasswordFirstTimeLoginXibName
        copy.requestCallBack = self.requestCallBack
        copy.appBundle = self.appBundle
        copy.config = self.config
        copy.authProtocol = self.authProtocol
        copy.mfaRecoveryCode = self.mfaRecoveryCode
        copy.UIConfig = self.UIConfig
        copy.enrollmentToken = self.enrollmentToken
        return copy
    }
    
}
