//
//  RootView.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/15.
//

public protocol AttributedViewProtocol {
    func getAttribute(key: String) -> Any?
    
    // for parsr
    func setAttribute(key: String, value: String)
    
    // for editor
    func setAttribute(key: String, value: Any?)
    
    // for exporter
    func getXMLAttributes() -> String
}

extension AttributedViewProtocol {
    public func getAttribute(key: String) -> Any? { return nil }
    public func setAttribute(key: String, value: String) {}
    public func setAttribute(key: String, value: Any?) {}
    public func getXMLAttributes() -> String { return "" }
}

extension UIView {
    private enum Keys {
        static var extendedPropertyKey = "extendedProperty"
    }

    public var extendedProperty: NSDictionary {
        get {
            if let ep = objc_getAssociatedObject(self, &Keys.extendedPropertyKey) as? NSDictionary {
                return ep
            }
            let ep = NSMutableDictionary()
            objc_setAssociatedObject(
                self,
                &Keys.extendedPropertyKey,
                ep,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            return ep
        }
        set {
            objc_setAssociatedObject(
                self,
                &Keys.extendedPropertyKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    public func refresh() {
        if let background = extendedProperty["background"] as? UIColor {
            backgroundColor = background
        }
    }
    
    public func getAttribute(key: String) -> Any? {
        if "background" == key {
            return backgroundColor
        } else if "width" == key || "height" == key {
            return layoutParams
        } else if "margin" == key {
            return layoutParams.margin
        } else if "flex" == key {
            return layoutParams.fill
        } else if "border-width" == key {
            return NSString(format: "%.1f", layer.borderWidth)
        } else if "border-color" == key {
            if let c = layer.borderColor {
                return UIColor(cgColor: c)
            }
        } else if "border-corner" == key {
            return NSString(format: "%.1f", layer.cornerRadius)
        } else if "color" == key {
            if let v = self as? UIButton {
                return v.titleLabel?.textColor
            } else if let v = self as? UILabel {
                return v.textColor
            } else if let v = self as? UITextField {
                return v.textColor
            }
        } else if "hint-color" == key {
            if let v = self as? BaseInput {
                return v.hintColor
            }
        } else if "text" == key {
            if let v = self as? Label {
                return v.textValue
            } else if let v = self as? Button {
                return v.textValue
            } else if let v = self as? BaseInput {
                return v.textValue
            }
        } else if "font-size" == key {
            if let v = self as? Label {
                return NSString(format: "%.1f", v.font.pointSize)
            } else if let v = self as? Button {
                if let font = v.titleLabel?.font {
                    return NSString(format: "%.1f", font.pointSize)
                }
            } else if let v = self as? BaseInput {
                if let font = v.font {
                    return NSString(format: "%.1f", font.pointSize)
                }
            }
        } else if "font-weight" == key {
            if let v = self as? Label {
                return v.isBold ? "bold" : "normal"
            } else if let v = self as? Button {
                return v.isBold ? "bold" : "normal"
            } else if let v = self as? BaseInput {
                return v.isBold ? "bold" : "normal"
            }
        } else if "text-align" == key {
            if let v = self as? Label {
                return v.textAlign
            } else if let v = self as? Button {
                return v.textAlign
            } else if let v = self as? BaseInput {
                return v.textAlign
            }
        } else if "direction" == key {
            if let v = self as? Layout {
                if v.orientation == .vertical {
                    return 0
                } else if v.orientation == .horizontal {
                    return 1
                }
            }
        } else if "align-items" == key {
            if let v = self as? Layout {
                if v.alignItems == .flexStart {
                    return 0
                } else if v.alignItems == .center {
                    return 1
                } else if v.alignItems == .flexEnd {
                    return 2
                }
            }
        } else if "target" == key {
            if let v = self as? GoSomewhereButton {
                return v.target
            }
        } else if "phoneTarget" == key {
            if let v = self as? ResetPasswordButton {
                return v.phoneTarget
            }
        } else if "emailTarget" == key {
            if let v = self as? ResetPasswordButton {
                return v.emailTarget
            }
        }
        return nil
    }
    
    public func setAttribute(key: String, value: Any?) {
        if "width" == key {
            if let v = value as? CGFloat {
                layoutParams.width = v
                superview?.setNeedsLayout()
            }
        } else if "height" == key {
            if let v = value as? CGFloat {
                layoutParams.height = v
                superview?.setNeedsLayout()
            }
        } else if "background" == key {
            if let color = value as? UIColor {
                backgroundColor = color
            }
        } else if "background-image" == key || "src" == key, let image = value as? UIImage {
            if let v = self as? UIImageView {
                v.image = image
            }
        } else if "margin" == key {
            if let v = value as? Edge {
                layoutParams.margin = v
                superview?.setNeedsLayout()
            }
        } else if "border-width" == key {
            if let v = value as? NSString {
                layer.borderWidth = CGFloat(v.floatValue)
                if layer.borderWidth > 0 {
                    layer.masksToBounds = true
                }
            }
        } else if "flex" == key {
            if let v = value as? CGFloat {
                layoutParams.fill = v
            }
        } else if "border-color" == key {
            if let color = value as? UIColor {
                layer.borderColor = color.cgColor
            }
        } else if "border-corner" == key {
            if let v = value as? NSString {
                layer.cornerRadius = CGFloat(v.floatValue)
            }
        } else if "color" == key, let color = value as? UIColor {
            if let v = self as? UIButton {
                v.titleLabel?.textColor = color
                v.setTitleColor(color, for: .normal)
                v.setTitleColor(color, for: .disabled)
            } else if let v = self as? UILabel {
                v.textColor = color
            } else if let v = self as? UITextField {
                v.textColor = color
            }
        } else if "hint-color" == key, let color = value as? UIColor {
            if let v = self as? BaseInput {
                v.hintColor = color
            }
        } else if "text" == key {
            if let v = value as? String {
                if let view = self as? Label {
                    view.textValue = v
                } else if let view = self as? Button {
                    view.textValue = v
                } else if let view = self as? BaseInput {
                    view.textValue = v
                }
            }
        } else if "font-size" == key {
            if let v = value as? NSString {
                if let view = self as? Label {
                    view.fontSize = CGFloat(v.floatValue)
                } else if let view = self as? Button {
                    view.fontSize = CGFloat(v.floatValue)
                } else if let view = self as? BaseInput {
                    view.fontSize = CGFloat(v.floatValue)
                }
            }
        } else if "font-weight" == key {
            if let v = value as? Bool {
                if let view = self as? Label {
                    view.isBold = v
                } else if let view = self as? Button {
                    view.isBold = v
                } else if let view = self as? BaseInput {
                    view.isBold = v
                }
            }
        } else if "text-align" == key {
            if let index = value as? Int {
                if let view = self as? Label {
                    view.textAlign = index
                } else if let view = self as? Button {
                    view.textAlign = index
                } else if let view = self as? BaseInput {
                    view.textAlign = index
                }
            }
        } else if "direction" == key, let index = value as? Int {
            if let v = self as? Layout {
                if index == 0 {
                    v.orientation = .vertical
                } else if index == 1 {
                    v.orientation = .horizontal
                }
            }
        } else if "align-items" == key, let index = value as? Int {
            if let v = self as? Layout {
                if index == 0 {
                    v.alignItems = .flexStart
                } else if index == 1 {
                    v.alignItems = .center
                } else if index == 2 {
                    v.alignItems = .flexEnd
                }
            }
        }
    }
    
    public func getXMLAttributes() -> String {
        var res = ""
        if let colorRef = extendedProperty["background"] {
            res += " background=\"\(colorRef)\""
        } else if let backgroundColor = backgroundColor,
            let hexColor = Util.exportColor(backgroundColor) {
            res += " background=\"\(hexColor)\""
        }
        let width = layoutParams.width
        if width == LayoutParams.matchParent {
            res += " width=\"match\""
        } else if width >= 0 {
            res += " width=\"\(width)\""
        }
        
        let height = layoutParams.height
        if height == LayoutParams.matchParent {
            res += " height=\"match\""
        } else if height >= 0 {
            res += " height=\"\(height)\""
        }
        
        if layoutParams.fill != 0 {
            res += " flex=\"\(layoutParams.fill)\""
        }
        
        let marginLeft = layoutParams.margin.left
        if marginLeft != 0 {
            res += " margin-left=\"\(marginLeft)\""
        }
        
        let marginTop = layoutParams.margin.top
        if marginTop != 0 {
            res += " margin-top=\"\(marginTop)\""
        }
        
        let marginRight = layoutParams.margin.right
        if marginRight != 0 {
            res += " margin-right=\"\(marginRight)\""
        }
        
        let marginBottom = layoutParams.margin.bottom
        if marginBottom != 0 {
            res += " margin-bottom=\"\(marginBottom)\""
        }
        
        let borderWidth = layer.borderWidth
        if borderWidth > 0 {
            res += " border-width=\"\(borderWidth)\""
        }
        
        if let colorRef = extendedProperty["border-color"] {
            res += " border-color=\"\(colorRef)\""
        } else if let borderColor = layer.borderColor,
            let hexColor = Util.exportColor(UIColor(cgColor: borderColor)) {
            res += " border-color=\"\(hexColor)\""
        }
        
        let cornerRadius = layer.cornerRadius
        if cornerRadius > 0 {
            res += " border-corner=\"\(cornerRadius)\""
        }
        
        if let layout = self as? Layout {
            if layout.alignItems == AlignItems.center {
                res += " align-items=\"center\""
            }
            if layout.orientation == .horizontal {
                res += " direction=\"row\""
            }
        }
        
        if let colorRef = extendedProperty["color"] {
            res += " color=\"\(colorRef)\""
        } else {
            if let color = getColor(self),
                let hexColor = Util.exportColor(color) {
                res += " color=\"\(hexColor)\""
            }
        }
        
        if let view = self as? Label {
            if let tv = view.textValue {
                res += " text=\"\(tv)\""
            }
            
            res += " font-size=\"\(view.fontSize)\""
            
            if view.isBold {
                res += " font-weight=\"bold\""
            }
            
            if let ta = view.getTextAlignAsString() {
                res += " text-align=\"\(ta)\""
            }
        }
        
        if let view = self as? Button {
            if let tv = view.textValue {
                res += " text=\"\(tv)\""
            }
            
            res += " font-size=\"\(view.fontSize)\""
            
            if view.isBold {
                res += " font-weight=\"bold\""
            }
            
            if let ta = view.getTextAlignAsString() {
                res += " text-align=\"\(ta)\""
            }
        }
        
        if let view = self as? BaseInput {
            if let colorRef = extendedProperty["hint-color"] {
                res += " hint-color=\"\(colorRef)\""
            } else if let color = view.hintColor,
                let hexColor = Util.exportColor(color) {
                res += " hint-color=\"\(hexColor)\""
            }
            
            if let tv = view.textValue {
                res += " text=\"\(tv)\""
            }
            
            res += " font-size=\"\(view.fontSize)\""
            
            if view.isBold {
                res += " font-weight=\"bold\""
            }
            
            if let ta = view.getTextAlignAsString() {
                res += " text-align=\"\(ta)\""
            }
        }
        
        if let view = self as? GoSomewhereButton {
            if let t = view.target {
                res += " target=\"\(t)\""
            }
        }
        
        if let view = self as? ResetPasswordButton {
            if let t = view.phoneTarget {
                res += " phoneTarget=\"\(t)\""
            }
            if let t = view.emailTarget {
                res += " emailTarget=\"\(t)\""
            }
        }
        return res
    }
    
    public func getColor(_ view: UIView) -> UIColor? {
        if let v = view as? Label {
            return v.textColor
        } else if let v = view as? Button {
            return v.titleLabel?.textColor
        } else if let v = view as? BaseInput {
            return v.textColor
        }
        return nil
    }
}

open class RootView: UIView, AttributedViewProtocol {
    public override func layoutSubviews() {
        if (subviews.count > 0) {
            if let layout = subviews[0] as? Layout {
                layout.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            }
        }
    }
    
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        layoutChild()
    }
    
    private func layoutChild() {
        if let layout = subviews[0] as? Layout {
            layout.layoutSubviews()
        }
    }
}
