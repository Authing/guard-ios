//
//  AppLogo.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import UIKit

open class AppLogo: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Authing.getConfig { config in
            let url = NSURL(string: (config?.getLogoUrl())!)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url! as URL)
                DispatchQueue.main.async() { [weak self] in
                    self?.image = UIImage(data: data!)
                }
            }
        }
    }
}
