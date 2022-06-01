//
//  CountryCodeView.swift
//  Guard
//
//  Created by JnMars on 2022/5/31.
//

import Foundation
import UIKit

typealias CountryCodeUpdateBlock = (_ code: String) -> Void

class CountryCodeView: UIView {
    
    var countryCodeButton = UIButton()
    var pullDownImageView = UIImageView()
    var countryCodeUpdateCallBack: CountryCodeUpdateBlock?
        
    public var countryCode: String = "+86" {
        didSet {
            self.updateContryCode(countryCode: countryCode)
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
        
        countryCodeButton.setTitle(countryCode, for: .normal)
        countryCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        countryCodeButton.contentHorizontalAlignment = .left
        countryCodeButton.setTitleColor(UIColor.black, for: .normal)
        countryCodeButton.addTarget(self, action: #selector(countryCodeButtonAction), for: .touchUpInside)
        self.addSubview(countryCodeButton)
        
        pullDownImageView.image = UIImage.init(named: "authing_down", in: Bundle(for: Self.self), compatibleWith: nil)
        pullDownImageView.contentMode = .scaleAspectFit
        self.addSubview(pullDownImageView)
        
    }
    
    public func updateContryCode(countryCode: String) {
        
        countryCodeButton.setTitle(countryCode, for: .normal)
         
        let countryCodeButtonWidth: CGFloat = textWidth(text: countryCode, font: UIFont.systemFont(ofSize: 14))
        countryCodeButton.frame = CGRect(x: 8, y: 0, width: countryCodeButtonWidth, height: self.frame.height)
        pullDownImageView.frame = CGRect(x: 16 + countryCodeButtonWidth, y: 0, width: 8, height: self.frame.height)
        
        self.countryCodeUpdateCallBack?(countryCode)
    }
    
    public func getWidth() -> CGFloat{
        
        let countryCodeButtonWidth: CGFloat = CGFloat(countryCode.count * 10)

        return 16 + countryCodeButtonWidth + 8
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateContryCode(countryCode: self.countryCode)
    }
    

    @objc func countryCodeButtonAction() {
        let countryCodeVC = CountryCodeViewController(nibName: "AuthingCountryCode", bundle: Bundle(for: CountryCodeViewController.self))
        countryCodeVC.modalPresentationStyle = .fullScreen
        countryCodeVC.selectCountryCallBack = { model in
            self.countryCode = "+\(model.code ?? 86)"
        }
        self.viewController?.present(countryCodeVC, animated: true)
    }
    
    
    public func textWidth(text: String, font: UIFont) -> CGFloat {
        let size = CGSize(width: CGFloat(MAXFLOAT), height: self.frame.height)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize:CGRect = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return labelSize.width
    }
}
