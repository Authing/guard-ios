//
//  SocialLoginButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/7.
//

import UIKit

open class SocialLoginButton: UIButton {
    
    var loading: UIActivityIndicatorView? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        loading = UIActivityIndicatorView()
        loading?.stopAnimating()
        addSubview(loading!)
        
        loading?.translatesAutoresizingMaskIntoConstraints = false
        loading?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        loading?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        loading?.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        loading?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
//    public override func draw(_ rect: CGRect) {
//        // get current context
//        let ctx = UIGraphicsGetCurrentContext()
//
//        // radius is the half the frame's width or height (whichever is smallest)
//        let radius = min(frame.size.width, frame.size.height) * 0.5
//
//        // center of the view
//        let viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
//
//        let color = UIColor(white: 0.9, alpha: 1)
//        ctx?.setStrokeColor(color.cgColor)
//
//        // move to the center of the pie chart
//        ctx?.move(to: viewCenter)
//
//        // add arc from the center for each segment (anticlockwise is specified for the arc, but as the view flips the context, it will produce a clockwise arc)
//        ctx?.addArc(center: viewCenter, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
//
//        ctx?.setLineWidth(Const.ONEPX)
//        ctx?.setAllowsAntialiasing(true)
//        ctx?.strokeEllipse(in: rect.insetBy(dx: 1, dy: 1))
//    }
}
