//
//  ALog.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/22.
//

open class ALog {
    public static func d(_ type: AnyClass, _ msg: Any...) {
        print("📘 \(getTimestamp()):\(getTag(type)):\(msg)")
    }
    
    public static func i(_ type: AnyClass, _ msg: Any...) {
        print("📗 \(getTimestamp()):\(getTag(type)):\(msg)")
    }
    
    public static func w(_ type: AnyClass, _ msg: Any...) {
        print("⚠️ \(getTimestamp()):\(getTag(type)):\(msg)")
    }
    
    public static func e(_ type: AnyClass, _ msg: Any...) {
        print("❌ \(getTimestamp()):\(getTag(type)):\(msg)")
    }
    
    private static func getTimestamp() -> String {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.string(from: date)
    }
    
    private static func getTag(_ type: AnyClass) -> String {
        let bundleId = Bundle(for: type).bundleIdentifier ?? ""
        let className = String(describing: type)
        return "\(bundleId).\(className)"
    }
}
