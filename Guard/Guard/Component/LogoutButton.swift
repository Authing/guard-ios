//
//  LogoutButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/1.
//

import UIKit

open class LogoutButton: UIButton {
    
    public typealias OnLogout = (Int, String?) -> Void
    public var onLogout: OnLogout?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.white
        setTitleColor(UIColor.black, for: .normal)
        let text = NSLocalizedString("authing_logout", bundle: Bundle(for: Self.self), comment: "")
        self.setTitle(text, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let cancel = NSLocalizedString("authing_cancel", bundle: Bundle(for: Self.self), comment: "")
        let tip = NSLocalizedString("authing_logout_tip", bundle: Bundle(for: Self.self), comment: "")
        let alert = UIAlertController(title: nil, message: tip, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            Util.getAuthClient(self).logout { code, message in
                DispatchQueue.main.async() {
                    self.onLogout?(code, message)
                }
            }
        }))

        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))

        viewController?.present(alert, animated: true, completion: nil)
    }
}
