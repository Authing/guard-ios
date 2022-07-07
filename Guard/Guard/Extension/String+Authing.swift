//
//  String+Authing.swift
//  Guard
//
//  Created by JnMars on 2022/7/7.
//

import Foundation

extension String {
    var L: String {
        let bundle = Bundle(identifier: "cn.authing.Guard")
        return NSLocalizedString(self, bundle: bundle ?? Bundle.init(), comment: "")
    }
}
