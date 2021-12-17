//
//  MainViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/12/14.
//

import UIKit
import Guard

class MainViewController: UIViewController {
    
    public var userInfo: UserInfo?
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelPhone: UILabel!
    
    override func viewDidLoad() {
        labelUsername.text = userInfo?.getUserName()
        labelEmail.text = userInfo?.getEmail()
        labelPhone.text = userInfo?.getPhone()
    }
}
