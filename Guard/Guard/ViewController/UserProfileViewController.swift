//
//  UserProfileViewController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

@objc open class UserProfileViewController: AuthViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Util.getGrayBackgroundColor()
        
        title = "authing_user_profile".L
    }
}
