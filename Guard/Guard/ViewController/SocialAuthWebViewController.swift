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
    private let loading = UIActivityIndicatorView()
    public var authResponse: ((_ success: Bool, _ authCode: String, _ error: Error?) -> Void)?
    
    class public func register(appId: String, scope: String, host: String, _ redirectURI: String? = nil) -> SocialAuthWebViewController {
        let web = SocialAuthWebViewController.init()
        web.appId = appId
        web.redirectURI = redirectURI
        web.scope = scope
        web.host = host
        return web
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView?.navigationDelegate = self
        view = webView
        
         if let redirect = self.buildAuthorizeUrl() {
            self.webView?.load(URLRequest(url: redirect))
            self.webView?.allowsBackForwardNavigationGestures = true
            self.loading.frame = CGRect(x: Const.SCREEN_WIDTH/2 - 50, y: Const.SCREEN_HEIGHT/2 - 50, width: 100, height: 100)
            self.loading.style = .gray
            self.webView?.addSubview(self.loading)
            self.loading.startAnimating()
         } else {
             ALog.e(SocialAuthWebViewController.self, "social auth webview get config failed.")
         }
        
        let cancelButton = UIButton.init(frame: CGRect(x: 10, y: 10, width: 60, height: 40))
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitle("authing_cancel".L, for: .normal)
        cancelButton.setTitleColor(UIColor.init(red: 0.11, green: 0.13, blue: 0.16, alpha: 1.0), for: .normal)
        cancelButton.addTarget(self, action:#selector(cancelClick(sender:)), for: .touchUpInside)
        self.view.addSubview(cancelButton)
    }
    
    @objc func cancelClick(sender: UIButton) {
        self.authResponse?(false, "authing_cancel".L, nil)
        self.dismiss(animated: true)
    }
    
    func buildAuthorizeUrl() -> URL? {
        var url = self.host + "/oauth/authorize?"
        let clientId = "&client_id=" + self.appId
        if self.redirectURI == nil {
            self.redirectURI = Authing.getConfigObject()?.redirectUris?.first ?? ""
        }
        let redirect = "&redirect_uri=" + (self.redirectURI ?? "")
        let scope = "&scope=" + (self.scope.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")

        url = url + clientId + redirect + scope + "&response_type=code"
        return URL(string: url)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {

            if url.absoluteString.hasPrefix(self.redirectURI!) {
                if let authCode = Util.getQueryStringParameter(url: url, param: "code") {
                    ALog.d(SocialAuthWebViewController.self, authCode)
                    self.authResponse?(true, authCode, nil)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loading.stopAnimating()
        if let url = webView.url{
            ALog.e(SocialAuthWebViewController.self, "didFinish: \(url)")
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.authResponse?(false, "", error)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.authResponse?(false, "", error)
    }

}

