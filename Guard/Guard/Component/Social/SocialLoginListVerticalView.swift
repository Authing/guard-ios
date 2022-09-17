//
//  SocialLoginListVerticalView.swift
//  Guard
//
//  Created by JnMars on 2022/9/18.
//

import Foundation

class SocialLoginListVerticalView: UIView, AttributedViewProtocol {
    
    let socialButtonWidth = Const.SCREEN_WIDTH - 48
    let socialButtonHeight = CGFloat(44)
    let scrollView = UIScrollView()
    
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
        
        isHidden = true
    
        self.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            
        Util.getConfig(self) { config in
            if (self.src != "auto") {
                return
            }
            
            let src = SocialLoginListView.srcSort(config: config)
            SocialLoginListView.handleSrc(container: self.scrollView, src, true)
            
            self.layoutSubviews()
        }

    }
    
    override func layoutSubviews() {
        
        var i = 0

        for v in self.scrollView.subviews {
            if v as? SocialLoginButton != nil {
                v.frame = CGRect(x: 0, y: (socialButtonHeight + 12) * CGFloat(i), width: socialButtonWidth, height: socialButtonHeight)
                v.backgroundColor = Const.Color_BG_Text_Box
                v.layer.cornerRadius = 4
                v.clipsToBounds = true
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
        
        SocialLoginListView.handleSrc(container: self.scrollView, srcs, true)
    }
    
}
