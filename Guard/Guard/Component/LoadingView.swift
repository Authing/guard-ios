//
//  LoadingView.swift
//  Guard
//
//  Created by JnMars on 2022/5/18.
//


open class LoadingView: ImageView {
    
    var animationView: UIImageView!
    let itemWidth: CGFloat = 60
    let itemHeight: CGFloat = 70
    var loadWork: DispatchWorkItem?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.white
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        self.addGestureRecognizer(tapGesture)
        
        var images = [UIImage]();
        for i in 0 ... 29{
            images.append(UIImage(named: "authing_loading-\(i)", in: Bundle(for: Self.self), compatibleWith: nil) ?? UIImage())
        }
        animationView  = UIImageView()
        animationView.frame = CGRect(x: UIScreen.main.bounds.width/2 - itemWidth/2,
                                     y: UIScreen.main.bounds.height/2 - itemHeight/2,
                                     width: itemWidth,
                                     height: itemHeight)
        animationView.animationImages = images
        animationView.animationDuration = 1
        animationView.animationRepeatCount = 0
                
        self.addSubview(animationView)
    }
    
    @objc private func tapGestureAction(){
        
    }
    
    public class func startAnimation(_ images: [UIImage] = [], _ imageSize: CGSize = CGSize.zero) -> LoadingView{
        
        let loading = LoadingView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        loading.isHidden = true
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        container.backgroundColor = Util.getWhiteBackgroundColor()
        container.addSubview(loading)
        
        if #available(iOS 11, *) {
             UIApplication.shared.keyWindow?.addSubview(container)
        } else {
             UIApplication.shared.windows.last?.addSubview(container)
        }
        
        // Show the animation after 0.5 seconds, the reloaded page does not flicker
        loading.loadWork = DispatchWorkItem(block: {
            loading.isHidden = false
                            
            if images.count != 0 {
                loading.animationView.frame = CGRect(x: UIScreen.main.bounds.width/2 - imageSize.width/2,
                                                           y: UIScreen.main.bounds.height/2 - imageSize.height/2,
                                                           width: imageSize.width,
                                                           height: imageSize.height)
                loading.animationView.animationImages = images
            }
        
            loading.animationView.startAnimating()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: loading.loadWork!)
        
        return loading
    }
    
    public class func stopAnimation(loadingView: LoadingView) {
        if loadingView.isHidden {
            loadingView.loadWork?.cancel()
            if let v = loadingView.superview {
                v.removeFromSuperview()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
                loadingView.animationView.stopAnimating()
                if let v = loadingView.superview {
                    v.removeFromSuperview()
                } else {
                    loadingView.removeFromSuperview()
                }
            }
        }
    }
}
