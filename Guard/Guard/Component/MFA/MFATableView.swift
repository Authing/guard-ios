//
//  MFATableView.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/10.
//

import UIKit

open class MFATableView: UIView {
    
    private let ITEM_HEIGHT: CGFloat = 48
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let mfaPhone: MFATableItem = MFATableItem()
        mfaPhone.mfaType = .phone
        addSubview(mfaPhone)
        
        mfaPhone.translatesAutoresizingMaskIntoConstraints = false
        mfaPhone.heightAnchor.constraint(equalToConstant: ITEM_HEIGHT).isActive = true
        mfaPhone.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        mfaPhone.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        mfaPhone.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        let mfaEmail: MFATableItem = MFATableItem()
        mfaEmail.mfaType = .email
        addSubview(mfaEmail)
        
        mfaEmail.translatesAutoresizingMaskIntoConstraints = false
        mfaEmail.heightAnchor.constraint(equalToConstant: ITEM_HEIGHT).isActive = true
        mfaEmail.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        mfaEmail.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        mfaEmail.topAnchor.constraint(equalTo: mfaPhone.bottomAnchor, constant: 16).isActive = true
    }
}
