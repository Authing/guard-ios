//
//  SplashViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/11/23.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var logoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            let rootVC = SampleListViewController(style: .plain)
            let keyWindow = UIApplication.shared.windows.first
            let nav: UINavigationController = UINavigationController(rootViewController: rootVC)
            keyWindow?.rootViewController = nav
        }
    }
}
