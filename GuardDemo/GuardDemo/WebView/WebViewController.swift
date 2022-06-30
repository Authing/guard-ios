//
//  WebViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2022/3/2.
//

import WebKit
import Guard

class WebViewController: AuthViewController, WKNavigationDelegate {
    
    var webView: WKWebView? = nil
    let authRequest = AuthRequest()
    
    override func viewDidLoad() {
                
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView?.navigationDelegate = self
        view = webView
        
        authRequest.redirect_uri = "cn.guard://authing.cn/redirect"

        OIDCClient(authRequest).buildAuthorizeUrl() { url in
            if url != nil {
                self.webView?.load(URLRequest(url: url!))
                self.webView?.allowsBackForwardNavigationGestures = true
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            print("shouldOverrideUrlLoading: \(url)")
            if let uuid = Util.getQueryStringParameter(url: url, param: "uuid") {
                authRequest.uuid = uuid
            }
            
            if url.absoluteString.hasPrefix(authRequest.redirect_uri) {
                if let authCode = Util.getQueryStringParameter(url: url, param: "code") {
                    OIDCClient(authRequest).authByCode(code: authCode) { code, message, userInfo in
                        if (code == 200) {
                            OIDCClient().getNewAccessTokenByRefreshToken(userInfo: userInfo) { code, message, userInfo in
                                print("\(userInfo?.accessToken ?? "")")
                                print("\(userInfo?.idToken ?? "")")
                                print("\(userInfo?.refreshToken ?? "")")
                                self.goHome()
                            }
                        }
                    }
                    decisionHandler(.cancel)

                    return
                }
            }
        }
        decisionHandler(.allow)
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url{
            print("didFinish: \(url)")
        }
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
