//
//  WeComLoginButton.swift
//  Guard
//
//  Created by JnMars on 2022/3/23.
//

import Foundation

open class WeComLoginButton: SocialLoginButton {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        setBackgroundImage(UIImage(named: "authing_wecom", in: Bundle(for: WeComLoginButton.self), compatibleWith: nil), for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
        
        
        NotificationCenter.addObserver(self, selector: #selector(self.weComLoginComplete(notification:)), name: .notify_wecom_Receive, object: nil)
    }
    
    @objc private func onClick(sender: UIButton) {
        
        NotificationCenter.post(name: .notify_wecom_register, object: nil, userInfo: nil)

        loading?.startAnimating()
        
    }
    
    @objc func weComLoginComplete(notification: Notification) {
        let dic = notification.object as? [ String : Any ]
        if let code = dic?["code"]  as? Int, let msg = dic?["msg"] as? String{
            self.loading?.stopAnimating()
            if (code == 200) {
                if let vc = self.viewController?.navigationController as? AuthNavigationController {
                    if let userInfo: UserInfo = dic?["userInfo"] as? UserInfo{
                        vc.complete(code, msg, userInfo)
                    } else {
                        Util.setError(self, "userInfo is nil")
                    }
                }else{
                    Util.setError(self, "code is nil")
                }
            } else {
                Util.setError(self, msg)
            }
        }
    }
}
