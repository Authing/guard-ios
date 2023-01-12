//
//  BindingWebAuthnButton.swift
//  Guard
//
//  Created by JnMars on 2022/12/28.
//

import Foundation
import WebAuthn
import PromiseKit
import UIKit

class BindingWebAuthnButton: PrimaryButton {
    
    var webAuthnClient: WebAuthnClient!
    var userConsentUI: UserConsentUI!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let loginText = "authing_bind".L
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupWebAuthnClient()
    }
    
    @objc private func onClick(sender: UIButton) {

        if let tfPhone: PhoneNumberTextField = Util.findView(self, viewClass: PhoneNumberTextField.self),
           let tfCode: VerifyCodeTextField = Util.findView(self, viewClass: VerifyCodeTextField.self) {
                if let phone = tfPhone.text, let code = tfCode.text {
                    if !(Validator.isValidPhone(phone: phone)) {
                        Util.setError(tfPhone, "authing_invalid_phone".L)
                        return
                    }
                    if phone == "" {
                        Util.setError(tfPhone, "authing_phone_none".L)
                    } else if code == "" {
                        Util.setError(tfCode, "authing_verifycode_none".L)
                    } else {
                        loginByPhoneCode(tfPhone.countryCode, phone, code)
                    }
                    return
                }
        }
        
        if let tfAccount: AccountTextField = Util.findView(self, viewClass: AccountTextField.self),
            let tfPassword: PasswordTextField = Util.findView(self, viewClass: PasswordTextField.self) {
            if let account = tfAccount.text,
               let password = tfPassword.text {
                if account == "" {
                    Util.setError(tfAccount, "authing_account_none".L)
                } else if password == "" {
                    Util.setError(tfPassword, "authing_password_none".L)
                } else {
                    loginByAccount(account, password)
                }
                return
            }
        }
        
        if let tfEmail: EmailTextField = Util.findView(self, viewClass: EmailTextField.self),
           let tfEmailCode: VerifyCodeTextField = Util.findView(self, viewClass: VerifyCodeTextField.self) {
            if let email = tfEmail.text,
               let code = tfEmailCode.text {
                if !(Validator.isValidEmail(email: email)) {
                    Util.setError(tfEmail, "authing_invalid_email".L)
                    return
                }
                if email == "" {
                    Util.setError(tfEmail, "authing_email_none".L)
                } else if code == "" {
                    Util.setError(tfEmailCode, "authing_verifycode_none".L)
                } else {
                    loginByEmail(email, code)
                }
            }
        }
    }
    
    private func loginByPhoneCode(_ countryCode: String? = nil, _ phone: String, _ code: String) {
        startLoading()
                
        let authProtocol = authViewController?.authFlow?.authProtocol ?? .EInHouse
        if authProtocol == .EInHouse {
            Util.getAuthClient(self).loginByPhoneCode(phoneCountryCode: countryCode, phone: phone, code: code) { code, message, userInfo in
                self.stopLoading()
                self.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)
            }
        } else {
            OIDCClient().loginByPhoneCode(phoneCountryCode: countryCode, phone: phone, code: code) { code, message, userInfo in
                self.stopLoading()
                self.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)

            }
        }
    }
    
    private func loginByAccount(_ account: String, _ password: String) {
        startLoading()
        
        let authProtocol = authViewController?.authFlow?.authProtocol ?? .EInHouse
        if authProtocol == .EInHouse {
            Util.getAuthClient(self).loginByAccount(authData: nil, account: account, password: password) { code, message, userInfo in
                self.stopLoading()
                self.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)
            }
        } else {
            OIDCClient().loginByAccount(account: account, password: password) { code,  message,  userInfo in
                self.stopLoading()
                self.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)

            }
        }
    }
    
    private func loginByEmail(_ email: String, _ code: String) {
        startLoading()
        
        let authProtocol = authViewController?.authFlow?.authProtocol ?? .EInHouse
        if authProtocol == .EInHouse {
            Util.getAuthClient(self).loginByEmail(authData: nil, email: email, code: code) { code, message, userInfo in
                self.stopLoading()
                self.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)
            }
        } else {
            OIDCClient().loginByEmail(email: email, code: code) { code,  message,  userInfo in
                self.stopLoading()
                self.handleLogin(button: self, code, message: message, userInfo: userInfo, authCompletion: self.authCompletion)
            }
        }
    }
    
    private func handleLogin(button: Button, _ code: Int, message: String?, userInfo: UserInfo?, authCompletion: Authing.AuthCompletion? = nil) {
        
        DispatchQueue.main.async() {
            if (authCompletion != nil) {
                if (code != 200 && code != Const.EC_MFA_REQUIRED && code != Const.EC_FIRST_TIME_LOGIN) {
                    Util.setError(button, message)
                }
                authCompletion?(code, message, userInfo)
            } else if code == 200 {
                
                Util.getConfig(button) { config in
                    let missingFields: Array<NSDictionary> = AuthFlow.missingField(config: config, userInfo: userInfo)
                    if (config?.completeFieldsPlace != nil
                        && config!.completeFieldsPlace!.contains("login")
                        && missingFields.count > 0) {
                        let vc: AuthViewController? = AuthViewController(nibName: "AuthingUserInfoComplete", bundle: Bundle(for: Self.self))
                        vc?.hideNavigationBar = true
                        if let flow = button.authViewController?.authFlow {
                            vc?.authFlow = flow.copy() as? AuthFlow
                        }
                        vc?.authFlow?.data.setValue(missingFields, forKey: AuthFlow.KEY_EXTENDED_FIELDS)
                        vc?.authFlow?.data.setValue("webAuthn", forKey: AuthFlow.KEY_BINDING_WEBAUTHN)
                        button.authViewController?.navigationController?.pushViewController(vc!, animated: true)
                    } else {
                        self.bindingWebAuthn()
                    }
                }
                
                self.authViewController?.authFlow?.requestCallBack = { type, code, message, userInfo in
                    if type == .BindingWebAuthn {
                        self.bindingWebAuthn()
                    }
                }
            } else if (code == Const.EC_MFA_REQUIRED) {
                
                if let mfaPolicy = Authing.getCurrentUser()?.mfaPolicy {
                    for policy in mfaPolicy {
                        DispatchQueue.main.async() {
                            let vc = LoginButton.mfaHandle(view: button, mfaType: policy, needGuide: true)
                            vc?.authFlow?.data.setValue("webAuthn", forKey: AuthFlow.KEY_BINDING_WEBAUTHN)
                            button.authViewController?.navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
                        }
                        break
                    }
                }
                
                self.authViewController?.authFlow?.requestCallBack = { type, code, message, userInfo in
                    if type == .BindingWebAuthn {
                        self.bindingWebAuthn()
                    }
                }

            } else if (code == Const.EC_FIRST_TIME_LOGIN) {
                // clear password text field
                if let tfPassword: PasswordTextField = Util.findView(button, viewClass: PasswordTextField.self) {
                    tfPassword.text = ""
                }
                
                var nextVC: AuthViewController? = nil
                if let vc = button.viewController as? AuthViewController {
                    if (vc.authFlow?.resetPasswordFirstTimeLoginXibName == nil) {
                        nextVC = AuthViewController(nibName: "AuthingFirstTimeLogin", bundle: Bundle(for: Self.self))
                    } else {
                        nextVC = AuthViewController(nibName: vc.authFlow?.resetPasswordFirstTimeLoginXibName!, bundle: Bundle.main)
                    }
                    vc.authFlow?.data.setValue(userInfo, forKey: AuthFlow.KEY_USER_INFO)
                    vc.authFlow?.data.setValue("webAuthn", forKey: AuthFlow.KEY_BINDING_WEBAUTHN)
                    nextVC?.authFlow = vc.authFlow?.copy() as? AuthFlow
                    nextVC?.title = "authing_first_time_login_title".L
                    vc.navigationController?.pushViewController(nextVC!, animated: true)
                }
                
                self.authViewController?.authFlow?.requestCallBack = { type, code, message, userInfo in
                    if type == .BindingWebAuthn {
                        self.bindingWebAuthn()
                    }
                }

           } else {
                Toast.show(text: message ?? "")
            }
        }
    }
    
    private func bindingWebAuthn() {
        AuthClient().getWebauthnRegistrationParam() { code, message, res in
            if  let data = res?["data"] as? NSDictionary,
                let statusCode = res?["statusCode"] as? Int,
                statusCode == 200 {
                print(data)

                DispatchQueue.main.async() {
                    self.startRegistration(challenge: (data["registrationOptions"] as? NSDictionary)?["challenge"] as? String,
                                           userId: ((data["registrationOptions"] as? NSDictionary)?["user"] as? NSDictionary)?["id"] as? String,
                                           userName: ((data["registrationOptions"] as? NSDictionary)?["user"] as? NSDictionary)?["name"] as? String,
                                           displayName: ((data["registrationOptions"] as? NSDictionary)?["user"] as? NSDictionary)?["displayName"] as? String,
                                           rpId: ((data["registrationOptions"] as? NSDictionary)?["rp"] as? NSDictionary)?["id"] as? String,
                                           rpName: ((data["registrationOptions"] as? NSDictionary)?["rp"] as? NSDictionary)?["name"] as? String,
                                           timeout: (data["registrationOptions"] as? NSDictionary)?["timeout"] as? Int,
                                           ticket: data["ticket"] as? String)
                }
            } else {
                Toast.show(text: res?["message"] as? String ?? "")
            }
        }
    }
    
    private func setupWebAuthnClient() {
        self.userConsentUI = UserConsentUI(viewController: self.viewController ?? UIViewController())
    }
    
    private func startRegistration(challenge: String?, userId: String?, userName: String?, displayName: String?, rpId: String?, rpName: String?, timeout: Int?, ticket: String?) {
        
        guard let challenge = challenge else {
            return
        }
        if challenge.isEmpty {
            return
        }
        
        guard let userId = userId else {
            return
        }
        if userId.isEmpty {
            return
        }
        
        guard let userName = userName else {
            return
        }
        if userName.isEmpty {
            return
        }
        
        guard let displayName = displayName else {
            return
        }
        if displayName.isEmpty {
            return
        }
        
        guard let rpId = rpId else {
            return
        }
        if rpId.isEmpty {
            return
        }
        
        guard let rpName = rpName else {
            return
        }
        if rpName.isEmpty {
            return
        }
                
        let attestation = [
            AttestationConveyancePreference.direct,
            AttestationConveyancePreference.indirect,
            AttestationConveyancePreference.none,
        ][0]
        
        let verification = [
            UserVerificationRequirement.required,
            UserVerificationRequirement.preferred,
            UserVerificationRequirement.discouraged
        ][0]
        
        let requireResidentKey = true
        
        let store = KeychainCredentialStore()
        let authenticator = InternalAuthenticator(ui: self.userConsentUI, credentialStore: store)

        self.webAuthnClient = WebAuthnClient(
            origin:        "https://\(rpId)",
            authenticator: authenticator
        )
        
        var options = PublicKeyCredentialCreationOptions()
        options.challenge = Util.stringEncodeToUInt8Array(challenge)
        options.user.id = Bytes.fromString(userId)
        options.user.name = userName
        options.user.displayName = displayName

//        if let iconURL = userIconURLText {
//            if !iconURL.isEmpty {
//                options.user.icon = iconURL
//            }
//        }
        
        options.rp.id = rpId
        options.rp.name = rpName
        
//        if let iconURL = rpIconURLText {
//            if !iconURL.isEmpty {
//                options.rp.icon = iconURL
//            }
//        }
        
        options.attestation = attestation
        options.addPubKeyCredParam(alg: .es256)
        options.authenticatorSelection = AuthenticatorSelectionCriteria(
            requireResidentKey: requireResidentKey,
            userVerification: verification
        )
         options.timeout = UInt64(timeout ?? 60000)
        //self.webAuthnClient.minTimeout = 5
        //self.webAuthnClient.defaultTimeout = 5

        firstly {
            
            self.webAuthnClient.create(options)
            
        }.done { credential in
            
            let cid = credential.id
            let rid = Base64.encodeBase64URL(credential.rawId)
            let att = Base64.encodeBase64URL(credential.response.attestationObject)
            let clidata = Base64.encodeBase64URL(credential.response.clientDataJSON.data(using: .utf8)!)
            
            AuthClient().webauthnRegistration(ticket: ticket ?? "", credentialId: cid, rawId: rid, attestationObject: att, clientDataJSON: clidata, authenticatorCode: Util.isFullScreenIphone() == true ? "face" : "fingerprint") { code, message, res in
                if  let data = res?["data"] as? NSDictionary,
                    let verified = data["verified"] as? Bool,
                    verified == true,
                    let statusCode = res?["statusCode"] as? Int,
                    statusCode == 200 {
                    DispatchQueue.main.async() {
                        let nextVC = MFABindSuccessViewController(nibName: "AuthingMFABindSuccess", bundle: Bundle(for: Self.self))
                        nextVC.type = .webauthn
                        nextVC.authFlow = self.authViewController?.authFlow?.copy() as? AuthFlow
                        self.authViewController?.navigationController?.pushViewController(nextVC, animated: true)
                    }
                } else {
                    Toast.show(text: res?["message"] as? String ?? "")
                    
                    for publicKey in store.loadAllCredentialSources(rpId: rpId) {
                        _ = store.deleteCredentialSource(publicKey)
                    }
                }
            }

        }.catch { error in
            if let err = error as? WebAuthn.WAKError {

                if err == WAKError.cancelled {
                    
                } else {
                    Toast.show(text: "\(error)")
                }
            }
        }
        
    }
    
}
