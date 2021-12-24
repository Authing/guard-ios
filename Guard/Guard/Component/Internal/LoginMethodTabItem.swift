//
//  LoginMethodTabItem.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

import UIKit

public class LoginMethodTabItem: UIView {
    
    private var button: UIButton?
    private var underLine: UIView?
    var type: Int = 0
    
    override init(frame: CGRect) {
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
        
        button = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height-2))
        button?.isUserInteractionEnabled = false
        button?.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .normal)
        button?.titleLabel?.font = button?.titleLabel?.font.withSize(14)
        addSubview(button!)
        
        underLine = UIView(frame: CGRect(x: 0, y: height - 2, width: width, height: 2))
        underLine?.backgroundColor = UIColor(white: 0.8, alpha: 1)
        addSubview(underLine!)
    }
    
    public func setText(_ text: String) {
        button?.setTitle(text, for: .normal)
    }
    
    public func gainFocus() {
        button?.setTitleColor(Const.Color_Authing_Main, for: .normal)
        underLine?.backgroundColor = Const.Color_Authing_Main
        
        DispatchQueue.main.async() {
        let containers: Array<LoginContainer> = Util.findViews(self, viewClass: LoginContainer.self)
        containers.forEach { container in
            if (container.type == self.type) {
                container.isHidden = false
            } else {
                container.isHidden = true
            }
        }
        }
    }
    
    public func loseFocus() {
        button?.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .normal)
        underLine?.backgroundColor = UIColor(white: 0.8, alpha: 1)
    }
}
