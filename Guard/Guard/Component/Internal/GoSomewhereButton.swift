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
        fontSize = 15
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
        if let page = target {
            if let authFlow = authViewController?.authFlow,
               let appBundle = authFlow.appBundle {
                let rootView = Parser().inflate(appBundle: appBundle, page: page)
                let vc = AuthViewController()
                vc.authFlow = authFlow.copy() as? AuthFlow
                vc.view = rootView
                if let mcs = appBundle.mainColor,
                   let mainColor = Util.parseColor(mcs) {
                    authViewController?.navigationController?.navigationBar.tintColor = mainColor
                }
                authViewController?.navigationController?.pushViewController(vc, animated: true)
            } else {
                ALog.e(Self.self, "can't go anywhere. page:\(page)")
            }
        } else {
            goNow()
        }
    }
    
    func getText() -> String {
        return ""
    }
    
    func goNow() {
        
    }
    
    public override func setAttribute(key: String, value: String) {
        super.setAttribute(key: key, value: value)
        if ("target" == key) {
            target = value
        }
    }
}
