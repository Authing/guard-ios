//
//  MFATableView.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/10.
//

open class MFATableView: UIView {
    
    private let ITEM_HEIGHT: CGFloat = 48
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        if let mfaPolicy = Authing.getCurrentUser()?.mfaPolicy {
            var i = 0, last: UIView? = nil
            for policy in mfaPolicy {
                let mfaItem: MFATableItem = MFATableItem()
                if (policy == "SMS") {
                    mfaItem.mfaType = .phone
                } else if (policy == "EMAIL") {
                    mfaItem.mfaType = .email
                } else if (policy == "OTP") {
                    mfaItem.mfaType = .totp
                } else if (policy == "FACE") {
                    mfaItem.mfaType = .face
                } else {
                    continue
                }
                addSubview(mfaItem)
                
                mfaItem.translatesAutoresizingMaskIntoConstraints = false
                mfaItem.heightAnchor.constraint(equalToConstant: ITEM_HEIGHT).isActive = true
                mfaItem.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
                mfaItem.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
                if (i == 0) {
                    mfaItem.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
                } else {
                    mfaItem.topAnchor.constraint(equalTo: last!.bottomAnchor, constant: 16).isActive = true
                }

                last = mfaItem
                i += 1
            }
        }
    }
}
