//
//  UserProfileViewController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

import UIKit

open class UserProfileViewController: AuthViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Const.Color_BG_Gray
        
        title = NSLocalizedString("authing_user_profile", bundle: Bundle(for: UserProfileViewController.self), comment: "")
    }
}
