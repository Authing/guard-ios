//
//  Validator.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

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
    
    public static func hasEnglish(_ s: String?) -> Bool {
        let range = s?.rangeOfCharacter(from: .letters)
        return range != nil
    }
    
    public static func hasNumber(_ s: String?) -> Bool {
        let range = s?.rangeOfCharacter(from: .decimalDigits)
        return range != nil
    }
    
    public static func hasSpecialCharacter(_ s: String?) -> Bool {
        let characterset = CharacterSet(charactersIn: "!@#$%&*()_+=|<>?{}~-[]")
        return s?.rangeOfCharacter(from: characterset) != nil
    }
}
