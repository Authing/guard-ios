//
//  GoSomewhereButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class GoSomewhereButton: Button {
    
    open var target: String? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let text = getText()
        setTitle(text, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClick(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc private func onClick(_ sender: UITapGestureRecognizer? = nil) {
        ALog.d(Self.self, "Going somewhere")
        if let t = target {
            
        } else {
            goNow()
        }
    }
    
    func getText() -> String {
        return ""
    }
    
    func goNow() {
        
    }
}
