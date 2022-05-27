//
//  WebViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2022/3/2.
//

import UIKit
import WebKit
import Guard

class WebViewController: AuthViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView? = nil
    let authRequest = AuthRequest()
    
    override func viewDidLoad() {
                
        let configuration = WKWebViewConfiguration()
        let log = """
                    console.log = (function(oriLogFunc){
                            return function(str){
                                        oriLogFunc.call(console,str);
                                        window.webkit.messageHandlers.log.postMessage(str);
                                    }
                            })(console.log);
                """
        let script = WKUserScript.init(source: log, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(self, name: "log")
        configuration.suppressesIncrementalRendering = true

        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        configuration.preferences = preferences

        webView = WKWebView(frame: .zero, configuration: configuration)
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
        if let url = navigationAction.request.url {
            print("shouldOverrideUrlLoading: \(url)")
            if let uuid = Util.getQueryStringParameter(url: url, param: "uuid") {
                authRequest.uuid = uuid
            }
            
            if url.absoluteString.hasPrefix(authRequest.redirect_uri) {
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
                return
            
            } else if url.lastPathComponent == "authz" && authRequest.uuid != nil {
                if self.authFlow?.skipConsent == true {
                    self.skipConsent(url: url)
                    decisionHandler(.allow)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url{
            print("didFinish: \(url)")
        
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//                self.webView?.load(URLRequest(url: url))
//            }
        }
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if error._domain == "WebKitErrorDomain" {
            if let info = error._userInfo as? [String: Any] {
                if let url = info["NSErrorFailingURLKey"] as? URL {
                    self.handleAuthCode(url: url)
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if error._domain == "WebKitErrorDomain" {
            if let info = error._userInfo as? [String: Any] {
                if let url = info["NSErrorFailingURLKey"] as? URL {
                    self.handleAuthCode(url: url)
                }
            }
        }
    }
    
    private func handleAuthCode(url: URL) {
        if url.absoluteString.hasPrefix(authRequest.redirect_uri) {
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
        }
    }
    
    private func skipConsent(url: URL) {
                
        let urlString = "\(url.scheme ?? "")://\(url.host ?? "")/interaction/oidc/\(authRequest.uuid ?? "")/confirm"
        let body = authRequest.getScopesAsConsentBody()
        
        let js =
        """
            (function f(){
                var xhr = new XMLHttpRequest();
                console.log('executing skipping js');
                xhr.open('POST', '\(urlString)', false);
                xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded;  charset=utf-8');
                xhr.onload = function() {
                    console.log('status=' + xhr.status + ' responseURL=' + xhr.responseURL);
                    if (xhr.status === 200) {
                        window.location.href = xhr.responseURL;
                    }
                };
                xhr.onerror = function(e) {
                    console.log('error=' + JSON.stringify(request));
                };
                xhr.onreadystatechange = function(e) {
                    if(xhr.readyState == 4 && xhr.status == 200) {
                        alert(xhr.responseText);
                    }else{
                        console.log('readyState=' + xhr.readyState + ' status=' + xhr.status + ' error=' + e);
                    }
                }
                xhr.send('\(body)');
            })()
        """
        
        print(js)

        self.webView?.evaluateJavaScript(js, completionHandler: nil)
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        print("userContentController: \(message.body)")
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
