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
        

        authRequest.redirect_uri = "cn.guard://authing.cn/redirect"
        OIDCClient().buildAuthorizeUrl(authRequest: authRequest) { url in
            if url != nil {
                self.webView?.load(URLRequest(url: url!))
                self.webView?.allowsBackForwardNavigationGestures = true
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
                url.absoluteString.hasPrefix(authRequest.redirect_uri) == true else {
            decisionHandler(.allow)
            return
        }
        
        if let authCode = Util.getQueryStringParameter(url: url, param: "code") {
            OIDCClient().authByCode(code: authCode, authRequest: authRequest) { code, message, userInfo in
                if (code == 200) {
                    OIDCClient().getNewAccessTokenByRefreshToken(userInfo: userInfo) { code, message, userInfo in
                        print("\(userInfo?.accessToken ?? "")")
                        print("\(userInfo?.idToken ?? "")")
                        print("\(userInfo?.refreshToken ?? "")")
                        self.goHome()
                    }
                }
            }
        }
        decisionHandler(.cancel)
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
