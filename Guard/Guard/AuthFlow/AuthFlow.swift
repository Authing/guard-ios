//
//  AuthFlow.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import UIKit

public class AuthFlow {
    public static func start(nibName: String? = nil, authCompletion: AuthNavigationController.AuthCompletion? = nil) {
        var vc: IndexAuthViewController? = nil
        if (nibName == nil) {
            vc = IndexAuthViewController(nibName: "AuthingLogin", bundle: Bundle(for: Self.self))
        } else {
            vc = IndexAuthViewController(nibName: nibName, bundle: nil)
        }
        
        guard vc != nil else {
            return
        }

        let nav: AuthNavigationController = AuthNavigationController(rootViewController: vc!)
        nav.setNavigationBarHidden(true, animated: false)
        nav.setAuthCompletion(authCompletion)
        nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        UIApplication.topViewController()!.present(nav, animated: true, completion: nil)
    }
}
