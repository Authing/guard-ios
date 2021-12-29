//
//  AuthViewController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import UIKit

open class AuthViewController: UIViewController {
    
    public override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(false, animated: true)
//        let backImage = UIImage(named: "authing_back", in: Bundle(for: Self.self), compatibleWith: nil)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(onBack))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    @IBAction func onCloseClick(_ sender: UIButton, forEvent event: UIEvent) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
