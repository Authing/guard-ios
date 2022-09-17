//
//  SocialLoginButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/7.
//

open class SocialLoginButton: Button {
    
    static let duration = 0.5 // takes {duration} seconds for one circle
    static let speed = Double.pi * 2 / duration
    
    var loading: UIActivityIndicatorView? = nil
    var isLoading: Bool = false
    var startTime: Double = 0.0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        setTitleColor(UIColor.init(hex: "#1D2129"), for: .normal)
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
        startTime = Date().timeIntervalSince1970
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

            let deltaTime = Date().timeIntervalSince1970 - startTime
            let startAngle = CGFloat(-Double.pi) + SocialLoginButton.speed * deltaTime
            let endAngle = startAngle + CGFloat(Double.pi/2)
            
            let trackPath = UIBezierPath(arcCenter: viewCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            trackPath.lineWidth = 2
            Const.Color_Authing_Main.setStroke()
            trackPath.stroke()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
                self.setNeedsDisplay()
            }
        }
    }
}
