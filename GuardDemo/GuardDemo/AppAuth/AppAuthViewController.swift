//
//  AppAuthViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/11/23.
//

import Foundation
import Guard
import AppAuth

class AppAuthViewController: UIViewController {
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    let authorizationEndpoint = URL(string: "https://finclip.authing.cn/oidc/auth")!
    let tokenEndpoint = URL(string: "https://finclip.authing.cn/oidc/token")!
    let regEndpoint = URL(string: "https://finclip.authing.cn/oidc/reg")!
    let redirectURL = URL(string: "cn.guard://authing.cn/redirect")!
    let endPoint = URL(string: "https://oiv3h3.authing.cn/login/profile/logout")!
    var idToken: String!
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
        let logoutRequest = OIDEndSessionRequest(configuration: config, idTokenHint: self.idToken, postLogoutRedirectURL: redirectURL, additionalParameters: ["redirect_uri":"cn.guard://authing.cn/redirect"])
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(logoutRequest, externalUserAgent: OIDExternalUserAgentIOS(presenting: self)!) { resp, err in
            print(resp)
            print(err)
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
                self.idToken = authState.lastTokenResponse?.accessToken
                
                self.tokenLabel.text = authState.lastTokenResponse?.accessToken
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
            //            self.setAuthState(nil)
                self.tokenLabel.text = "\(error?.localizedDescription ?? "Unknown error")"
            }
        }
    }

}
