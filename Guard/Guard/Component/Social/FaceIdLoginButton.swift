//
//  FaceIdLoginButton.swift
//  FaceId
//
//  Created by JnMars on 2022/8/12.
//

import Foundation
import WebAuthn
import PromiseKit

open class FaceIdLoginButton: SocialLoginButton {
    
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
        setImage(UIImage(named: Util.isFullScreenIphone() == true ? "authing_face" : "authing_touch", in: Bundle(for: SocialLoginListView.self), compatibleWith: nil), for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupWebAuthnClient()
    }
    
    private func setupWebAuthnClient() {
                
        self.userConsentUI = UserConsentUI(viewController: self.authViewController ?? UIViewController())
        self.userConsentUI.config.alwaysShowKeySelection = false

    }

    @objc private func onClick(sender: UIButton) {

        if PrivacyToast.privacyBoxIsChecked() == false {
            PrivacyToast.showToast(viewController: self.authViewController ?? UIViewController(), true)
            return
        }

        AuthClient().getWebauthnAuthenticationParam() { code, message, res in
            if  let data = res?["data"] as? NSDictionary,
                let statusCode = res?["statusCode"] as? Int,
                statusCode == 200 {
                print(data)

                DispatchQueue.main.async() {

                    self.startAuthentication(challenge: (data["authenticationOptions"] as? NSDictionary)?["challenge"] as? String,
                                             rpId:  (data["authenticationOptions"] as? NSDictionary)?["rpId"] as? String,
                                             timeout:  (data["authenticationOptions"] as? NSDictionary)?["timeout"] as? Int,
                                             userVerification: (data["authenticationOptions"] as? NSDictionary)?["userVerification"] as? String,
                                             ticket: data["ticket"] as? String)
                }
            } else {
                Toast.show(text: res?["message"] as? String ?? "")
            }
        }
    }
    
    private func startAuthentication(challenge: String?, rpId: String?, timeout: Int?, userVerification: String?, ticket: String?) {
        
        guard let challenge = challenge else {
            return
        }
        
        if challenge.isEmpty {
            return
        }
        
        guard let rpId = rpId else {
            return
        }
        
        if rpId.isEmpty {
            return
        }
        
//        let authenticator = InternalAuthenticator(ui: self.userConsentUI)
        
        let store = KeychainCredentialStore()
        let authticator = InternalAuthenticator(ui: self.userConsentUI, credentialStore: store)
        
        self.webAuthnClient = WebAuthnClient(
            origin:        "https://\(rpId)",
            authenticator: authticator
        )
                
        var options = PublicKeyCredentialRequestOptions()
        options.challenge = Util.stringEncodeToUInt8Array(challenge)
        options.rpId = rpId

        switch userVerification {
        case "required":
            options.userVerification = UserVerificationRequirement.required
            break
        case "preferred":
            options.userVerification = UserVerificationRequirement.preferred
            break
        case "discouraged":
            options.userVerification = UserVerificationRequirement.discouraged
            break
        default:
            options.userVerification = UserVerificationRequirement.required
            break
        }
        
//        if let credId = "IpLHNefCR_mE9pykGeA5jQ" {
//            if !credId.isEmpty {
//                var base64Encoded = credId.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
//
//                let remainder = base64Encoded.count % 4
//                if remainder > 0 {
//                    base64Encoded = base64Encoded.padding(toLength: base64Encoded.count + 4 - remainder,
//                                                  withPad: "=",
//                                                  startingAt: 0)
//                }
//
//                var array:  [UInt8] = []
//                if let decodedData = Data(base64Encoded: base64Encoded) {
//                    array=[UInt8](decodedData)
//                }
//
//                options.addAllowCredential(
//                    credentialId: array,
//                    transports:   [.internal_]
//                )
//            }
//        }
        options.timeout = UInt64(timeout ?? 60000)
        
        //self.webAuthnClient.minTimeout = 5
        //self.webAuthnClient.defaultTimeout = 5

        firstly {
            
            self.webAuthnClient.get(options)
            
        }.done { assertion in
            
            let cid = assertion.id
            let rawId = Base64.encodeBase64URL(assertion.rawId)
            let attData = Base64.encodeBase64URL(assertion.response.authenticatorData)
            let clientData = Base64.encodeBase64URL(assertion.response.clientDataJSON.data(using: .utf8)!)
            let sig = Base64.encodeBase64URL(assertion.response.signature)
            let userHandle = Base64.encodeBase64URL(assertion.response.userHandle!)
            
//            store.deleteAllCredentialSources(rpId: rpId, userHandle: assertion.response.userHandle!)
            
            AuthClient().webauthnAuthentication(ticket: ticket ?? "", credentialId: cid, rawId: rawId, authenticatorData: attData, userHandle: userHandle, clientDataJSON: clientData, signature: sig, authenticatorAttachment: "platform") { code, message, res in
                if  let data = res?["data"] as? NSDictionary,
                    let verified = data["verified"] as? Bool,
                    verified == true,
                    let statusCode = res?["statusCode"] as? Int,
                    let tokenSet = data["tokenSet"] as? NSDictionary,
                    statusCode == 200 {
                    DispatchQueue.main.async() {
                        
                        let user = UserInfo()
                        user.parse(data: tokenSet)
                        Authing.saveUser(user)
                        
                        AuthClient().getCurrentUser(user: user) { [weak self] code, message, user in
                            if code == 200 {
                                DispatchQueue.main.async() {
                                    self?.authViewController?.authFlow?.complete(200, "", user)
                                }
                            } else {
                                Toast.show(text: message ?? "")
                            }
                        }
                    }
                } else {
                    Toast.show(text: res?["message"] as? String ?? "")
                }
            }

        }.catch { error in
            if let err = error as? WebAuthn.WAKError {
                if err == WAKError.notAllowed {
                    let vc = AuthViewController(nibName: "AuthingBindingWebAuthn", bundle: Bundle(for: Self.self))
                    vc.title = "authing_binding_account".L
                    vc.authFlow = self.authViewController?.authFlow?.copy() as? AuthFlow
                    self.authViewController?.navigationController?.pushViewController(vc, animated: true)
                } else if err == WAKError.cancelled {
                    
                } else {
                    Toast.show(text: "\(error)")
                }
            }
        }
    }
}
