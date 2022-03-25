//
//  TextFieldBorder.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/28.
//

import UIKit

open class TextFieldBorder: UIView {
    
    var highlight: Bool = false
    var animator: Animator = Animator()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
        animator.duration = 400
    }
    
    func setHighlight(_ highlight: Bool) {
        self.highlight = highlight
        if (highlight) {
            animator.start()
        }
        setNeedsDisplay()
    }
    
    override public func draw(_ rect: CGRect) {
        if let parent = superview as? TextFieldLayout {
            if parent.layer.borderWidth > 0 {
                return
            }
        }
        
        let cornor: CGFloat = 6
        if (highlight) {
            let progress: CGFloat = CGFloat(animator.update())
            let step: CGFloat = 1
            var path = UIBezierPath(roundedRect: rect.insetBy(dx: 0.5 * step, dy: 0.5 * step), cornerRadius: cornor)
            path.lineWidth = step
            UIColor(red: 0.8, green: 0.84, blue: 1, alpha: progress*progress).setStroke()
            path.stroke()
            
            path = UIBezierPath(roundedRect: rect.insetBy(dx: 1.5*step, dy: 1.5*step), cornerRadius: cornor)
            path.lineWidth = 1.5
            UIColor(red: 0.82, green: 0.85, blue: 1, alpha: progress).setStroke()
            path.stroke()
            
            path = UIBezierPath(roundedRect: rect.insetBy(dx: 2.5*step, dy: 2.5*step), cornerRadius: cornor)
            path.lineWidth = step
            UIColor(red: 0.16, green: 0.38, blue: 1, alpha: sqrt(progress)).setStroke()
            path.stroke()
            
            if (animator.running) {
                DispatchQueue.main.async() {
                    self.setNeedsDisplay()
                }
            }
        } else {
            let path = UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: cornor)
            path.lineWidth = 1
            UIColor(white: 0.9, alpha: 1).setStroke()
            path.stroke()
        }
    }
}
