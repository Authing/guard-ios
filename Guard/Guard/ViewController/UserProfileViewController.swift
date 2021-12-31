//
//  UserProfileViewController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

import UIKit

open class UserProfileViewController: AuthViewController {
    
    @IBOutlet weak var container: UIScrollView!
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelPhone: UILabel!
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        checkStatus()
    }
    
    func checkStatus() {
        AuthClient.getCurrentUserInfo { code, message, userInfo in
            DispatchQueue.main.async() {
                if (code == 200 && userInfo != nil) {
                    self.updateProfile(userInfo)
                } else {
                    AuthFlow.start()
                }
            }
        }
    }
    
    func updateProfile(_ userInfo: UserInfo?) {
        container.isHidden = false
        
        let undefined = NSLocalizedString("undefined", bundle: Bundle(for: Self.self), comment: "")
        self.labelUsername.text = userInfo?.getUserName() ?? undefined
        self.labelEmail.text = userInfo?.getEmail() ?? undefined
        self.labelPhone.text = userInfo?.getPhone() ?? undefined
    }
    
    @IBAction func onLogout(_ sender: UIButton, forEvent event: UIEvent) {
        AuthClient.logout { code, message in
            self.checkStatus()
        }
    }
}
