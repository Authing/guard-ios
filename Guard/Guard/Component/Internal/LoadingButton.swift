//
//  LoadingButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/27.
//

import UIKit

@IBDesignable open class LoadingButton: UIButton {
    
    static let LoadingPaddingH: CGFloat = CGFloat(16)
    static let LoadingPaddingV: CGFloat = CGFloat(12)
    static let DeltaAngle: CGFloat = CGFloat(Double.pi * 2 / 300)
    
    var isLoading: Bool = false
    var tick: Int = 0
    
    @IBInspectable var loadingColor: UIColor? = UIColor.white
    @IBInspectable var loadingLocation: Int = 0 // 0 left; 1 over;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    public func startLoading() {
        isLoading = true
        tick = 0
        self.isEnabled = false
        if (loadingLocation == 0) {
            let h: CGFloat = getLoadingHeight()
            titleEdgeInsets = UIEdgeInsets(top: 0, left: (h + LoadingButton.LoadingPaddingH) / 2, bottom: 0.0, right: 0.0)
        }
        setNeedsDisplay()
    }
    
    public func stopLoading() {
        DispatchQueue.main.async() {
            self.isLoading = false
            self.isEnabled = true
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0.0, right: 0.0)
            self.setNeedsDisplay()
        }
    }

    private func setup() {
    }
    
    private func getLoadingHeight() -> CGFloat {
        return frame.height - 2 * CGFloat(LoadingButton.LoadingPaddingV)
    }
    
    override public func draw(_ rect: CGRect) {
        if (isLoading) {
            let padding = CGFloat(12)
            let size = frame.height - 2 * padding
            let radius = size / 2
            
            var x: CGFloat = 0
            if (loadingLocation == 0) {
                let width = size + LoadingButton.LoadingPaddingH + self.intrinsicContentSize.width
                x = (frame.width - width + size) / 2
            } else if (loadingLocation == 1) {
                x = frame.width / 2
            }
            
            let startAngle = CGFloat(-Double.pi) + CGFloat(tick) * LoadingButton.DeltaAngle
            let endAngle = startAngle + CGFloat(Double.pi/2)

            let circlePath = UIBezierPath(arcCenter: CGPoint(x: x, y: frame.height/2), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            circlePath.lineWidth = 2
            loadingColor?.setStroke()
            circlePath.stroke()
            
            tick += 1
            DispatchQueue.main.async() {
                self.setNeedsDisplay()
            }
        }
    }
}
