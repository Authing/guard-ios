//
//  Alipay.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/6.
//

import Foundation

open class Alipay {
    
    var callback: AuthCallback? = nil
    
    public static var appid: String? = nil
    public static var customScheme: String? = nil
    
    func login(_ completion: @escaping AuthCallback) {
        guard Alipay.appid != nil && Alipay.customScheme != nil else {
            print("Alipay error appid and customScheme cannot be empty")
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.alipayLoginOK(notification:)), name: Notification.Name("alipayLoginOK"), object: nil)
        
        callback = completion
        
        let param = [kAFServiceOptionBizParams:["url": "https://authweb.alipay.com/auth?auth_type=PURE_OAUTH_SDK&app_id=\(Alipay.appid!)&scope=auth_user&state=init"],
                kAFServiceOptionCallbackScheme:Alipay.customScheme!] as [String : Any]
        AFServiceCenter.call(AFService.auth, withParams: param, andCompletion: nil)
    }
    
    @objc func alipayLoginOK(notification: Notification) {
        // has to manually remove it. don't trust the doc which says observer will be removed automatically
        NotificationCenter.default.removeObserver(self)
        
        let url = notification.object as? URL

        // only call it twice can trigger callback
        AFServiceCenter.handleResponseURL(url) { resp in
        }
        
        AFServiceCenter.handleResponseURL(url) { resp in
            if let data = resp?.result {
                if let code = data["auth_code"] as? String {
                    // sleep. otherwise will sometimes get -1005
                    // guess it's due to background networking
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        AuthClient.loginByAlipay(code) { code, message, userInfo in
                            guard self.callback != nil else {
                                return
                            }
                            self.callback!(code, message, userInfo)
                        }
                    }
                }
            }
        }
    }
}
