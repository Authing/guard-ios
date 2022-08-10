//
//  Language.swift
//  Guard
//
//  Created by JnMars on 2022/8/2.
//

import Foundation

enum Language: String, CaseIterable {
    case English, Japanese, Chinese, ChineseT
    
    var code: String {
        switch self {
        case .English: return "en"
        case .Japanese: return "ja"
        case .Chinese: return "zh-Hans"
        case .ChineseT: return "zh-Hant"
        }
    }

    static var lang: Language {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "language")
            UserDefaults.standard.synchronize()
        }
        get {
            return Language(rawValue: UserDefaults.standard.string(forKey: "language") ?? "") ?? .English
        }
    }

    static func setLanguage(_ language: String) {
        lang = Language.transitionLanguage(language)
    }
    
    static func transitionLanguage(_ language: String) -> Language {
        switch language {
        case "zh-CN", "zh_CN":
            return .Chinese
        case "en-US", "en_US":
            return .English
        case "zh-TW", "zh_TW":
            return .ChineseT
        case "ja-JP", "ja_JP":
            return .Japanese
        default:
            return .English
        }
    }

}
