//
//  AuthFlowUIConfig.swift
//  Guard
//
//  Created by JnMars on 2022/9/14.
//

import Foundation

public class AuthFlowUIConfig: NSObject {
    
    ///AuthFlow content mode
    public enum ContentMode {
        case left
        case center
        case right
    }
    
    public var contentMode: ContentMode = .left
    
}
