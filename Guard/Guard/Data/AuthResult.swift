//
//  AuthResult.swift
//  Guard
//
//  Created by JnMars on 2022/6/13.
//

import Foundation

open class AuthResult {
    /// authorization_code
    public var authorizationCode: String?
    /// auth request
    public var authRequest: AuthRequest?
    
    init(code: String?, request: AuthRequest?) {
        self.authorizationCode = code
        self.authRequest = request
    }
}
