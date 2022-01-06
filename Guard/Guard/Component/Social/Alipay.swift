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
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.alipayLoginOK(notification:)), name: Notification.Name("alipayLoginOK"), object: nil)
    }
    
    func login(_ completion: @escaping AuthCallback) {
        guard Alipay.appid != nil && Alipay.customScheme != nil else {
            print("Alipay error appid and customScheme cannot be empty")
            return
        }
        
        callback = completion
        
        let param = [kAFServiceOptionBizParams:["url": "https://authweb.alipay.com/auth?auth_type=PURE_OAUTH_SDK&app_id=\(Alipay.appid!)&scope=auth_user&state=init"],
                kAFServiceOptionCallbackScheme:Alipay.customScheme!] as [String : Any]
        AFServiceCenter.call(AFService.auth, withParams: param, andCompletion: nil)
    }
    
    @objc func alipayLoginOK(notification: Notification) {
        let url = notification.object as! URL
        let urlS = url.absoluteString
        let idx = urlS.firstIndex(of: "?")
        guard idx != nil else {
            return
        }
        let idx1 = urlS.index(idx!, offsetBy: 1)
        let code = urlS.suffix(from: idx1)
        print(code)
        
        AuthClient.loginByAlipay(String(code)) { code, message, userInfo in
            guard self.callback != nil else {
                return
            }
            self.callback!(code, message, userInfo)
        }
    }
}
