//
//  AuthFlowUIConfig.swift
//  Guard
//
//  Created by JnMars on 2022/9/14.
//

import Foundation

public class AuthFlowUIConfig: NSObject {
    
    ///AuthFlow view type
    public enum viewType: String {
        case login = "AuthingLogin"
        case register = "AuthingRegister"
    }
    
    
    ///AuthFlow content mode
    public enum ContentMode {
        case left
        case center
        case right
    }
    
    public var contentMode: ContentMode = .left
    
    public var isCustomView: Bool = false
    
    public var viewType: viewType = .login
    
    public var button: UIButton?
    
    public func setButton(button: UIButton, type: viewType) {
        self.isCustomView = true
        self.viewType = type
        self.button = button
    }
}
