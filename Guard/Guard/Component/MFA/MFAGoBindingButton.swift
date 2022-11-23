//
//  MFAGoBindingButton.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//

open class MFAGoBindingButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        if let item: MFATableItem = Util.findView(self, viewClass: MFATableItem.self) {
            item.handleTap()
        } else {
            if let mfaPolicy = Authing.getCurrentUser()?.mfaPolicy?.first {
                DispatchQueue.main.async() {
                    let vc = LoginButton.mfaHandle(view: self, mfaType: mfaPolicy, needGuide: false)
                    self.authViewController?.navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
                }
            }
        }
    }
}
