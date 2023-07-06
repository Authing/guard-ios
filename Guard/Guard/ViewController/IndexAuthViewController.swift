//
//  IndexAuthViewController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

@objc open class IndexAuthViewController: AuthViewController {
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
