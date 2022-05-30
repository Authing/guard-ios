//
//  SocialLoginButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/7.
//

import UIKit

open class SocialLoginButton: Button {
    
    var loading: UIActivityIndicatorView? = nil
    var isLoading: Bool = false
    var angle: CGFloat = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
//        loading = UIActivityIndicatorView()
//        loading?.stopAnimating()
//        addSubview(loading!)
//
//        loading?.translatesAutoresizingMaskIntoConstraints = false
//        loading?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
//        loading?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
//        loading?.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
//        loading?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    public func startLoading() {
        isLoading = true
        setNeedsDisplay()
    }
    
    public func stopLoading() {
        isLoading = false
    }
    
    public override func draw(_ rect: CGRect) {
        if isLoading {
            // get current context
            let ctx = UIGraphicsGetCurrentContext()

            // radius is the half the frame's width or height (whichever is smallest)
            let radius = min(frame.size.width, frame.size.height) * 0.5 - 1

            // center of the view
            let viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)

            let color = Const.Color_Authing_Main
            ctx?.setStrokeColor(color.cgColor)

            let trackPath = UIBezierPath(arcCenter: viewCenter, radius: radius, startAngle: angle, endAngle: angle + CGFloat.pi / 2, clockwise: true)
            trackPath.lineWidth = 1
            Const.Color_Authing_Main.setStroke()
            trackPath.stroke()
            
            angle = angle + 5 * CGFloat.pi / 180
            if angle >= CGFloat.pi*2 {
                angle = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
                self.setNeedsDisplay()
            }
        }
    }
}
