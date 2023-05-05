//
//  UIColor+Authing.swift
//  Guard
//
//  Created by JnMars on 2022/6/14.
//

import UIKit

extension UIColor {
    public convenience init(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            let divisor = CGFloat(255)
            let scanner = Scanner(string: hexColor)

            if hexColor.count == 6 {
                var hexNumber: UInt32 = 0

                if scanner.scanHexInt32(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / divisor
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / divisor
                    b = CGFloat((hexNumber & 0x0000FF)        ) / divisor
                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
            
            if hexColor.count == 8 {
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / divisor
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / divisor
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / divisor
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        self.init(red: 0, green: 0, blue: 0, alpha: 0)
        return
    }
    
    public class func dynamicColor(darkHex: String, lightHex: String) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark ?
                UIColor.init(hex: darkHex) : UIColor.init(hex: lightHex)
            }
        }
        return UIColor.init(hex: lightHex)
    }
}
