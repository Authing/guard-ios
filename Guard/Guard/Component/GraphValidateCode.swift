//
//  GraphValidateCode.swift
//  Guard
//
//  Created by JnMars on 2023/3/8.
//

import Foundation

open class GraphValidateCode: ImageView {
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
            if config?.appRobotVerify == "always_enable" {

            }
            self.isHidden = config?.appRobotVerify == "always_enable" ? false : true
        }
        
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 0.5
        self.layer.borderColor = Const.Color_BG_Gray.cgColor
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        self.refreshCaptcha()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.refreshCaptcha()
    }
    
    public func refreshCaptcha() {
        AuthClient().getSecurityCaptcha { code, message, data in
            DispatchQueue.global().async {
                if let imgData = data,
                   let image = UIImage(data: imgData) {
                    DispatchQueue.main.async() { [weak self] in
                        self?.image = image
                    }
                }
            }
        }
    }
}
