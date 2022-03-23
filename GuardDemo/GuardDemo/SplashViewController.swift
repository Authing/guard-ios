//
//  SplashViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/11/23.
//

import Guard

class SplashViewController: UIViewController {

    @IBOutlet weak var logoView: UIImageView!
    var flag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Guard.autoLogin() { code, message, userInfo in
            DispatchQueue.main.async() {
                self.next(1)
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            self.next(2)
        }
    }
    
    func next(_ f: Int) {
        flag |= f
        
        if (flag == 3) {
            var root: UIViewController? = nil
            if (Guard.getCurrentUser() != nil) {
                root = MainViewController(nibName: "AuthingUserProfile", bundle: Bundle(for: UserProfileViewController.self))
            } else {
                root = SampleListViewController()
            }
            
            let keyWindow = UIApplication.shared.windows.first
            let nav: UINavigationController = UINavigationController(rootViewController: root!)
            keyWindow?.rootViewController = nav
        }
    }
}
