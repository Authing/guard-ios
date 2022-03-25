//
//  UserInfoCompleteButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/17.
//

import UIKit

open class UserInfoCompleteButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Util.setError(self, " ")
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let vc: AuthViewController? = authViewController
        if (vc == nil) {
            return
        }
        
        let container: UserInfoCompleteContainer? = Util.findView(self, viewClass: UserInfoCompleteContainer.self)
        if (container == nil) {
            return
        }
        
        Util.setError(self, " ")
        startLoading()
        doComplete(0, container: container, userInfo: nil)
    }
    
    private func doComplete(_ step: Int, container: UserInfoCompleteContainer?, userInfo: UserInfo?) {
        DispatchQueue.main.async() {
            self._doComplete(step, container: container, userInfo: userInfo)
        }
    }
    
    private func _doComplete(_ step: Int, container: UserInfoCompleteContainer?, userInfo: UserInfo?) {
        if (step == 0) {
            bindEmail(container: container, userInfo: userInfo) { goon, user in
                if (goon) {
                    self.doComplete(1, container: container, userInfo: user)
                } else {
                    self.cancel()
                }
            }
        } else if (step == 1) {
            bindPhone(container: container, userInfo: userInfo) { goon, user in
                if (goon) {
                    self.doComplete(2, container: container, userInfo: user)
                } else {
                    self.cancel()
                }
            }
        } else if (step == 2) {
            updateInfo(container: container, userInfo: userInfo) { code, message, user in
                if (code == 200) {
                    if (user != nil) {
                        self.done(code, message, user)
                    } else {
                        self.done(code, message, userInfo)
                    }
                } else {
                    self.cancel()
                }
            }
        }
    }
    
    private func bindEmail(container: UserInfoCompleteContainer?, userInfo: UserInfo?, completion: @escaping(Bool, UserInfo?) -> Void) {
        if (container == nil) {
            return
        }
        
        var form: UserInfoCompleteFieldEmail? = nil
        for sub in container!.subviews {
            form = sub as? UserInfoCompleteFieldEmail
            if (form != nil) {
                break
            }
        }
        
        if (form == nil) {
            completion(true, userInfo)
            return
        }
        
        let required: Bool = form!.data?["required"] as! Bool
        let email = form!.getEmail()
        if (required && Util.isNull(email)) {
            Util.setError(self, NSLocalizedString("authing_email_cannot_be_empty", bundle: Bundle(for: Self.self), comment: ""))
            completion(false, nil)
            return
        }
        
        let code = form!.getCode()
        if (required && Util.isNull(code)) {
            Util.setError(self, NSLocalizedString("authing_email_code_cannot_be_empty", bundle: Bundle(for: Self.self), comment: ""))
            completion(false, nil)
            return
        }
        
        Util.getAuthClient(self).bindEmail(email: email!.lowercased(), code: code!) { code, message, user in
            if (code == 200) {
                completion(true, user)
            } else if (required) {
                Util.setError(self, message)
                completion(false, nil)
            } else {
                completion(true, userInfo)
            }
        }
    }
    
    private func bindPhone(container: UserInfoCompleteContainer?, userInfo: UserInfo?, completion: @escaping(Bool, UserInfo?) -> Void) {
        if (container == nil) {
            return
        }
        
        var form: UserInfoCompleteFieldPhone? = nil
        for sub in container!.subviews {
            form = sub as? UserInfoCompleteFieldPhone
            if (form != nil) {
                break
            }
        }
        
        if (form == nil) {
            completion(true, userInfo)
            return
        }
        
        let required: Bool = form!.data?["required"] as! Bool
        let phone = form!.getPhone()
        if (required && Util.isNull(phone)) {
            Util.setError(self, NSLocalizedString("authing_phone_cannot_be_empty", bundle: Bundle(for: Self.self), comment: ""))
            completion(false, nil)
            return
        }
        
        let code = form!.getCode()
        if (required && Util.isNull(code)) {
            Util.setError(self, NSLocalizedString("authing_phone_code_cannot_be_empty", bundle: Bundle(for: Self.self), comment: ""))
            completion(false, nil)
            return
        }
        
        Util.getAuthClient(self).bindPhone(phone: phone!, code: code!) { code, message, user in
            if (code == 200) {
                completion(true, user)
            } else if (required) {
                Util.setError(self, message)
                completion(false, nil)
            } else {
                completion(true, userInfo)
            }
        }
    }
    
    private func updateInfo(container: UserInfoCompleteContainer?, userInfo: UserInfo?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        if (container == nil) {
            return
        }
        
        var forms: Array<UserInfoCompleteFieldForm> = []
        for sub in container!.subviews {
            if let form = sub as? UserInfoCompleteFieldFormText {
                forms.append(form)
            }
            if let form = sub as? UserInfoCompleteFieldFormSelect {
                forms.append(form)
            }
            if let form = sub as? UserInfoCompleteFieldFormDateTime {
                forms.append(form)
            }
        }
        
        if (forms.count == 0) {
            completion(200, nil, userInfo)
            return
        }
        
        let updatedInfo: NSMutableDictionary = [:]
        for form: UserInfoCompleteFieldForm in forms {
            let required: Bool = form.data?["required"] as! Bool
            let name: String? = form.data!["name"] as? String
            let label: String? = form.data!["label"] as? String
            let value = form.getValue()
            
            if (required && Util.isNull(value)) {
                Util.setError(self, "\(label!)\(NSLocalizedString("authing_is_required", bundle: Bundle(for: Self.self), comment: ""))")
                completion(500, nil, nil)
                return
            }
            
            if (name != nil && value != nil) {
                let value = form.getValue()
                updatedInfo.setValue(value, forKey: name!)
            }
        }
        
        Util.getAuthClient(self).updateProfile(object: updatedInfo, completion: { code, message, userInfo in
            if (code == 200) {
                completion(200, message, userInfo)
            } else {
                Util.setError(self, message)
                completion(code, message, nil)
            }
        })
    }
    
    private func cancel() {
        stopLoading()
    }
    
    private func done(_ code: Int, _ message: String?, _ userInfo: UserInfo?) {
        DispatchQueue.main.async() {
            if let vc = self.authViewController?.navigationController as? AuthNavigationController {
                vc.complete(code, message, userInfo)
            }
        }
    }
}
