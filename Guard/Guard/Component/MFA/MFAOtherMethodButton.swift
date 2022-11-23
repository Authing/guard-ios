//
//  MFAOtherMethodButton.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//

import Foundation

open class MFAOtherMethodButton: PrimaryButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        
        self.backgroundColor = UIColor.init(hex: "#F2F3F5")
        self.setTitleColor(UIColor.init(hex: "#1D2129"), for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if Util.findView(self, viewClass: MFATableView.self) == nil {
            self.isHidden = true
        }
    }
    
    @objc private func onClick(sender: UIButton) {
        if let table: MFATableView = Util.findView(self, viewClass: MFATableView.self) {
            UIView.animate(withDuration: 0.3) {
                table.alpha = 1
            }
        }
    }
}
