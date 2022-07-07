//
//  LogoutButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/1.
//

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
        backgroundColor = Util.getWhiteBackgroundColor()
        setTitleColor(Util.getLabelColor(), for: .normal)
        let text = "authing_logout".L
        self.setTitle(text, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        let cancel = "authing_cancel".L
        let tip = "authing_logout_tip".L
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

        authViewController?.present(alert, animated: true, completion: nil)
    }
}
