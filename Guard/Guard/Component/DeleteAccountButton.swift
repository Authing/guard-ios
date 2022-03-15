//
//  DeleteAccountButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/4.
//

import UIKit

open class DeleteAccountButton: UIButton {
    
    public typealias OnDeleteAccount = (Int, String?) -> Void
    public var onDeleteAccount: OnDeleteAccount?
    
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
        let text = NSLocalizedString("authing_delete_account", bundle: Bundle(for: Self.self), comment: "")
        self.setTitle(text, for: .normal)
        setTitleColor(Const.Color_Error, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let cancel = NSLocalizedString("authing_cancel", bundle: Bundle(for: Self.self), comment: "")
        let tip = NSLocalizedString("authing_delete_account_tip", bundle: Bundle(for: Self.self), comment: "")
        let alert = UIAlertController(title: nil, message: tip, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            AuthClient().deleteAccount { code, message in
                DispatchQueue.main.async() {
                    self.onDeleteAccount?(code, message)
                }
            }
        }))

        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))

        viewController?.present(alert, animated: true, completion: nil)
    }
}
