//
//  LocalizeHelper.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = NSLocalizedString(key!, bundle: Bundle(for: Authing.self), comment: "")
        }
    }
}

extension UITextField {
    @IBInspectable var localizedHint: String? {
        get { return nil }
        set(key) {
            placeholder = NSLocalizedString(key!, bundle: Bundle(for: Authing.self), comment: "")
        }
    }
}
