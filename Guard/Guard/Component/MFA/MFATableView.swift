//
//  MFATableView.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/10.
//

import UIKit

open class MFATableView: UIView {
    
    private let ITEM_HEIGHT: CGFloat = 74
    let tip = UILabel()
    
    let leftSep = UIView()
    let rightSep = UIView()


    let maskBackGroundView = UIView()
    let backGroundView = UIView()
    var itemArr: [MFATableItem] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        
        maskBackGroundView.backgroundColor = UIColor.black
        maskBackGroundView.alpha = 0.4
        addSubview(maskBackGroundView)
        sendSubviewToBack(maskBackGroundView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        maskBackGroundView.addGestureRecognizer(tap)
        
        backGroundView.backgroundColor = UIColor.white
        backGroundView.layer.cornerRadius = 14
        addSubview(backGroundView)

        leftSep.backgroundColor = Const.Color_Line_Gray
        addSubview(leftSep)
        
        tip.textColor = Const.Color_Text_Gray
        tip.font = UIFont.systemFont(ofSize: 12)
        tip.textAlignment = .center
        tip.text = NSLocalizedString("authing_mfa_other", bundle: Bundle(for: Self.self), comment: "")
        addSubview(tip)
        
        rightSep.backgroundColor = Const.Color_Line_Gray
        addSubview(rightSep)
        
        if let mfaPolicy = Authing.getCurrentUser()?.mfaPolicy {
            if mfaPolicy.count == 1 {
                self.isHidden = true
                return
            }
            for policy in mfaPolicy {
                let mfaItem: MFATableItem = MFATableItem()
                if (policy == "SMS") {
                    mfaItem.mfaType = .phone
                } else if (policy == "EMAIL") {
                    mfaItem.mfaType = .email
                } else if (policy == "OTP") {
                    mfaItem.mfaType = .totp
                } else if (policy == "FACE") {
                    mfaItem.mfaType = .face
                } else {
                    continue
                }
                addSubview(mfaItem)
                itemArr.append(mfaItem)
            }
        }
    }
    
    
    open override func layoutSubviews() {
        
        let backGroundViewOrignY = Const.SCREEN_HEIGHT - 200.0

        var i = 0, last: UIView? = nil
        for mfaItem in itemArr {
            
            if (mfaItem.mfaType?.rawValue == Authing.getCurrentUser()?.mfaPolicy?.first &&
                self.authViewController?.nibName == "AuthingMFAOptions") ||
                (mfaItem.mfaType == .phone &&
                 self.authViewController?.nibName == "AuthingMFAPhone1") ||
                (mfaItem.mfaType == .email &&
                 self.authViewController?.nibName == "AuthingMFAEmail1") ||
                (mfaItem.mfaType == .totp &&
                 self.authViewController?.nibName == "AuthingMFAOTP1") ||
                (mfaItem.mfaType == .face &&
                 self.viewController?.isKind(of: MFAFaceViewController.self) == true)
            {
                continue
            }
 
            var mfaItemX: CGFloat = 20
            if (i != 0) {
                mfaItemX = (last?.frame.origin.x ?? 0) + (last?.frame.size.width ?? 0) + 24.0
            }
            mfaItem.frame = CGRect(x: mfaItemX, y: backGroundViewOrignY + 48, width: ITEM_HEIGHT, height: ITEM_HEIGHT)

            last = mfaItem
            i += 1
        }
            
        let sepMargin = 12.0
        let sepWidth = 24.0
        let tipHeight = 50.0
        
        maskBackGroundView.frame = CGRect(x: 0, y: 0, width: Const.SCREEN_WIDTH, height: Const.SCREEN_HEIGHT)
        backGroundView.frame = CGRect(x: 0, y: backGroundViewOrignY, width: Const.SCREEN_WIDTH, height: 200)
        let tipW = tip.intrinsicContentSize.width
        let tipX = (frame.width - tipW) / 2
        leftSep.frame = CGRect(x: tipX - sepMargin - sepWidth, y: tipHeight / 2 + backGroundViewOrignY, width: sepWidth, height: 1)
        tip.frame = CGRect(x: tipX, y: backGroundViewOrignY, width: tipW, height: tipHeight)
        rightSep.frame = CGRect(x: tipX + tipW + sepMargin, y: tipHeight / 2 + backGroundViewOrignY, width: sepWidth, height: 1)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
}
