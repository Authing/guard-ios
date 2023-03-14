//
//  SocialAuthWebViewController.swift
//  Guard
//
//  Created by JnMars on 2023/3/14.
//

import Foundation
import WebKit

open class SocialAuthWebViewController: AuthViewController, WKNavigationDelegate {
    
    var webView: WKWebView? = nil
    private var appId: String!
    private var redirectURI: String?
    private var scope: String!
    private var host: String!
    
    class public func register(appId: String, scope: String, host: String, _ redirectURI: String? = nil) -> SocialAuthWebViewController {
        let web = SocialAuthWebViewController.init()
        web.appId = appId
        web.redirectURI = redirectURI
        web.scope = scope
        web.host = host
        return web
    }
    
    public override func viewDidLoad() {
                
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView?.navigationDelegate = self
        view = webView
        
        self.buildAuthorizeUrl { url in
            if let redirect = url {
                self.webView?.load(URLRequest(url: redirect))
                self.webView?.allowsBackForwardNavigationGestures = true
            } else {
                ALog.e(SocialAuthWebViewController.self, "social auth webview get config failed.")
            }
        }
        
    }
    
    func buildAuthorizeUrl(completion: @escaping (URL?) -> Void) {
        Authing.getConfig { config in
            if (config == nil) {
                completion(nil)
            } else {
                var url = "https://" + self.host + "/oauth/authorize?"
                let clientId = "&client_id=" + self.appId
                if self.redirectURI == nil {
                    self.redirectURI = config?.redirectUris?.first ?? ""
                }
                let redirect = "&redirect_uri=" + self.redirectURI!
                let scope = "&scope=" + (self.scope.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")

                url = url + clientId + redirect + scope + "&response_type=code"
                completion(URL(string: url))
            }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            
            if url.absoluteString.hasPrefix(self.redirectURI!) {
                if let authCode = Util.getQueryStringParameter(url: url, param: "code") {
                    print(authCode)
                    decisionHandler(.cancel)

                    return
                }
            }
        }
        decisionHandler(.allow)
    }
    
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url{
            print("didFinish: \(url)")
        }
    }
}

