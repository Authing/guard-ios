//
//  MethodTabItem.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

public class MethodTabItem: UIView {
    
    private let button = UIButton()
    private var isFocuse: Bool = false
    var type: Int = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup(frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(frame)
    }

    private func setup(_ frame: CGRect) {
        self.isUserInteractionEnabled = true
        
        let width: Double = frame.width
        let height: Double = frame.height
        
        button.frame = CGRect(x: 0, y: 0, width: width, height: height-2)
        button.isUserInteractionEnabled = false
        button.titleLabel?.font = button.titleLabel?.font.withSize(14)
        addSubview(button)
    }
    
    public func setText(_ text: String) {
        button.setTitle(text, for: .normal)
    }
    
    public func gainFocus(lastFocused: MethodTabItem?) {
        isFocuse = true
        button.setTitleColor(Const.Color_Authing_Main, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        focusGained()
    }
    
    public func loseFocus() {
        isFocuse = false
        button.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    public func focusGained() {
        
    }
    
    public func isFocused() -> Bool{
        return isFocuse
    }
}
