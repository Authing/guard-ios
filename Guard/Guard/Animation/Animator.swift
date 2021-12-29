//
//  Animator.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class Animator {
    var from: Double = 0
    var to: Double = 1
    var duration: Int = 0
    var startTime: TimeInterval = 0
    var running: Bool = false
    
    open func start() {
        startTime = Date().timeIntervalSince1970
        running = true
    }
    
    open func update() -> Double {
        let now: TimeInterval = Date().timeIntervalSince1970
        var elapse: Double = (now - startTime) * 1000 / Double(duration)
        if (elapse >= 1) {
            elapse = 1
            running = false
        }
        return from + (to - from) * elapse
    }
}
