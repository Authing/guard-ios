//
//  Util.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/3.
//

import Foundation
import UIKit

public class Util {
    enum KeychainError: Error {
        // Attempted read for an item that does not exist.
        case itemNotFound
        
        // Attempted save to override an existing item.
        // Use update instead of save to update existing items
        case duplicateItem
        
        // A read of an item in any format other than Data
        case invalidItemFormat
        
        // Any operation result status than errSecSuccess
        case unexpectedStatus(OSStatus)
    }
    
    private static let SERVICE_UUID: String = "service_uuid"

    public static func getDeviceID() -> String {
        let savedUUID = load()
        if (savedUUID == nil) {
            let uuid: String = NSUUID().uuidString
            try? save(uuid: uuid)
            return uuid
        } else {
            return savedUUID!
        }
    }
    
    public static func load() -> String? {
        let query = [
          kSecClass: kSecClassGenericPassword,
          kSecAttrService as String: SERVICE_UUID as AnyObject,
          kSecReturnAttributes: true,
          kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        if (status != 0) {
            print("Try get uuid from keychain operation finished with status: \(status)")
        }
        if (result == nil) {
            return nil
        }
        
        let dic = result as! NSDictionary
        let uuidData = dic[kSecValueData] as! Data
        let uuid = String(data: uuidData, encoding: .utf8)!
//        print("uuid: \(uuid)")
        return uuid;
    }
    
    public static func save(uuid: String) throws {
        let uuidData: Data? = uuid.data(using: String.Encoding.utf8)
        let query = [
          kSecValueData: uuidData!,
          kSecAttrService: SERVICE_UUID,
          kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        // SecItemAdd attempts to add the item identified by
        // the query to keychain
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )

        // errSecDuplicateItem is a special case where the
        // item identified by the query already exists. Throw
        // duplicateItem so the client can determine whether
        // or not to handle this as an error
        if status == errSecDuplicateItem {
            throw KeychainError.duplicateItem
        }

        // Any status other than errSecSuccess indicates the
        // save operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    public static func remove() {
        let query = [
          kSecClass: kSecClassGenericPassword,
          kSecAttrService: SERVICE_UUID,
        ] as CFDictionary

        SecItemDelete(query)
    }
    
    public static func encryptPassword(_ message: String) -> String {
        let data: Data = Data(base64Encoded: Authing.getPublicKey())!
        
        var attributes: CFDictionary {
            return [kSecAttrKeyType         : kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass        : kSecAttrKeyClassPublic,
                    kSecAttrKeySizeInBits   : 2048,
                    kSecReturnPersistentRef : kCFBooleanTrue!] as CFDictionary
        }

        var error: Unmanaged<CFError>? = nil
        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
            print(error.debugDescription)
            return "error"
        }
        
        let buffer = [UInt8](message.utf8)

        var keySize   = SecKeyGetBlockSize(secKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)

        // Encrypto  should less than key length
        guard SecKeyEncrypt(secKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize) == errSecSuccess else { return "error" }
        return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
    }
    
    public static func getLangHeader() -> String {
        let langStr: String? = Locale.current.languageCode
        if (langStr!.hasPrefix("zh")) {
            return "zh-CN"
        } else {
            return "en-US"
        }
    }
    
    public static func findViews<T: UIView>(_ current: UIView, viewClass: AnyClass) -> Array<T> {
        let rootView: UIView = getRootView(current)
        var views: Array<T> = []
        _findViews(rootView, viewClass: viewClass, result: &views)
        return views
    }
    
    public static func _findViews<T: UIView>(_ parent: UIView, viewClass: AnyClass, result: inout Array<T>) {
        for child: UIView in parent.subviews {
            _findViews(child, viewClass: viewClass, result: &result)
            
            if (type(of: child) == viewClass) {
                result.append(child as! T)
            }
        }
    }
    
    public static func findView<T: UIView>(_ current: UIView, viewClass: AnyClass) -> T? {
        let rootView: UIView = current.viewController?.view ?? getRootView(current)
        return _findView(rootView, viewClass: viewClass)
    }
    
    public static func _findView<T: UIView>(_ parent: UIView, viewClass: AnyClass) -> T? {
        if (type(of: parent) == viewClass && isVisible(parent)) {
            return parent as? T
        }
        for child in parent.subviews {
            let result: T? = _findView(child, viewClass: viewClass)
            if (result != nil) {
                return result
            }
        }
        return nil
    }
    
    public static func getRootView(_ current: UIView) -> UIView {
        var v: UIView = current
        while v.superview != nil {
            v = v.superview!
        }
        return v
    }
    
    public static func isVisible(_ view: UIView?) -> Bool {
        if (view == nil) {
            return true
        }
        if (view!.isHidden) {
            return false
        }
        return isVisible(view!.superview)
    }
    
    public static func setError(_ current: UIView, _ text: String?) {
        DispatchQueue.main.async() {
            let errorView = Util.findView(current, viewClass: ErrorLabel.self)
            if (errorView != nil) {
                (errorView as! ErrorLabel).text = text
            }
        }
    }
    
    public static func getVerifyCode(_ current: UIView) -> String? {
        if let tfVerifyCode: VerifyCodeTextField = Util.findView(current, viewClass: VerifyCodeTextField.self) {
            return tfVerifyCode.text
        }
        
        if let tfVerifyCode: FramedVerifyCodeTextField = Util.findView(current, viewClass: FramedVerifyCodeTextField.self) {
            return tfVerifyCode.getText()
        }
        return nil
    }
    
    public static func getHost(_ config: Config) -> String {
        return "\(config.identifier!).\(Authing.getHost())"
    }
    
    public static func isNull(_ s: String?) -> Bool {
        return s == nil || s?.count == 0 || s == "null"
    }
    
    public static func getPhoneNumber(_ current: UIView) -> String? {
        if let tfPhone: PhoneNumberTextField = Util.findView(current, viewClass: PhoneNumberTextField.self) {
            if (Validator.isValidPhone(phone: tfPhone.text)) {
                return tfPhone.text
            }
        }
        
        if let tfAccount: AccountTextField = Util.findView(current, viewClass: AccountTextField.self) {
            if (Validator.isValidPhone(phone: tfAccount.text)) {
                return tfAccount.text
            }
        }
        
        let phone: String? = current.viewController?.authFlow?.data[AuthFlow.KEY_MFA_PHONE] as? String
        if (phone != nil) {
            return phone
        }
        
        return current.viewController?.authFlow?.data[AuthFlow.KEY_ACCOUNT] as? String
    }
    
    public static func getEmail(_ current: UIView) -> String? {
        if let tfEmail: EmailTextField = Util.findView(current, viewClass: EmailTextField.self) {
            if (Validator.isValidEmail(email: tfEmail.text)) {
                return tfEmail.text
            }
        }
        
        if let tfAccount: AccountTextField = Util.findView(current, viewClass: AccountTextField.self) {
            if (Validator.isValidEmail(email: tfAccount.text)) {
                return tfAccount.text
            }
        }
        
        let email: String? = current.viewController?.authFlow?.data[AuthFlow.KEY_MFA_EMAIL] as? String
        if (email != nil) {
            return email
        }
        
        return current.viewController?.authFlow?.data[AuthFlow.KEY_ACCOUNT] as? String
    }
    
    public static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    public static func getQueryStringParameter(url: URL, param: String) -> String? {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
