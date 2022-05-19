//
//  LoadingView.swift
//  Guard
//
//  Created by JnMars on 2022/5/18.
//

import Foundation
import UIKit

open class LoadingView: ImageView {
    
    var animationView: UIImageView!
    let itemWidth: CGFloat = 60
    let itemHeight: CGFloat = 70

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
    
    public class func startAnimation(viewController: UIViewController, _ images: [UIImage] = [], imageSize: CGSize = CGSize.zero) -> LoadingView{
        
        let loading = LoadingView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        viewController.view.addSubview(loading)
                        
        if images.count != 0 {
            loading.animationView.frame = CGRect(x: UIScreen.main.bounds.width/2 - imageSize.width/2,
                                                       y: UIScreen.main.bounds.height/2 - imageSize.height/2,
                                                       width: imageSize.width,
                                                       height: imageSize.height)
            loading.animationView.animationImages = images
        }
        loading.animationView.startAnimating()
        
        return loading
    }
    
    public class func stopAnimation(loadingView: LoadingView) {
        
        loadingView.animationView.stopAnimating()
        loadingView.removeFromSuperview()

    }
}
