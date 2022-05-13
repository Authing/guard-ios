//
//  MethodTabItem.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

public class MethodTabItem: UIView {
    
    private var button: UIButton?
    private var underLine: UIView?
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
        
        button = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height-2))
        button?.isUserInteractionEnabled = false
        button?.titleLabel?.font = button?.titleLabel?.font.withSize(14)
        addSubview(button!)
        
        underLine = UIView(frame: CGRect(x: 0, y: height - 2, width: width, height: 2))
        addSubview(underLine!)
    }
    
    public func setText(_ text: String) {
        button?.setTitle(text, for: .normal)
    }
    
    public func gainFocus(lastFocused: MethodTabItem?) {
        
        isFocuse = true

        button?.setTitleColor(Const.Color_Authing_Main, for: .normal)
        underLine?.backgroundColor = Const.Color_Authing_Main
                
        //重复点击不展示动画
        if self == lastFocused { return }

        DispatchQueue.main.async() {

            if let focused = lastFocused {
                
                let lastFocusedX: CGFloat = focused.layer.position.x
                let x: CGFloat = self.layer.position.x
                let underLinePositionX: CGFloat = self.underLine?.layer.position.x ?? 60

                self.underLine?.layer.add(self.createBasicAnimation(fromValue: underLinePositionX - (x - lastFocusedX),
                                                                    toValue: underLinePositionX,
                                                                    timingFunction: CAMediaTimingFunctionName.linear.rawValue), forKey: "underLine")
            }
        
            self.focusGained()
        }
    }
    
    public func loseFocus() {
        isFocuse = false
        button?.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .normal)
        underLine?.backgroundColor = UIColor(white: 1, alpha: 0)
    }
    
    public func focusGained() {
        
    }
    
    public func isFocused() -> Bool{
        return isFocuse
    }
}

extension MethodTabItem: CAAnimationDelegate{

    fileprivate func createBasicAnimation (fromValue: Double, toValue: Double, timingFunction: String) -> CABasicAnimation {

        let basicAni = CABasicAnimation()
        basicAni.keyPath = "position.x"
        basicAni.fromValue = fromValue
        basicAni.toValue = toValue
        basicAni.duration = 0.3;
        basicAni.repeatCount = 0
        basicAni.delegate = self
        basicAni.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName(rawValue: timingFunction))
        return basicAni;
    }

}
