//
//  AlipayButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/5.
//

import UIKit

open class AlipayButton: UIButton {
    
    public static var appid: String? = nil
    public static var customScheme: String? = nil
    
    public
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        setBackgroundImage(UIImage(named: "authing_alipay", in: Bundle(for: WechatButton.self), compatibleWith: nil), for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.alipayLoginOK(notification:)), name: Notification.Name("alipayLoginOK"), object: nil)
    }
    
    @objc private func onClick(sender: UIButton) {
        guard AlipayButton.appid != nil && AlipayButton.customScheme != nil else {
            print("Alipay error appid and customScheme cannot be empty")
            return
        }
        
        let param = [kAFServiceOptionBizParams:["url": "https://authweb.alipay.com/auth?auth_type=PURE_OAUTH_SDK&app_id=\(AlipayButton.appid!)&scope=auth_user&state=init"],
                kAFServiceOptionCallbackScheme:AlipayButton.customScheme!] as [String : Any]
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
//            self.stopLoading()
            if (code == 200) {
                DispatchQueue.main.async() {
                    let vc = self.viewController?.navigationController as? AuthNavigationController
                    if (vc == nil) {
                        return
                    }
                    
                    vc?.complete(userInfo)
                }
            } else {
                Util.setError(self, message)
            }
        }
    }
}
