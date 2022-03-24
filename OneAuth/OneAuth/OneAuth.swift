//
//  OneAuth.swift
//  OneAuth
//
//  Created by Lance Mao on 2021/12/15.
//

import Foundation
import Guard

open class OneAuth {
    
    public static var bizId: String?
    
    public static func start(_ vc: UIViewController, businessId: String? = nil, model: Any? = nil, completion: @escaping(Int, String?, UserInfo?)->Void) {
        if (businessId != nil) {
            bizId = businessId!
        }
        
        NTESQuickLoginManager.sharedInstance().register(withBusinessID: bizId!)
        NTESQuickLoginManager.sharedInstance().getPhoneNumberCompletion { result in
            let success: Bool = result["success"] as! Bool
            if (success) {
                let token: String? = result["token"] as? String
                Util.getConfig(vc.view) { config in
                    self.setCustomUI(config, vc, completion: completion)
                    self.startLogin(token, completion)
                }
            } else {
                let error: String = result["desc"] as! String
                print("Error oneauth getPhoneNumber \(error)")
                completion(500, error, nil)
            }
        }
    }
    
    static func setCustomUI(_ config: Config?, _ vc: UIViewController, completion: @escaping(Int, String?, UserInfo?)->Void) {
        let model: NTESQuickLoginModel = NTESQuickLoginModel()
        model.currentVC = vc
        if (vc.navigationController == nil) {
            model.navBarHidden = true
            model.presentDirectionType = NTESPresentDirection.present;
            model.authWindowPop = NTESAuthWindowPop.fullScreen;
        } else {
            model.presentDirectionType = NTESPresentDirection.push;
            model.navText = "Authing"
            model.navReturnImg = UIImage(named: "back", in: Bundle(for: OneAuth.self), compatibleWith: nil)!
        }
        
        model.privacyNavReturnImg = UIImage(named: "back", in: Bundle(for: OneAuth.self), compatibleWith: nil)!

        let offsetY: CGFloat = 100
        
        /// logo
        let url = URL(string: (config?.getLogoUrl())!)
        let data = try? Data(contentsOf: url! as URL)
        model.logoImg = UIImage(data: data!)!
        model.logoWidth = 52;
        model.logoHeight = 52;
        model.logoOffsetTopY = offsetY;
        model.logoHidden = false;

        /// 手机号码
//        model.numberFont = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        model.numberOffsetX = 0;
        model.numberHeight = 27;
        model.numberOffsetTopY = 100 + offsetY

        ///  品牌
//        model.brandFont = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        model.brandWidth = 200;
        model.brandBackgroundColor = UIColor.clear
        model.brandHeight = 20;
        model.brandOffsetX = 0;
        model.brandOffsetTopY = 150 + offsetY

            /// 登录按钮
//        model.logBtnTextFont = [UIFont systemFontOfSize:14];
        model.logBtnTextColor = UIColor.white
        model.logBtnText = "确定登录";
        model.logBtnRadius = 8;
        model.logBtnHeight = 44;
        model.logBtnOffsetTopY = 200 + offsetY
        model.startPoint = CGPoint(x:0, y:0.5);
        model.endPoint = CGPoint(x:1, y:0.5);
        model.logBtnUsableBGColor = Const.Color_Authing_Main

            /// 隐私协议
//        model.appPrivacyText = "登录即同意《默认》并授权《用户协议》和《隐私协议》获得本机号码";
//        model.appFPrivacyText = "《用户协议》";
        model.appPrivacyOriginBottomMargin = 50;
        model.shouldHiddenPrivacyMarks = true;
        model.protocolColor = Const.Color_Authing_Main
        model.uncheckedImg = UIImage(named: "unchecked", in: Bundle(for: OneAuth.self), compatibleWith: nil)!
        model.checkedImg = UIImage(named: "checked", in: Bundle(for: OneAuth.self), compatibleWith: nil)!
        model.checkboxWH = 11;
        model.privacyState = true;
        model.isOpenSwipeGesture = false;
//        model.privacyFont = [UIFont fontWithName:@"PingFangSC-Regular" size:11];
        model.statusBarStyle = UIStatusBarStyle.lightContent;

        let handler: OtherLoginMethodHandler = OtherLoginMethodHandler()
        handler.setCallback(completion: completion)
        let closeHandler = CloseButtonMethodHandler()
        closeHandler.setCallback(completion: completion)
        model.customViewBlock = { customView in
            let otherLoginButton: UIButton = UIButton()
            otherLoginButton.setTitle(NSLocalizedString("authing_other_login_methods", bundle: Bundle(for: Authing.self), comment: ""), for: .normal)
            otherLoginButton.setTitleColor(UIColor(white: 0.35, alpha: 1), for: .normal)
            otherLoginButton.backgroundColor = UIColor(white: 0.9, alpha: 1)
            otherLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                otherLoginButton.layer.cornerRadius = 10
            }
            otherLoginButton.addTarget(handler, action: #selector(OtherLoginMethodHandler.clicked), for: .touchUpInside)
            customView?.addSubview(otherLoginButton)
            
            otherLoginButton.translatesAutoresizingMaskIntoConstraints = false
            otherLoginButton.centerXAnchor.constraint(equalTo: customView!.centerXAnchor).isActive = true
            otherLoginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            otherLoginButton.leadingAnchor.constraint(equalTo: customView!.leadingAnchor, constant: 40).isActive = true
            otherLoginButton.trailingAnchor.constraint(equalTo: customView!.trailingAnchor, constant: -40).isActive = true
            otherLoginButton.topAnchor.constraint(equalTo: customView!.topAnchor, constant: 256 + offsetY).isActive = true
            
            if (vc.navigationController == nil) {
                let closeButton: UIButton = UIButton()
                let img = UIImage(named: "authing_close", in: Bundle(for: Authing.self), compatibleWith: nil)!
                closeButton.setBackgroundImage(img, for: .normal)
                closeButton.addTarget(closeHandler, action: #selector(CloseButtonMethodHandler.clicked), for: .touchUpInside)
                customView?.addSubview(closeButton)

                closeButton.translatesAutoresizingMaskIntoConstraints = false
                closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
                closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
                closeButton.leadingAnchor.constraint(equalTo: customView!.leadingAnchor, constant: 20).isActive = true
                closeButton.topAnchor.constraint(equalTo: customView!.topAnchor, constant: 44).isActive = true
            }
        }

        /**返回按钮点击事件回调*/
//        model.backActionBlock = ^{
//            NSLog(@"返回按钮点击");
//        };
//
//        /**登录按钮点击事件回调*/
//        model.loginActionBlock = ^{
//            NSLog(@"loginAction");
//        };
//
//        /**复选框点击事件回调*/
//        model.checkActionBlock = ^(BOOL isChecked) {
//            if (isChecked) {
//                //选中复选框;
//            } else {
//                //取消复选框;
//            }
//        };
//
//        /**协议点击事件回调*/
//        model.privacyActionBlock = ^(int privacyType) {
//            if (privacyType == 0) {
//                //点击默认协议
//            } else if (privacyType == 1) {
//                // 点击自定义第1个协议;
//            } else if (privacyType == 2) {
//                // 点击自定义第1个协议;
//            }
//        };
//
//        /**协议点击事件回调，不会跳转到默认的协议页面。开发者可以在回调里，自行跳转到自定义的协议页面*/
//        model.pageCustomBlock = ^{
//            // 跳转到自定义的控制器
//        };

        NTESQuickLoginManager.sharedInstance().setupModel(model)
    }
    
    private static func startLogin(_ token: String?, _ completion: @escaping(Int, String?, UserInfo?)->Void) {
        NTESQuickLoginManager.sharedInstance().cucmctAuthorizeLoginCompletion { result in
            let success: Bool = result["success"] as! Bool
            if (success) {
                let ak: String = result["accessToken"] as! String
                self.getAuthingToken(token!, ak, completion)
            } else {
                let error: String = result["desc"] as! String
                print("Error oneauth cucmctAuthorize \(error)")
                completion(500, error, nil)
            }
        }
    }
    
    private static func getAuthingToken(_ token: String, _ ak: String, _ completion: @escaping(Int, String?, UserInfo?)->Void) {
        AuthClient().loginByOneAuth(token: token, accessToken: ak) { code, message, userInfo in
            completion(code, message, userInfo)
        }
    }
    
    class OtherLoginMethodHandler {
        
        typealias Callback = (Int, String?, UserInfo?)->Void
        
        var callback: Callback?
        
        func setCallback(completion: @escaping(Callback)) {
            callback = completion
        }
        
        @objc func clicked() {
            AuthFlow().start { [weak self] code, message, userInfo in
                if (userInfo != nil && self?.callback != nil) {
                    self?.callback!(200, nil, userInfo)
                }
            }
        }
    }
    
    class CloseButtonMethodHandler {
        
        typealias Callback = (Int, String?, UserInfo?)->Void
        
        var callback: Callback?
        
        func setCallback(completion: @escaping(Callback)) {
            callback = completion
        }
        
        @objc func clicked() {
            NTESQuickLoginManager.sharedInstance().closeAuthController(nil)
            callback?(500, "canceled", nil)
        }
    }
}
