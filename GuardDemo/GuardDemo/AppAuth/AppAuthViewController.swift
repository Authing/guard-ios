//
//  AppAuthViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/11/23.
//

import Guard
import AppAuth
import AuthenticationServices

class AppAuthViewController: UIViewController {
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    let authorizationEndpoint = URL(string: "https://finclip.authing.cn/oidc/auth")!
    let tokenEndpoint = URL(string: "https://finclip.authing.cn/oidc/token")!
    let regEndpoint = URL(string: "https://finclip.authing.cn/oidc/reg")!
    let redirectURL = URL(string: "cn.guard://authing.cn/redirect")!
    let endPoint = URL(string: "https://oiv3h3.authing.cn/login/profile/logout")!
    var idToken: String = ""
    private var authState: OIDAuthState?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewDidLayoutSubviews() {
        self.tokenLabel.sizeToFit()
    }

    @IBAction func logout(_ sender: Any) {
        
        let config = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint, tokenEndpoint: tokenEndpoint, issuer:nil, registrationEndpoint: regEndpoint, endSessionEndpoint: endPoint)
                
        let logoutRequest = OIDEndSessionRequest(configuration: config, idTokenHint: idToken, postLogoutRedirectURL: redirectURL, additionalParameters: ["redirect_uri":"cn.guard://authing.cn/redirect"])
        
        logoutRequest.setValue(nil, forKey: "state")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        
        appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(logoutRequest, externalUserAgent: OIDExternalUserAgentIOS(presenting: self)!) { resp, err in
            print(resp as Any)
            print(err as Any)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint,
                                                    tokenEndpoint: tokenEndpoint)
        
        // builds authentication request
        let clientID = Authing.getAppId();
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail, OIDScopePhone, "username", "address", "offline_access", "roles","role", "extended_fields"],
                                              redirectURL: redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: ["prompt": "consent"])
        
        // performs authentication request
        print("Initiating authorization request with scope: \(request.scope ?? "nil")")

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        appDelegate.currentAuthorizationFlow =
            OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in
            if let authState = authState {
            //            self.setAuthState(authState)
                print("Got authorization tokens. Access token: " +
                  "\(authState.lastTokenResponse?.accessToken ?? "nil")")
                
                print("Refresh token: " +
                  "\(authState.lastTokenResponse?.refreshToken ?? "nil")")
                
                print("ID Token: " +
                      "\(authState.lastTokenResponse?.idToken ?? "nil")")
                self.idToken = authState.lastTokenResponse?.accessToken ?? ""
                
                self.tokenLabel.text = authState.lastTokenResponse?.accessToken
                
                
//                self.navigationController?.present(AuthView.init() , animated: true, completion: nil)
                
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
            //            self.setAuthState(nil)
                self.tokenLabel.text = "\(error?.localizedDescription ?? "Unknown error")"
            }
        }
    }
}

//@available(iOS 12.0, *)
//class AuthView: UIViewController {
//
//    var authSession: ASWebAuthenticationSession!
//
//    override func viewDidLoad() {
//      super.viewDidLoad()
//        if #available(iOS 13.0, *) {
//            configureAuthSession()
//        }
//    }
//
//    @available(iOS 13.0, *)
//    private func configureAuthSession() {
//        let urlString = "https://oiv3h3.authing.cn/u?app_id=6244398c8a4575cdb2cb5656"
//        guard let url = URL(string: urlString) else { return }
//        let callbackScheme = ""
//        authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme)
//        { (callbackURL, error) in
//            guard error == nil, let successURL = callbackURL else { return }
//            _ = NSURLComponents(string: (successURL.absoluteString))?.queryItems?.filter({ $0.name == "code" }).first
//        }
//        authSession.presentationContextProvider = self
//        authSession.start()
//    }
//}
//
//@available(iOS 12.0, *)
//extension AuthView: ASWebAuthenticationPresentationContextProviding {
//
//    @available(iOS 12.0, *)
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        return self.view.window ?? ASPresentationAnchor()
//    }
//}
