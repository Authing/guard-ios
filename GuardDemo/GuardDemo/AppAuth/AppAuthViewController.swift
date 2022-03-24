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
    
    let authorizationEndpoint = URL(string: "https://lrb31s-demo.authing.cn/oidc/auth")!
    let tokenEndpoint = URL(string: "https://lrb31s-demo.authing.cn/oidc/token")!
    let redirectURL: URL? = URL(string: "cn.guard://authing.cn/redirect");
    
    private var authState: OIDAuthState?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewDidLayoutSubviews() {
        self.tokenLabel.sizeToFit()
    }

    override func viewDidAppear(_ animated: Bool) {
        let configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint,
                                                    tokenEndpoint: tokenEndpoint)
        
        // builds authentication request
        let clientID = Authing.getAppId();
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail, OIDScopePhone, "offline_access", "role"],
                                              redirectURL: redirectURL!,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        // performs authentication request
        print("Initiating authorization request with scope: \(request.scope ?? "nil")")

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        appDelegate.currentAuthorizationFlow =
            OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in
            if let authState = authState {
            //            self.setAuthState(authState)
                print("Got authorization tokens. Access token: " +
                  "\(authState.lastTokenResponse?.accessToken ?? "nil")")
                self.tokenLabel.text = authState.lastTokenResponse?.accessToken
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
            //            self.setAuthState(nil)
                self.tokenLabel.text = "\(error?.localizedDescription ?? "Unknown error")"
            }
        }
    }

}
