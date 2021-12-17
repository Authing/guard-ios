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
        OneAuth.start { code, message, userInfo in
            if (code == 200 && userInfo != nil) {
                
            } else {
                self.errorLabel.text = message
            }
        }
    }
}
