//
//  WebViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2022/3/2.
//

import UIKit
import WebKit
import Guard

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView? = nil
    let authRequest = AuthRequest()
    override func viewDidLoad() {
        webView = WKWebView()
        webView?.navigationDelegate = self
        view = webView
        
        
        OIDCClient.buildAuthorizeUrl(authRequest: authRequest) { url in
            if url != nil {
                self.webView?.load(URLRequest(url: url!))
                self.webView?.allowsBackForwardNavigationGestures = true
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString.hasPrefix(authRequest.redirect_uri) == true {
                if let authCode = Util.getQueryStringParameter(url: url, param: "code") {
                    OIDCClient.authByCode(code: authCode, authRequest: authRequest) { code, message, userInfo in
                        if (code == 200) {
                            OIDCClient.getNewAccessTokenByRefreshToken(userInfo: userInfo, authRequest: self.authRequest) { code, message, userInfo in
                                self.goHome()
                            }
                        }
                    }
                }
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    private func goHome() {
        DispatchQueue.main.async() {
            let vc = MainViewController(nibName: "AuthingUserProfile", bundle: Bundle(for: UserProfileViewController.self))
            let keyWindow = UIApplication.shared.windows.first
            let nav: UINavigationController = UINavigationController(rootViewController: vc)
            keyWindow?.rootViewController = nav
        }
    }
}
