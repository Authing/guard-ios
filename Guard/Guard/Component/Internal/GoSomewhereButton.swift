//
//  GoSomewhereButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class GoSomewhereButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let text = getText()
        self.setTitle(text, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    func getText() -> String {
        return ""
    }
    
    func getNibName() -> String {
        return ""
    }
    
    @objc private func onClick(sender: UIButton) {
        let vc: AuthViewController? = AuthViewController(nibName: getNibName(), bundle: Bundle(for: Self.self))
        self.viewController?.navigationController?.pushViewController(vc!, animated: true)
    }
}
