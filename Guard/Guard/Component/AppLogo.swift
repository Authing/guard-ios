//
//  AppLogo.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import UIKit

open class AppLogo: UIImageView, AttributedViewProtocol {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Authing.getConfig { config in
            guard config != nil else {
                return
            }
            guard config?.getLogoUrl() != nil else {
                return
            }
            
            let url = NSURL(string: (config?.getLogoUrl())!)
            if (url == nil) {
                return
            }
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url! as URL)
                DispatchQueue.main.async() { [weak self] in
                    if (data != nil) {
                        self?.image = UIImage(data: data!)
                    }
                }
            }
        }
    }
}
