//
//  ALog.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/22.
//

import Foundation

open class ALog {
    public static func d(_ tag: String, _ msg: String...) {
        print("📘\(tag):\(msg)")
    }
    
    public static func i(_ tag: String, _ msg: String...) {
        print("📗\(tag):\(msg)")
    }
    
    public static func w(_ tag: String, _ msg: String...) {
        print("📙\(tag):\(msg)")
    }
    
    public static func e(_ tag: String, _ msg: String...) {
        print("📕\(tag):\(msg)")
    }
}
