//
//  DeleteAccountButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/4.
//

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
        backgroundColor = Util.getWhiteBackgroundColor()
        let text = "authing_delete_account".L
        self.setTitle(text, for: .normal)
        setTitleColor(Const.Color_Error, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let cancel = "authing_cancel".L
        let tip = "authing_delete_account_tip".L
        let alert = UIAlertController(title: nil, message: tip, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            Util.getAuthClient(self).deleteAccount { code, message in
                DispatchQueue.main.async() {
                    self.onDeleteAccount?(code, message)
                }
            }
        }))

        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))

        authViewController?.present(alert, animated: true, completion: nil)
    }
}
