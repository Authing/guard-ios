//
//  Util.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/3.
//

import Foundation
import UIKit

public class Util {
    
    public enum PasswordStrength {
        case weak
        case medium
        case strong
    }
    
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
        let rootView: UIView = current.authViewController?.view ?? getRootView(current)
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
            if let errorView: ErrorLabel = Util.findView(current, viewClass: ErrorLabel.self) {
                errorView.text = text
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
    
    public static func isIp(_ str: String) -> Bool {
        let reg = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
        return str.range(of: reg, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    public static func getHost(_ config: Config) -> String {
        if Util.isIp(Authing.getHost()) {
            return Authing.getHost()
        } else {
            return config.requestHostname ?? "\(config.identifier ?? "").\(Authing.getHost())"
        }
    }
    
    public static func isNull(_ s: String?) -> Bool {
        return s == nil || s?.count == 0 || s == "null"
    }
    
    public static func getPhoneNumber(_ current: UIView) -> String? {
        if let tfPhone: PhoneNumberTextField = Util.findView(current, viewClass: PhoneNumberTextField.self) {
            if (Validator.isValidPhone(phone: tfPhone.textField.text)) {
                return tfPhone.textField.text
            }
        }
        
        if let tfAccount: AccountTextField = Util.findView(current, viewClass: AccountTextField.self) {
            if (Validator.isValidPhone(phone: tfAccount.text)) {
                return tfAccount.text
            }
        }
        
        if let phone = current.authViewController?.authFlow?.data[AuthFlow.KEY_MFA_PHONE] as? String {
            return phone
        }
        
        return current.authViewController?.authFlow?.data[AuthFlow.KEY_ACCOUNT] as? String
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
        
        if let email = current.authViewController?.authFlow?.data[AuthFlow.KEY_MFA_EMAIL] as? String {
            return email
        }
        
        return current.authViewController?.authFlow?.data[AuthFlow.KEY_ACCOUNT] as? String
    }
    
    public static func getAccount(_ current: UIView) -> String? {
        if let phone = Util.getPhoneNumber(current) {
            return phone
        }
        if let email = Util.getEmail(current) {
            return email
        }
        if let tfAccount: AccountTextField = Util.findView(current, viewClass: AccountTextField.self) {
            return tfAccount.text
        }
        return current.authViewController?.authFlow?.data[AuthFlow.KEY_ACCOUNT] as? String
    }
    
    public static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    public static func getQueryStringParameter(url: URL, param: String) -> String? {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    public static func computePasswordSecurityLevel(password: String) -> PasswordStrength {
        let length = password.count
        if (length < 6) {
            return .weak
        }

        let hasEnglish = Validator.hasEnglish(password)
        let hasNumber = Validator.hasNumber(password)
        let hasSpecialChar = Validator.hasSpecialCharacter(password)
        if (hasEnglish && hasNumber && hasSpecialChar) {
            return .strong
        } else if ((hasEnglish && hasNumber) ||
                (hasEnglish && hasSpecialChar) ||
                (hasNumber && hasSpecialChar)) {
            return .medium
        } else {
            return .weak
        }
    }
    
    public static func parseColor(_ appBundle: AppBundle?, _ colorString: String) -> UIColor? {
        if "@mainColor" == colorString {
            let color = appBundle?.mainColor ?? "#3A69FF"
            return Util.parseColor(color)
        } else {
            return Util.parseColor(colorString)
        }
    }
    
    public static func parseColor(_ colorString: String) -> UIColor? {
        var cString:String = colorString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        } else {
            return nil
        }

        if cString.count == 6 {
            var rgbValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)

            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        } else if cString.count == 8 {
            var rgbValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)

            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat((rgbValue & 0xFF0000) >> 24) / 255.0
            )
        }
        return nil
    }
    
    public static func exportColor(_ color: UIColor) -> String? {
        if let components = color.cgColor.components {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            if components.count == 2 {
                r = components[0]
                g = components[0]
                b = components[0]
                a = components[1]
            } else if components.count == 4 {
                r = components[0]
                g = components[1]
                b = components[2]
                a = components[3]
            }
            
            if a == 0 {
                return nil
            } else if a == 1 {
                return String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
            } else {
                return String.init(format: "#%02lX%02lX%02lX%02lX", lroundf(Float(a * 255)), lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
            }
        }
        return nil
    }
    
    public static func getConfig(_ view: UIView, completion: @escaping(Config?)->Void) {
        DispatchQueue.main.async() {
            if let c = view.authViewController?.authFlow?.config {
                c.getConfig(completion: completion)
            } else {
                Authing.getConfig(completion: completion)
            }
        }
    }
    
    public static func getAuthClient(_ view: UIView) -> AuthClient {
        if let flow = view.authViewController?.authFlow,
           let config = flow.config {
            return AuthClient(config)
        } else {
            return AuthClient()
        }
    }
    
    public static func openPage(_ view: UIView, _ page: String) {
        ALog.d(Self.self, "Opening \(page)")
        if let authFlow = view.authViewController?.authFlow,
           let appBundle = authFlow.appBundle {
            let rootView = Parser().inflate(appBundle: appBundle, page: page)
            let vc = AuthViewController()
            vc.authFlow = authFlow.copy() as? AuthFlow
            vc.view = rootView
            if let mcs = appBundle.mainColor,
               let mainColor = Util.parseColor(mcs) {
                view.authViewController?.navigationController?.navigationBar.tintColor = mainColor
            }
            view.authViewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            ALog.e(Self.self, "can't open page:\(page)")
        }
    }
}
