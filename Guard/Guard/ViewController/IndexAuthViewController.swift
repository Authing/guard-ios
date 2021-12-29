//
//  IndexAuthViewController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class IndexAuthViewController: AuthViewController {
    open override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
