//
//  String+Authing.swift
//  Guard
//
//  Created by JnMars on 2022/7/7.
//

import Foundation

extension String {
    var L: String {
        
        if let lan = Util.langHeader{
            let path = Bundle(identifier: "cn.authing.Guard")?.path(forResource: lan, ofType: "lproj")
            let bundle = Bundle(path: path ?? "") ?? Bundle()
            return NSLocalizedString(self, bundle: bundle, comment: "")
        } else {
            let bundle = Bundle(identifier: "cn.authing.Guard")
            return NSLocalizedString(self, bundle: bundle ?? Bundle.init(), comment: "")
        }
    }
}
