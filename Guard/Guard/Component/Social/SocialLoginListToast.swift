//
//  SocialLoginListToast.swift
//  Guard
//
//  Created by JnMars on 2022/9/18.
//

import Foundation

class SocialLoginListToast: UIView {
    
    var src: Array<String> = []
    var backGroundView: UIView!
    var backGroundMask: UIView!
    
    let tip = UILabel()
    let tipHeight = 57.0
    let tipGap = 16.0
    
    let leftSep = UIView()
    let rightSep = UIView()
    let sepMargin = 12.0
    let sepWidth = 24.0
    
    let privacy = PrivacyConfirmBox.init()
    
    let socialButtonWidth = CGFloat(48)
    let socialButtonHeight = CGFloat(48)
    let buttonViewHeight: CGFloat = 68.0
    var backGroundHeight: CGFloat = 0
    
    class func show(viewController: AuthViewController, src: Array<String>) {
        let toast = SocialLoginListToast.init(frame: CGRect(x: 0, y: 0, width: Const.SCREEN_WIDTH, height: Const.SCREEN_HEIGHT))
        toast.alpha = 0
        toast.src = src
        toast.setup()
        viewController.view.addSubview(toast)
        
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        backGroundMask = UIView.init(frame: CGRect(x: 0, y: 0, width: Const.SCREEN_WIDTH, height: Const.SCREEN_HEIGHT))
        backGroundMask.backgroundColor = UIColor.black
        backGroundMask.alpha = 0.3
        self.addSubview(backGroundMask)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        backGroundMask.addGestureRecognizer(tap)
                
        let lines = self.src.count / 4 + 1
        
        backGroundHeight = CGFloat(lines) * (buttonViewHeight + 17) + 57
        
        backGroundView = UIView.init(frame: CGRect(x: 0, y: Const.SCREEN_HEIGHT, width: Const.SCREEN_WIDTH, height: backGroundHeight))
        backGroundView.backgroundColor = UIColor.white
        backGroundView.layer.cornerRadius = 4
        self.addSubview(backGroundView)
        
        SocialLoginListView.handleSrc(container: self.backGroundView, self.src, true)
        
        leftSep.backgroundColor = Const.Color_Line_Gray
        backGroundView.addSubview(leftSep)
        
        tip.textColor = Const.Color_Text_Gray
        tip.font = UIFont.systemFont(ofSize: 12)
        tip.textAlignment = .center
        tip.text = NSLocalizedString("authing_social_login", bundle: Bundle(for: Self.self), comment: "")
        backGroundView.addSubview(tip)
        
        rightSep.backgroundColor = Const.Color_Line_Gray
        backGroundView.addSubview(rightSep)
        
        backGroundView.addSubview(privacy)

        UIView.animate(withDuration: 0.3) {
            self.backGroundView.frame = CGRect(x: 0, y: Const.SCREEN_HEIGHT - self.backGroundHeight, width: Const.SCREEN_WIDTH, height: self.backGroundHeight)
        }
        
        self.layoutSubviews()
        
    }
    
    override func layoutSubviews() {
        let tipW = tip.intrinsicContentSize.width
        let tipX = (frame.width - tipW) / 2
        leftSep.frame = CGRect(x: tipX - sepMargin - sepWidth, y: tipHeight / 2, width: sepWidth, height: 1)
        tip.frame = CGRect(x: tipX, y: 0, width: tipW, height: tipHeight)
        rightSep.frame = CGRect(x: tipX + tipW + sepMargin, y: tipHeight / 2, width: sepWidth, height: 1)
        privacy.frame = CGRect(x: 54, y: self.backGroundHeight - 40, width: Const.SCREEN_WIDTH - 108, height: 20)
        var count = 0.0
        for v in self.backGroundView.subviews {
            if v as? SocialLoginButton != nil {
                count += 1
            }
        }
        let paddingH = (Const.SCREEN_WIDTH - (socialButtonWidth * 4) - 108) / 3
        var i = 0
        for v in self.backGroundView.subviews {
            if let button = v as? SocialLoginButton {
                button.frame = CGRect(x:  54 + (socialButtonWidth + paddingH) * CGFloat(i - 4 * (i / 4)), y: tipHeight + (socialButtonHeight + 16) * CGFloat(i / 4), width: socialButtonWidth, height: socialButtonHeight)

                button.backgroundColor = Const.Color_BG_Text_Box
                button.layer.cornerRadius = 4
                button.clipsToBounds = true
                button.setTitle("", for: .normal)
                i += 1
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.backGroundView.frame = CGRect(x: 0, y: Const.SCREEN_HEIGHT, width: Const.SCREEN_WIDTH, height: self.backGroundView.frame.height)
            self.backGroundMask.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    
}
