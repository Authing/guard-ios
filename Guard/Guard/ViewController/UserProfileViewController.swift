//
//  UserProfileViewController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/30.
//

open class UserProfileViewController: AuthViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Util.getGrayBackgroundColor()
        
        title = NSLocalizedString("authing_user_profile", bundle: Bundle(for: UserProfileViewController.self), comment: "")
    }
}
