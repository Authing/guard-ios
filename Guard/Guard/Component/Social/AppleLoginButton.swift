//
//  AppleLoginButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/6.
//

import UIKit
import AuthenticationServices

@available(iOS 13.0, *)
open class AppleLoginButton: SocialLoginButton, ASAuthorizationControllerDelegate {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        setBackgroundImage(UIImage(named: "authing_apple", in: Bundle(for: AppleLoginButton.self), compatibleWith: nil), for: .normal)
        self.addTarget(self, action: #selector(onClick), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
        startLoading()
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            if let authorizationCode = String(bytes: appleIDCredential.authorizationCode!, encoding: .utf8) {
                Util.getAuthClient(self).loginByApple(authorizationCode) { code, message, userInfo in
                    DispatchQueue.main.async() {
                        self.stopLoading()
                        if (code == 200) {
                            if let vc = self.authViewController?.navigationController as? AuthNavigationController {
                                vc.complete(code, message, userInfo)
                            }
                        } else {
                            Util.setError(self, message)
                        }
                    }
                }
            } else {
                Util.setError(self, "apple auth code not a valid UTF-8 sequence")
            }
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        stopLoading()
        if let err = error as? ASAuthorizationError {
            switch err.code {
                case .canceled:
                return
            default:
                Util.setError(self, "Sign in with apple failed")
                return
            }
        }
    }
}
