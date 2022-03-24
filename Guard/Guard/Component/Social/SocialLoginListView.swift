//
//  SocialLoginListView.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/28.
//

import UIKit

open class SocialLoginListView: UIView {
    
    let WIDTH = CGFloat(44)
    let HEIGHT = CGFloat(44)
    let SPACE = CGFloat(24)
    
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
        Util.getConfig(self) { config in
            if (self.src != "auto") {
                return
            }
            
            let connections: [NSDictionary]? = config?.data?["ecConnections"] as? [NSDictionary]
            if (connections == nil) {
                return
            }
            for conn in connections! {
                if let type = conn["type"] as? String {
                    if ("wechat:mobile" == type) {
                        self.addSubview(WechatLoginButton())
                    } else if ("wechatwork:mobile" == type) {
                        self.addSubview(WeComLoginButton())
                    } else if ("apple" == type) {
                        if #available(iOS 13.0, *) {
                            self.addSubview(AppleLoginButton())
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
            }
        }
    }
    
    open override func layoutSubviews() {
        let count = CGFloat(subviews.count)
        let paddingH = CGFloat((frame.width - count * WIDTH - (count - 1) * SPACE) / 2)
        let paddingV = CGFloat((frame.height - HEIGHT) / 2)
        var i = 0
        for v in subviews {
            v.frame = CGRect(x: paddingH + (WIDTH + SPACE) * CGFloat(i), y: paddingV, width: WIDTH, height: HEIGHT)
            i += 1
        }
    }
    
    open func setSource(_ src: String) {
        for v in subviews {
            v.removeFromSuperview()
        }
        
        if ("auto" == src) {
            setup()
            return
        }
        
        let srcs = src.split(separator: "|")
        for s in srcs {
            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if ("wechat" == trimmed) {
                self.addSubview(WechatLoginButton())
            } else if ("wecom" == trimmed) {
                self.addSubview(WeComLoginButton())
            }else if ("apple" == trimmed) {
                if #available(iOS 13.0, *) {
                    self.addSubview(AppleLoginButton())
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}
