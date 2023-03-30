//
//  SocialLoginListView.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/28.
//

import UIKit
import LocalAuthentication

open class SocialLoginListView: UIView, AttributedViewProtocol {
    
    let tip = UILabel()
    let tipHeight = 32.0
    let tipGap = 16.0
    
    let leftSep = UIView()
    let rightSep = UIView()
    let sepMargin = 12.0
    let sepWidth = 24.0
    
    let container = UIView()
    let socialButtonWidth = CGFloat(48)
    let socialButtonHeight = CGFloat(48)
    let socialButtonSpace = CGFloat(25)

    @IBInspectable open var src: String = "auto" {
        didSet {
            setSource(src)
        }
    }
    
    var srcArr: Array<String> = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        // hide until we get source
            
        isHidden = true
        
        leftSep.backgroundColor = Const.Color_Line_Gray
        addSubview(leftSep)
        
        tip.textColor = Const.Color_Text_Gray
        tip.font = UIFont.systemFont(ofSize: 12)
        tip.textAlignment = .center
        tip.text = NSLocalizedString("authing_social_login", bundle: Bundle(for: Self.self), comment: "")
        addSubview(tip)
        
        rightSep.backgroundColor = Const.Color_Line_Gray
        addSubview(rightSep)
        
        addSubview(container)
        
        Util.getConfig(self) { config in
            if (self.src != "auto") {
                return
            }
            
            self.srcArr = SocialLoginListView.srcSort(config: config)
            SocialLoginListView.handleSrc(container: self.container, self.srcArr)
            
            self.layoutSubviews()
        }
    }
    
    open override func layoutSubviews() {
        let tipW = tip.intrinsicContentSize.width
        let tipX = (frame.width - tipW) / 2
        leftSep.frame = CGRect(x: tipX - sepMargin - sepWidth, y: tipHeight / 2, width: sepWidth, height: 1)
        tip.frame = CGRect(x: tipX, y: 0, width: tipW, height: tipHeight)
        rightSep.frame = CGRect(x: tipX + tipW + sepMargin, y: tipHeight / 2, width: sepWidth, height: 1)
        container.frame = CGRect(x: 0, y: tipHeight + tipGap, width: frame.width, height: socialButtonHeight)

        var count = 0.0
        for v in container.subviews {
            if v as? SocialLoginButton != nil {
                count += 1
            }
        }
        let paddingH = (frame.width - count * socialButtonWidth - (count - 1) * socialButtonSpace) / 2
        var i = 0
        for v in container.subviews {
            if v as? SocialLoginButton != nil {
                v.frame = CGRect(x:  CGFloat(paddingH) + (socialButtonWidth + socialButtonSpace) * CGFloat(i), y: 0, width: socialButtonWidth, height: socialButtonHeight)
                v.backgroundColor = Const.Color_BG_Text_Box
                v.layer.cornerRadius = 4
                v.clipsToBounds = true
                i += 1
                
                if i == 4 {
                    (v as? SocialLoginButton)?.addTarget(self, action: #selector(moreButtonClick), for: .touchUpInside)
                }
            }
        }
    }
    
    @objc func moreButtonClick() {
        SocialLoginListToast.show(viewController: self.authViewController ?? AuthViewController(), src: self.srcArr)
    }
    
    open func setSource(_ src: String) {
        if ("auto" == src) {
            setup()
            return
        }
        
        var srcs: Array<String> = []
        for sub in src.split(separator: "|") {
            srcs.append(String(sub))
        }
        
        if srcs.count == 0 {
            isHidden = true
            return
        }
        
        isHidden = false
        
        SocialLoginListView.handleSrc(container: self.container, srcs)
    }
    
    class func srcSort(config: Config?) -> [String] {

        if let connections: [NSDictionary] = config?.data?["ecConnections"] as? [NSDictionary] {
            let srcs: NSMutableDictionary = [:]
            for conn in connections {
                if let type = conn["type"] as? String {
                    if ("wechat:mobile" == type) {
                        srcs.setValue("wechat", forKey: "1")
                    } else if ("wechat:miniprogram:app-launch" == type) {
                        srcs.setValue("miniprogram", forKey: "2")
                    } else if ("apple" == type) {
                        srcs.setValue("apple", forKey: "3")
                    } else if ("google:mobile" == type) {
                        srcs.setValue("google", forKey: "4")
                    } else if ("wechatwork:mobile" == type || "wechatwork:agency:mobile" == type) {
                        srcs.setValue("wecom", forKey: "5")
                    } else if ("lark-internal" == type || "lark-public" == type) {
                        srcs.setValue("lark", forKey: "6")
                    } else if ("facebook:mobile" == type) {
                        srcs.setValue("facebook", forKey: "7")
                    } else if ("qq:mobile" == type) {
                        srcs.setValue("qq", forKey: "8")
                    } else if ("weibo:mobile" == type) {
                        srcs.setValue("weibo", forKey: "9")
                    } else if ("baidu:mobile" == type) {
                        srcs.setValue("baidu", forKey: "10")
                    } else if ("linkedin:mobile" == type) {
                        srcs.setValue("linkedin", forKey: "11")
                    } else if ("dingtalk:mobile" == type) {
                        srcs.setValue("dingtalk", forKey: "12")
                    } else if ("douyin:mobile" == type) {
                        srcs.setValue("douyin", forKey: "13")
                    } else if ("github:mobile" == type) {
                        srcs.setValue("github", forKey: "14")
                    } else if ("gitee:mobile" == type) {
                        srcs.setValue("gitee", forKey: "15")
                    } else if ("kuaishou:mobile" == type) {
                        srcs.setValue("kuaishou", forKey: "16")
                    } else if ("xiaomi:mobile" == type) {
                        srcs.setValue("xiaomi", forKey: "17")
                    } else if ("gitlab:mobile" == type) {
                        srcs.setValue("gitlab", forKey: "18")
                    } else if ("line:mobile" == type) {
                        srcs.setValue("line", forKey: "19")
                    } else if ("slack:mobile" == type) {
                        srcs.setValue("slack", forKey: "20")
                    }
                }
            }
            
            var arrs: [String] = srcs.allKeys as? [String] ?? []
            var value: [String] = []
            arrs = arrs.sorted { a, b in
                return a < b
            }
            arrs.forEach { key in
                value.append(srcs[key] as? String ?? "")
            }
            
            if config?.enableFaceLogin == true && Util.isFullScreenIphone() == true {
                value.insert("face", at: 0)
            } else if config?.enableFingerprintLogin == true && Util.isFullScreenIphone() == false {
                value.insert("touch", at: 0)
            }
            
            return value
        }
        
        return []
    }
    
    class func handleSrc(container: UIView, _ sources: Array<String>, _ isVerticalLayout: Bool = false) {
        
        var srcs: Array<String> = sources
        
        if srcs.count == 0 {
            container.superview?.isHidden = true
            return
        }
        
        container.superview?.isHidden = false

        for v in container.subviews {
            v.removeFromSuperview()
        }
        
        if isVerticalLayout == false {
            if srcs.count > 3 {
                srcs.insert("more", at: 3)
                srcs = Array(srcs[0...3])
            }
        }
        
        for s in srcs {
            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if ("wechat" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Wechat")?.classNamed("Wechat.WechatLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_wechat".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("miniprogram" == trimmed) {
                                
                if let type = Bundle(identifier: "cn.authing.Wechat")?.classNamed("Wechat.MiniProgramLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_mini".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("wecom" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.WeCom")?.classNamed("WeCom.WeComLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_wecom".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("lark" == trimmed) {
                
                if let type = Bundle(identifier: "cn.authing.LarkLogin")?.classNamed("LarkLogin.LarkLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_lark".L, for: .normal)
                    }
                    container.addSubview(view)
                }
                
            }else if ("apple" == trimmed) {
                if #available(iOS 13.0, *) {
                    let view = AppleLoginButton()
                    if isVerticalLayout {
                        view.setTitle("authing_social_apple".L, for: .normal)
                    }
                    container.addSubview(view)
                } else {
                    // Fallback on earlier versions
                }
            } else if ("google" == trimmed) {
                
                if let type = Bundle(identifier: "cn.authing.Google")?.classNamed("Google.GoogleSignInButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_google".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("face" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.webauthn")?.classNamed("WebAuthn.BiometricLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("Authing_social_face".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("touch" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.webauthn")?.classNamed("WebAuthn.BiometricLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("Authing_social_touch".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("facebook" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Facebook")?.classNamed("Facebook.FacebookButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_facebook".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("qq" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Tencent")?.classNamed("Tencent.TencentLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_qq".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("weibo" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Weibo")?.classNamed("Weibo.WeiboLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_weibo".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("baidu" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Baidu")?.classNamed("Baidu.BaiduLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_baidu".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("linkedin" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Linkedin")?.classNamed("Linkedin.LinkedinLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_linkedin".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("dingtalk" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.DingTalk")?.classNamed("DingTalk.DingTalkLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_dingtalk".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("douyin" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Douyin")?.classNamed("Douyin.DouyinLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_douyin".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("github" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Github")?.classNamed("Github.GithubLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_github".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("gitee" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Gitee")?.classNamed("Gitee.GiteeLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_gitee".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("kuaishou" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Kuaishou")?.classNamed("Kuaishou.KuaishouLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_kuaishou".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("xiaomi" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Xiaomi")?.classNamed("Xiaomi.XiaomiLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_xiaomi".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("gitlab" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.GitLab")?.classNamed("GitLab.GitLabLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_gitlab".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("line" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Line")?.classNamed("Line.LineLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_line".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("slack" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Slack")?.classNamed("Slack.SlackLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    if isVerticalLayout {
                        view.setTitle("authing_social_slack".L, for: .normal)
                    }
                    container.addSubview(view)
                }
            } else if ("more" == trimmed) {
                let view = SocialLoginButton.init()
                view.setImage(UIImage(named: "authing_more", in: Bundle(for: SocialLoginListView.self), compatibleWith: nil), for: .normal)
                container.addSubview(view) 
            }
        }
    }
    

}
