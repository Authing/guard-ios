//
//  OneClickViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/12/15.
//

import UIKit
import Guard
import OneAuth

class OneClickViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var btnOneClick: UIButton!
    
    var token: String? = nil
    
    override func viewDidLoad() {
    }
    
    @IBAction func onClick(_ sender: UIButton, forEvent event: UIEvent) {
        let model: NTESQuickLoginModel = NTESQuickLoginModel()
        model.currentVC = self
        model.customViewBlock = { cumtom in
            
        }
        
        OneAuth.start(self) { code, message, userInfo in
            DispatchQueue.main.async() {
                if (code == 200 && userInfo != nil) {
                    self.navigationController?.popViewController(animated: true)
                    self.finishAndGoHome(userInfo)
                } else {
                    self.errorLabel.text = message
                }
            }
        }
    }
    
    func finishAndGoHome(_ userInfo: UserInfo?) {
        self.navigationController?.popViewController(animated: true)
        let vc: MainViewController = MainViewController(nibName: "AuthingUserProfile", bundle: Bundle(for: UserProfileViewController.self))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
