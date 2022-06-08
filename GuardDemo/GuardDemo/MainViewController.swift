//
//  MainViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/12/14.
//

import Guard
import UIKit

class MainViewController: UserProfileViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let v = Util.findView(view, viewClass: LogoutButton.self) as? LogoutButton {
            v.onLogout = { code, message in
                self.goSampleList()
            }
        }
        
        if let v = Util.findView(view, viewClass: DeleteAccountButton.self) as? DeleteAccountButton {
            v.onDeleteAccount = { code, message in
                self.goSampleList()
            }
        }
    }
    
    private func goSampleList() {
        DispatchQueue.main.async() {
            let root = SampleListViewController(style: .plain)
            let keyWindow = UIApplication.shared.windows.first
            let nav: UINavigationController = UINavigationController(rootViewController: root)
            keyWindow?.rootViewController = nav
        }
    }
}
