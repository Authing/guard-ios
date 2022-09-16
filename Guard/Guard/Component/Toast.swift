//
//  Toast.swift
//  ToolBox
//
//  Created by JnMars on 2022/7/15.
//

import UIKit

class Toast {
    
    class func show(text: String){
        if text == "" { return }

        DispatchQueue.main.async() {
            
            let keyWindow = UIApplication.shared.windows.first
            
            let rect = text.boundingRect(with: CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude), options:[NSStringDrawingOptions.truncatesLastVisibleLine, NSStringDrawingOptions.usesFontLeading,NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)], context: nil)
            
            let labelWidth: CGFloat = rect.width + 40
            let labelHeight: CGFloat = rect.height + 20
            let labelOrignY: CGFloat = (keyWindow?.center.y ?? 0) - (labelHeight)/2
            let backgroundView = UIView(frame: CGRect(x: (keyWindow?.center.x ?? 0) - (labelWidth)/2,
                                                      y: labelOrignY,
                                                      width: labelWidth,
                                                      height: labelHeight))
            backgroundView.backgroundColor = UIColor.black
            backgroundView.alpha = 0
            backgroundView.layer.cornerRadius = 4
            keyWindow?.addSubview(backgroundView)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight))
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14.0)
            label.text = text
            label.numberOfLines = 0
            backgroundView.addSubview(label)
        

            UIView.animate(withDuration: 0.5) {
                backgroundView.alpha = 0.7
            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    UIView.animate(withDuration: 0.5) {
                        backgroundView.alpha = 0
                    } completion: { _ in
                        backgroundView.removeFromSuperview()
                    }
                }
            }
        }
    }

}
class ToastView: UIView {
    
}
