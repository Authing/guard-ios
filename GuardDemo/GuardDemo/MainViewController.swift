//
//  MainViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/12/14.
//

import Guard

class MainViewController: UserProfileViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let v = Util.findView(view, viewClass: LogoutButton.self) as? LogoutButton {
            v.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
        }
    }
    
    @objc private func onClick(sender: UIButton) {
        AuthClient.logout { code, message in
            DispatchQueue.main.async() {
                let root = SampleListViewController(style: .plain)
                let keyWindow = UIApplication.shared.windows.first
                let nav: UINavigationController = UINavigationController(rootViewController: root)
                keyWindow?.rootViewController = nav
            }
        }
    }
}
