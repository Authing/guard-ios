//
//  Validator.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

import Foundation

open class Validator {
    public static func isValidPhone(phone: String?) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]+"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }

    public static func isValidEmail(email: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
