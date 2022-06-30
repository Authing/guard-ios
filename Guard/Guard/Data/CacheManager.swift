//
//  CacheManager.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/28.
//

open class CacheManager {
    public static func getImage(_ key: String) -> UIImage? {
        do {
            let documentDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let path = documentDir.appendingPathComponent(key)
            if let data = try? Data(contentsOf: path) {
                return UIImage(data: data)
            }
        } catch {
            ALog.e(Self.self, "exception when getting image \(error)")
        }
        return nil
    }
    
    public static func putImage(_ key: String, _ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return
        }
        do {
            let documentDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let path = documentDir.appendingPathComponent(key)
            try data.write(to: path)
        } catch {
            ALog.e(Self.self, "exception when putting image \(error)")
        }
    }
}
