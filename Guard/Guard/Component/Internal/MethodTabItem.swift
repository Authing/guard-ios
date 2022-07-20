//
//  MethodTabItem.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

public class MethodTabItem: UIView {
    
    let content = UILabel()
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

        content.font = UIFont.systemFont(ofSize: 14)
        addSubview(content)
    }
    
    public func setText(_ text: String) {
        content.text = text
    }
    
    public func gainFocus(lastFocused: MethodTabItem?) {
        isFocuse = true
        content.textColor = Const.Color_Authing_Main
        focusGained()
    }
    
    public func loseFocus() {
        isFocuse = false
        content.textColor = Const.Color_Text_Default_Gray
    }
    
    public func focusGained() {
        
    }
    
    public func isFocused() -> Bool{
        return isFocuse
    }
}
