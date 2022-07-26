//
//  SocialLoginListView.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/28.
//

open class SocialLoginListView: UIView, AttributedViewProtocol {
    
    let tip = UILabel()
    let tipHeight = 32.0
    let tipGap = 32.0
    
    let leftSep = UIView()
    let rightSep = UIView()
    let sepMargin = 12.0
    let sepWidth = 24.0
    
    let container = UIView()
    let socialButtonWidth = CGFloat(44)
    let socialButtonHeight = CGFloat(44)
    let socialButtonSpace = CGFloat(24)

    @IBInspectable open var src: String = "auto" {
        didSet {
            setSource(src)
        }
    }
    
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
        
        leftSep.backgroundColor = getTipColor()
        addSubview(leftSep)
        
        tip.textColor = getTipColor()
        tip.font = UIFont.systemFont(ofSize: 14)
        tip.textAlignment = .center
        tip.text = NSLocalizedString("authing_social_login", bundle: Bundle(for: Self.self), comment: "")
        addSubview(tip)
        
        rightSep.backgroundColor = getTipColor()
        addSubview(rightSep)
        
        addSubview(container)
        
        Util.getConfig(self) { config in
            if (self.src != "auto") {
                return
            }
            
            if let connections: [NSDictionary] = config?.data?["ecConnections"] as? [NSDictionary] {
                var srcs: Array<String> = []
                for conn in connections {
                    if let type = conn["type"] as? String {
                        if ("wechat:mobile" == type) {
                            srcs.append("wechat")
                        } else if ("wechatwork:mobile" == type) {
                            srcs.append("wecom")
                        } else if ("apple" == type) {
                            srcs.append("apple")
                        } else if ("lark-internal" == type || "lark-public" == type) {
                            srcs.append(type)
                        }
                    }
                }
                
                self.handleSrc(srcs)
                
                self.layoutSubviews()
            }
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
                i += 1
            }
        }
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
        handleSrc(srcs)
    }
    
    private func handleSrc(_ srcs: Array<String>) {
        if srcs.count == 0 {
            isHidden = true
            return
        }
        
        isHidden = false
        
        for v in container.subviews {
            v.removeFromSuperview()
        }
        
        for s in srcs {
            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if ("wechat" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.Wechat")?.classNamed("Wechat.WechatLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    self.container.addSubview(view)
                }
            } else if ("wecom" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.WeCom")?.classNamed("WeCom.WeComLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    self.container.addSubview(view)
                }
            } else if ("lark-internal" == trimmed || "lark-public" == trimmed) {
                if let type = Bundle(identifier: "cn.authing.LarkLogin")?.classNamed("LarkLogin.LarkLoginButton") as? SocialLoginButton.Type {
                    let view = type.init()
                    self.container.addSubview(view)
                }
            }else if ("apple" == trimmed) {
                if #available(iOS 13.0, *) {
                    self.container.addSubview(AppleLoginButton())
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    private func getTipColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray4
        } else {
            return Const.Color_Text_Gray
        }
    }
}
